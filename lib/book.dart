import 'dart:math';

import 'package:http/http.dart';
import 'package:xml/xml.dart';

class Book {
  int goodreadsId;
  String isbn;
  String isbn13;
  String title;
  String imageUrl;
  String smallImageUrl;
  String goodreadsUrl;
  int numberOfPages;
  double averageRating;
  int numberOfRatings;
  String author;
  String rawDateStartedReading;
  DateTime dateStartedReading;
  String rawDateFinishedReading;
  DateTime dateFinishedReading;

  int userRating;
  List<String> categories;

  Book.fromXml(XmlElement reviewXml) {
    rawDateStartedReading = reviewXml.getElement('started_at').text;
    dateStartedReading = _dateTimeFromRawText(rawDateStartedReading);
    rawDateFinishedReading = reviewXml.getElement('read_at').text;
    dateFinishedReading = _dateTimeFromRawText(rawDateFinishedReading);
    userRating = reviewXml.getElement('rating').text == ''
        ? null
        : num.parse(reviewXml.getElement('rating').text);

    var bookXml = reviewXml.getElement('book');

    goodreadsId = num.parse(bookXml.getElement('id').text);
    isbn = bookXml.getElement('isbn').getAttribute('nil') != null
        ? bookXml.getElement('isbn').text
        : null;
    isbn13 = bookXml.getElement('isbn13').getAttribute('nil') != null
        ? bookXml.getElement('isbn13').text
        : null;
    title = bookXml.getElement('title').text;
    imageUrl = bookXml.getElement('image_url').text;
    smallImageUrl = bookXml.getElement('small_image_url').text;
    goodreadsUrl = bookXml.getElement('link').text;
    numberOfPages = bookXml.getElement('num_pages').text == ''
        ? null
        : num.parse(bookXml.getElement('num_pages').text);
    averageRating = num.parse(bookXml.getElement('average_rating').text);
    numberOfRatings = num.parse(bookXml.getElement('ratings_count').text);
    author = bookXml
        .getElement('authors')
        .getElement('author')
        .getElement('name')
        .text;
    categories = [];
  }

  Book.fromJson(Map json) {
    goodreadsId = json['goodreadsId'];
    isbn = json['isbn'];
    isbn13 = json['isbn13'];
    title = json['title'];
    imageUrl = json['imageUrl'];
    smallImageUrl = json['smallImageUrl'];
    goodreadsUrl = json['goodreadsUrl'];
    numberOfPages = json['numberOfPages'];
    averageRating = json['averageRating'];
    numberOfRatings = json['numberOfRatings'];
    author = json['author'];
    rawDateStartedReading = json['rawDateStartedReading'];
    dateStartedReading = _dateTimeFromRawText(rawDateStartedReading);
    rawDateFinishedReading = json['rawDateFinishedReading'];
    dateFinishedReading = _dateTimeFromRawText(rawDateFinishedReading);
    userRating = json['userRating'];
  }

  Map<String, dynamic> asJson() {
    return {
      'goodreadsId': goodreadsId,
      'isbn': isbn,
      'isbn13': isbn13,
      'title': title,
      'imageUrl': imageUrl,
      'smallImageUrl': smallImageUrl,
      'goodreadsUrl': goodreadsUrl,
      'numberOfPages': numberOfPages,
      'averageRating': averageRating,
      'numberOfRatings': numberOfRatings,
      'author': author,
      'rawDateStartedReading': rawDateStartedReading,
      'rawDateFinishedReading': rawDateFinishedReading,
      'userRating': userRating,
    };
  }

  DateTime _dateTimeFromRawText(String date) {
    if (date == '') {
      return null;
    }

    var dateComponents = date.split(' ');
    var year = dateComponents.last;
    var month = dateComponents[1];
    var dayOfMonth = dateComponents[2];
    var time = dateComponents[3];

    return DateTime.parse('$year-${monthMapping[month]}-$dayOfMonth $time');
  }

  Future<Book> enrichWithGoogleData() async {
    _enrichCategories();

//    var url = _getGoogleBooksUrl();
//
//    Response response = await get(url);
//    Map googleBooksResponse = jsonDecode(response.body);
//
//    if (googleBooksResponse['totalItems'] == 0) {
//      return this;
//    }
//
//    Map result = googleBooksResponse['items'][0];
//
//    _enrichIdentifiers(result);
//    _enrichImageLinks(result);
//    _enrichNumberOfPages(result);
//    _enrichRatings(result);
//    _enrichAuthor(result);

    return this;
  }

