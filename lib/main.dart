import 'package:flutter/material.dart';
import 'package:goodreads_companion/authentication.dart';
import 'package:goodreads_companion/authentication_page.dart';
import 'package:goodreads_companion/data_refresh_prompt.dart';
import 'package:goodreads_companion/main_ui.dart';
import 'package:goodreads_companion/settings.dart';
import 'package:goodreads_companion/shelf.dart';
import 'package:goodreads_companion/statistics.dart';
import 'package:goodreads_companion/user_id_input_page.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';
import 'package:oauth1/oauth1.dart' as oauth1;

import 'book.dart';
import 'library.dart';
import 'user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Library library = await Library.load();
  User user = await User.load();
  Authentication authentication = await Authentication.load();
  Settings settings = await Settings.load();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => library,
      ),
      ChangeNotifierProvider(
        create: (_) => user,
      ),
      ChangeNotifierProvider(
        create: (_) => authentication,
      ),
      ChangeNotifierProvider(
        create: (_) => settings,
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GR Books Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int BOOK_RETRIEVAL_PAGE_SIZE = 200;

  String userIdInputError;

  @override
  Widget build(BuildContext context) {
    return Consumer4<Library, User, Authentication, Settings>(
        builder: (context, library, user, authentication, settings, _) {
      if (DateTime.now().difference(settings.lastDownloaded).inDays >= 1) {
        return DataRefreshPrompt();
      }

      if (user.userId == null) {
        return UserIDInputPage(userIdInputError);
      }

      if (!library.populationStarted && !library.isPopulated()) {
        _populateLibrary(library, user, authentication, settings);
      }

      if (authentication.needsAuthentication) {
        return AuthenticationPage();
      }

      if (library.isPopulated()) {
        if (user.averageReadingRate == null) {
          try {
            user.averageReadingRate = calculateAverageReadingRateInDays(
                library.shelves['read'].books,
                settings.excludeBooksReadInASingleDayFromStats);
          } catch (e) {}
        }
        return MainUI();
      } else if (library.shelves != null && library.shelves.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goodreads Companion'),
          ),
          body: Center(
            child: LibraryPopulationProgressIndicator(library.shelves),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goodreads Companion'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }

  void _populateLibrary(Library library, User user,
      Authentication authentication, Settings settings) async {
    oauth1.Client oauthClient;
    Future<http.Response> Function(String) getGoodreadsResponse;

    if (authentication.accessCredentials == null) {
      getGoodreadsResponse = (url) => http.get(url);

      http.Response response = await getGoodreadsResponse(
          'https://www.goodreads.com/review/list/${user.userId}.xml?key=${Authentication.API_KEY}&v=2&shelf=read&per_page=1');

      if (response.statusCode == 403) {
        authentication.needsAuthentication = true;
        return;
      } else {
        library.readyToPopulate = true;
        authentication.needsAuthentication = false;
      }
    } else {
      oauthClient = new oauth1.Client(Authentication.platform.signatureMethod,
          Authentication.clientCredentials, authentication.accessCredentials);

      getGoodreadsResponse = (url) => oauthClient.get(url);

      http.Response response = await getGoodreadsResponse(
          'https://www.goodreads.com/review/list/${user.userId}.xml?key=${Authentication.API_KEY}&v=2&shelf=read&per_page=1');

      if ([403, 401].contains(response.statusCode)) {
        authentication.needsAuthentication = false;
        setState(() {
          userIdInputError =
              'It seems that the user ID you entered (${user.userId})\na) Doesn\'t belong to you\nb) Doesn\'t belong to a Goodreads friend\nand c) Doesn\'t belong to a user with a public profile.\nEnter an ID which satisfies one of these requirements and try again.';
        });
        user.userId = null;
        library.reset();
        user.reset();
        return;
      } else {
        library.readyToPopulate = true;
        authentication.needsAuthentication = false;
      }
    }

    if (library.readyToPopulate &&
        library.shelves == null &&
        !library.populationStarted) {
      library.populationStarted = true;
      http.Response response = await getGoodreadsResponse(
          'https://www.goodreads.com/shelf/list.xml?key=${Authentication.API_KEY}&user_id=${user.userId}');

      var xml = XmlDocument.parse(response.body);
      xml
          .getElement('GoodreadsResponse')
          .getElement('shelves')
          .findAllElements('user_shelf')
          .forEach((shelfXml) => library.addShelf(
              shelfXml.getElement('name').text,
              num.parse(shelfXml.getElement('book_count').text)));

      for (var shelfName in library.shelves.keys) {
        int booksRemaining = library.shelves[shelfName].size;
        int page = 1;
        var url =
            'https://www.goodreads.com/review/list/${user.userId}.xml?key=${Authentication.API_KEY}&v=2&shelf=$shelfName&per_page=$BOOK_RETRIEVAL_PAGE_SIZE';
        List<XmlElement> allReviewsXml = [];

        while (booksRemaining > 0) {
          http.Response response =
              await getGoodreadsResponse(url + '&page=$page');

          var xml = XmlDocument.parse(response.body);
          allReviewsXml.addAll(xml
              .getElement('GoodreadsResponse')
              .getElement('reviews')
              .findAllElements('review')
              .toList());
          booksRemaining -= BOOK_RETRIEVAL_PAGE_SIZE;
          library.updateShelfPopulationProgress(
              shelfName, BOOK_RETRIEVAL_PAGE_SIZE);
          page++;
        }

        List<Book> books = await generateBooksFromXml(allReviewsXml);

        library.addBooksToShelf(shelfName, books);
      }

      library.save();
      settings.lastDownloaded = DateTime.now();
    }
  }

  Future<List<Book>> generateBooksFromXml(
      List<XmlElement> allReviewsXml) async {
    List<Book> books =
        allReviewsXml.map((reviewXml) => Book.fromXml(reviewXml)).toList();

//    await Future.forEach(books, (Book book) async => book.enrichWithGoogleData());

//    allReviewsXml.forEach((reviewXml) async {
//      var book = Book.fromXml(reviewXml);
//      await book.enrichWithGoogleData();
//      books.add(book);
//    });

    return books;
  }
}

class LibraryPopulationProgressIndicator extends StatelessWidget {
  final Map<String, Shelf> shelves;

  LibraryPopulationProgressIndicator(this.shelves);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: shelves.values
            .map((shelf) => Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(children: [
                  Text(shelf.name),
                  LinearProgressIndicator(
                    value: shelf.populationProgress / shelf.size,
                  )
                ])))
            .toList(),
      ),
    );
  }
}
