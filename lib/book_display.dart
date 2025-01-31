import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:goodreads_companion/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'book.dart';
import 'settings.dart';

class BookDisplay extends StatelessWidget {
  final Book book;

  final amazonLogo =
      Image(height: 20, image: AssetImage('images/affiliate-logos/amazon.png'));

  final audibleLogo = Image(
      height: 20, image: AssetImage('images/affiliate-logos/audible.png'));

  final googlePlayBooksLogo = Image(
      height: 25, image: AssetImage('images/affiliate-logos/play-books.png'));

  final bookDepositoryLogo = Image(
      height: 25,
      image: AssetImage('images/affiliate-logos/book-depository.png'));

  BookDisplay(this.book, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Settings, User>(
      builder: (context, settings, user, _) {
        int avgReadingRate = user.averageReadingRate;
        int daysToRead = avgReadingRate == null || book.numberOfPages == null
            ? null
            : (book.numberOfPages / avgReadingRate).ceil();

        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          book.author,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(book.imageUrl),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Text(
                                      'Avg Rating',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    )),
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  RatingBarIndicator(
                                    rating: book.averageRating,
                                    itemBuilder: (_, __) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20,
                                  ),
                                  Text(
                                    '(${book.numberOfRatings})',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  )
                                ]),
                                SizedBox(
                                  height: 10,
                                ),
                                book.userRating == null
                                    ? null
                                    : Padding(
                                        padding: EdgeInsets.only(left: 3),
                                        child: Text(
                                          'Your Rating',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12),
                                        )),
                                book.userRating == null
                                    ? null
                                    : RatingBarIndicator(
                                        rating: book.userRating.toDouble(),
                                        itemBuilder: (_, __) => Icon(
                                          Icons.star,
                                          color: Colors.teal,
                                        ),
                                        itemCount: 5,
                                        itemSize: 20,
                                      ),
                                book.userRating == null
                                    ? null
                                    : SizedBox(
                                        height: 10,
                                      ),
                                book.numberOfPages == null
                                    ? null
                                    : Text('${book.numberOfPages} pages'),
                                SizedBox(
                                  height: 5,
                                ),
                                daysToRead == null
                                    ? null
                                    : Text(
                                        'Estimated time to read: $daysToRead ${daysToRead > 1 ? 'days' : 'day'}.')
                              ].where((element) => element != null).toList(),
                            ))
                          ],
                        ),
                        settings.showBookDepositoryLink ||
                                settings.showGoogleBooksLink ||
                                settings.showAudibleLink ||
                                settings.showAmazonLink
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: RaisedButton(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text('Buy this book'),
                                    onPressed: () => _showBuyModal(context,
                                        '${book.title} ${book.author}')))
                            : null,
                      ].where((element) => element != null).toList())),
            ));
      },
    );
  }

  _showBuyModal(context, searchString) {
    showDialog(
        context: context,
        builder: (context) {
          return Consumer<Settings>(
            builder: (context, settings, _) {
              return SimpleDialog(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Select a Store',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          settings.showAmazonLink
                              ? RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: amazonLogo,
                                  onPressed: () => launch(_getAmazonUrl(
                                      searchString, settings.selectedCountry)),
                                )
                              : null,
                          settings.showAudibleLink
                              ? RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: audibleLogo,
                                  onPressed: () => launch(_getAudibleUrl(
                                      searchString, settings.selectedCountry)),
                                )
                              : null,
                        ].where((element) => element != null).toList(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          settings.showGoogleBooksLink
                              ? RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: googlePlayBooksLogo,
                                  onPressed: () => launch(
                                      'https://play.google.com/store/search?gl=${settings.selectedCountry}&c=books&q=$searchString'),
                                )
                              : null,
                          settings.showBookDepositoryLink
                              ? RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: bookDepositoryLogo,
                                  onPressed: () => launch(
                                      'https://www.bookdepository.com/search?searchTerm=$searchString'),
                                )
                              : null,
                        ].where((element) => element != null).toList(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CountryCodePicker(
                        onChanged: (selected) =>
                            settings.selectedCountry = selected.code,
                        initialSelection: settings.selectedCountry,
                        favorite: ['GB', 'US'],
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: true,
                      )
                    ],
                  )
                ],
              );
            },
          );
        });
  }

  String _getAmazonUrl(String bookTitle, String countryCode) {
    String url;

    switch (countryCode) {
      case 'AU':
        url = 'https://www.amazon.com.au/s?k=';
        break;
      case 'BR':
        url = 'https://www.amazon.com.br/s?k=';
        break;
      case 'CA':
        url = 'https://www.amazon.ca/s?k=';
        break;
      case 'CN':
        url = 'https://www.amazon.cn/s?k=';
        break;
      case 'FR':
        url = 'https://www.amazon.fr/s?tag=fbjulez0e-21&k=';
        break;
      case 'DE':
        url = 'https://www.amazon.de/s?tag=fbjulez0a-21&k=';
        break;
      case 'IN':
        url = 'https://www.amazon.in/s?k=';
        break;
      case 'IT':
        url = 'https://www.amazon.it/s?tag=fbjulez0b-21&k=';
        break;
      case 'JP':
        url = 'https://www.amazon.co.jp/s?k=';
        break;
      case 'MX':
        url = 'https://www.amazon.com.mx/s?k=';
        break;
      case 'NL':
        url = 'https://www.amazon.nl/s?k=';
        break;
      case 'ES':
        url = 'https://www.amazon.es/s?tag=fbjulez01-21&k=';
        break;
      case 'GB':
        url = 'https://www.amazon.co.uk/s?tag=fbjulez-21&k=';
        break;
      case 'US':
        url = 'https://www.amazon.com/s?tag=fbjulez-20&k=';
        break;
      default:
        url = 'https://www.amazon.com/s?k=';
        break;
    }

    return url += bookTitle;
  }

  String _getAudibleUrl(String bookTitle, String countryCode) {
    String url;

    switch (countryCode) {
      case 'AU':
        url = 'https://www.audible.com.au/search?keywords=';
        break;
      case 'NZ':
        url = 'https://www.audible.com.au/search?keywords=';
        break;
      case 'CA':
        url = 'https://www.audible.ca/search?keywords=';
        break;
      case 'FR':
        url = 'https://www.audible.fr/search?keywords=';
        break;
      case 'BE':
        url = 'https://www.audible.fr/search?keywords=';
        break;
      case 'CH':
        url = 'https://www.audible.fr/search?keywords=';
        break;
      case 'DE':
        url = 'https://www.audible.de/search?keywords=';
        break;
      case 'AT':
        url = 'https://www.audible.de/search?keywords=';
        break;
      case 'IN':
        url = 'https://www.audible.in/search?keywords=';
        break;
      case 'IT':
        url = 'https://www.audible.it/search?keywords=';
        break;
      case 'JP':
        url = 'https://www.audible.co.jp/search?keywords=';
        break;
      case 'GB':
        url = 'https://www.audible.co.uk/search?keywords=';
        break;
      case 'IE':
        url = 'https://www.audible.co.uk/search?keywords=';
        break;
      case 'US':
        url = 'https://www.audible.com/search?keywords=';
        break;
      default:
        url = 'https://www.audible.com/search?keywords=';
        break;
    }

    return url += bookTitle;
  }
}