  _getGoogleBooksUrl() {
    var url = 'https://www.googleapis.com/books/v1/volumes?q=';

    if (isbn != null) {
      url += 'isbn:$isbn';
    } else if (isbn13 != null) {
      url += 'isbn:$isbn13';
    } else {
      url += title;
      if (author != null) {
        url += '+inauthor:$author';
      }
    }

    return url;
  }

  void _enrichIdentifiers(googleBooksResult) {
    List identifiers = googleBooksResult['volumeInfo']['industryIdentifiers'];

    if (isbn == null) {
      var googleIsbn10 = identifiers
          .where((identifier) => identifier['type'] == 'ISBN_10')
          .toList();
      if (googleIsbn10.length > 0) {
        isbn = googleIsbn10[0]['identifier'];
      }
    }

    if (isbn13 == null) {
      var googleIsbn13 = identifiers
          .where((identifier) => identifier['type'] == 'ISBN_13')
          .toList();
      if (googleIsbn13.length > 0) {
        isbn13 = googleIsbn13[0]['identifier'];
      }
    }
  }

  void _enrichImageLinks(googleBooksResult) {
    Map imageLinks = googleBooksResult['volumeInfo']['imageLinks'];

    if (imageUrl == null || imageUrl == '' || imageUrl.contains('nophoto')) {
      if (imageLinks != null && imageLinks['thumbnail'] != null) {
        imageUrl = imageLinks['thumbnail'];
      }
    }

    if (smallImageUrl == null ||
        smallImageUrl == '' ||
        smallImageUrl.contains('nophoto')) {
      if (imageLinks != null && imageLinks['smallThumbnail'] != null) {
        smallImageUrl = imageLinks['smallThumbnail'];
      }
    }
  }

  void _enrichNumberOfPages(Map googleBooksResult) {
    if (numberOfPages == null) {
      numberOfPages = googleBooksResult['volumeInfo']['pageCount'];
    }
  }

  void _enrichRatings(Map googleBooksResult) {
    if (numberOfRatings == null || averageRating == null) {
      if (googleBooksResult['volumeInfo']['averageRating'] != null &&
          googleBooksResult['volumeInfo']['ratingsCount'] != null) {
        numberOfRatings = googleBooksResult['volumeInfo']['ratingsCount'];
        averageRating = googleBooksResult['volumeInfo']['averageRating'];
      }
    }
  }

  void _enrichAuthor(Map googleBooksResult) {
    if (author == null || author == '') {
      if (List.from(googleBooksResult['volumeInfo']['authors']).isNotEmpty) {
        author = googleBooksResult['volumeInfo']['authors'][0];
      }
    }
  }

  Future<void> _enrichCategories() async {
    print('Enriching categories...');

    get(goodreadsUrl).then((response) {
      String goodreadsPageHtml = response.body;

      RegExp regExp = new RegExp(r'\/genres\/[a-z-]+\"\>(.*)\<');
      var genresFound = regExp.allMatches(goodreadsPageHtml);

      int currentMatch = 0;
      int genresToStore = min(3, genresFound.length);

      while (currentMatch < genresToStore) {
        categories.add(genresFound.elementAt(currentMatch).group(0));
        currentMatch++;
      }

      print('categories found: ${categories.toString()}');
    });
  }

  @override
  String toString() {
    return 'Book{goodreadsId: $goodreadsId, isbn: $isbn, isbn13: $isbn13, title: $title, imageUrl: $imageUrl, smallImageUrl: $smallImageUrl, goodreadsUrl: $goodreadsUrl, numberOfPages: $numberOfPages, averageRating: $averageRating, numberOfRatings: $numberOfRatings, author: $author, userRating: $userRating, rawDateStartedReading: $rawDateStartedReading, dateStartedReading: $dateStartedReading, rawDateFinishedReading: $rawDateFinishedReading, dateFinishedReading: $dateFinishedReading}';
  }
}

const monthMapping = {
  'Jan': '01',
  'Feb': '02',
  'Mar': '03',
  'Apr': '04',
  'May': '05',
  'Jun': '06',
  'Jul': '07',
  'Aug': '08',
  'Sep': '09',
  'Oct': '10',
  'Nov': '11',
  'Dec': '12',
};
