import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodreads_companion/authentication.dart';
import 'package:goodreads_companion/recommendations.dart';
import 'package:goodreads_companion/shelf.dart';
import 'package:goodreads_companion/statistics.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      home: MyHomePage(title: 'GR Books Companion'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int BOOKS_LIST = 0;
  static const int STATISTICS = 1;
  static const int RECOMMEND = 2;
  static const int SETTINGS = 3;
  static const int BOOK_RETRIEVAL_PAGE_SIZE = 200;

  int _selectedPage = BOOKS_LIST;

  String userIdInput;
  String userIdInputError;
  Widget userCheckResultMessage;

  String authenticationErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer3<Library, User, Authentication>(
        builder: (context, library, user, authentication, _) {
      if (user.userId == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goodreads Companion'),
          ),
          body: Center(
            child: Column(
              children: [
                Text('Enter your goodreads ID'),
                Text(
                    'This is the number shown in the URL of the goodreads website when you click on "My Books"'),
                Row(children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        decoration:
                            new InputDecoration(labelText: "Goodreads ID"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (input) {
                          if (input.replaceAll(' ', '') == '') {
                            setState(() => userIdInput = null);
                          }
                          setState(() => userIdInput = input);
                        },
                      )),
                  RaisedButton(
                    child: Text('Check ID'),
                    onPressed: () {
                      setState(() {
                        userCheckResultMessage = null;
                      });

                      if (userIdInput == null || userIdInput.replaceAll(' ', '') == '') {
                        return;
                      }

                      userCheckResultMessage = CircularProgressIndicator();

                      http
                          .get(
                              'https://www.goodreads.com/user/show/$userIdInput.xml?key=${Authentication.API_KEY}')
                          .then((response) {
                        if (response.statusCode == 404) {
                          setState(() {
                            userCheckResultMessage = Text(
                              'User does not exist',
                              style: TextStyle(color: Colors.red),
                            );
                          });
                        } else {
                          var xml = XmlDocument.parse(response.body);
                          var name =
                              xml.getElement('GoodreadsResponse').getElement('user').getElement('name').text;
                          setState(() {
                            userCheckResultMessage = Text(
                              'User ID $userIdInput belongs to $name',
                              style: TextStyle(color: Colors.green),
                            );
                          });
                        }
                      });
                    },
                  )
                ]),
                userCheckResultMessage == null
                    ? Container()
                    : userCheckResultMessage,
                RaisedButton(
                  onPressed: () {
                    setState(() {
                      userIdInputError = null;
                    });
                    if (userIdInput == null || userIdInput.replaceAll(' ', '') == '') {
                      setState(() {
                        userIdInputError = 'Please enter a user ID';
                      });
                    } else {
                      http
                          .get(
                              'https://www.goodreads.com/shelf/list.xml?key=${Authentication.API_KEY}&user_id=$userIdInput}')
                          .then((response) {
                        if (response.statusCode == 404) {
                          setState(() {
                            userIdInputError =
                                'User $userIdInput doesn\'t seem to exist! Double check that you entered the correct ID.';
                          });
                        } else {
                          user.userId = userIdInput;
                        }
                      });
                    }
                  },
                  child: Text('Save'),
                ),
                userIdInputError == null
                    ? Container()
                    : Text(
                        userIdInputError,
                        style: TextStyle(color: Colors.red),
                      )
              ],
            ),
          ),
        );
      }

      print('NEEDS AUTHENTICATION: ${authentication.needsAuthentication}');

      if (!library.isPopulated()) {
        _populateLibrary(library, user, authentication);
      }

      if (authentication.needsAuthentication) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goodreads Companion'),
          ),
          body: Center(
            child: Column(
              children: [
                Text('In order to access your books'),
                RaisedButton(
                  onPressed: () {
                    _authenticateUser(authentication);
                  },
                  child: Text('Log in to Goodreads'),
                ),
                RaisedButton(
                  onPressed: () {
                    var authenticationErrorResponse = () => setState(() {
                          authenticationErrorMessage =
                              'Something went wrong! Make sure that you entered your username and password while logging in; opening the app isn\'t enough on its own.\nAlternatively, you can make your goodreads account public in the settings in order to skip this step.';
                        });

                    _getAccessToken(
                        authentication, authenticationErrorResponse);
                  },
                  child: Text('Done'),
                ),
                authenticationErrorMessage == null
                    ? Container()
                    : Text(
                        authenticationErrorMessage,
                        style: TextStyle(color: Colors.red),
                      )
              ],
            ),
          ),
        );
      }

      if (library.isPopulated()) {
        var tabs = library.shelves.keys
            .map((shelfName) => Tab(
                  text: shelfName,
                ))
            .toList();

        var tabPages = library.shelves.keys.map((shelfName) {
          var books = library.shelves[shelfName].books;
          switch (_selectedPage) {
            case BOOKS_LIST:
              return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (_, index) => Container(
                        height: 50,
                        child: Text(books[index].title),
                      ));
            case STATISTICS:
              return SingleChildScrollView(
                  child: Column(children: [
                NumberOfBooksStatistic(
                  books: books,
                ),
                BooksReadStatistic(
                  books: books,
                ),
                AverageNumberOfPagesStatistic(
                  books: books,
                ),
                TotalPagesReadStatistic(
                  books: books,
                ),
                AverageTimeToReadStatistic(
                  books: books,
                ),
                AverageReadingRateStatistic(
                  books: books,
                ),
                StartedReadingDaysStatistic(
                  books: books,
                ),
                FinishReadingDaysStatistic(books: books),
              ]));
            case RECOMMEND:
              return BookRecommendationsPage(
                  books, library.shelves['read'].books);
            case SETTINGS:
            //TODO Add a settings page
            default:
              return Text('Number of books: ${books.length}');
          }
        }).toList();

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Goodreads Companion'),
              bottom: TabBar(isScrollable: true, tabs: tabs),
            ),
            body: TabBarView(
              children: tabPages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.black,
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.grey[800],
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_books), title: Text('Book lists')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.insert_chart), title: Text('Statistics')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check), title: Text('Recommendations')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), title: Text('Settings'))
              ],
              currentIndex: _selectedPage,
              onTap: (index) => setState(() => _selectedPage = index),
            ),
          ),
        );
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

  void _populateLibrary(
      Library library, User user, Authentication authentication) async {
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
        setState(() {
          userIdInputError =
              'It seems that the user ID you entered ($userIdInput)\na) Doesn\'t belong to you\nb) Doesn\'t belong to a Goodreads friend\nand c) Doesn\'t belong to a user with their profile set to public. \nEnter an ID which satisfies one of these requirements and try again.';
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
          print('Hitting the url: ${url + '&page=$page'}');
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

  Future<void> _authenticateUser(Authentication authentication) async {
    var platform = oauth1.Platform(
        'https://www.goodreads.com/oauth/request_token',
        'https://www.goodreads.com/oauth/authorize',
        'https://www.goodreads.com/oauth/access_token',
        oauth1.SignatureMethods.hmacSha1);

    var auth =
        new oauth1.Authorization(Authentication.clientCredentials, platform);

    Authentication.authorization
        .requestTemporaryCredentials('oob')
        .then((res) async {
      authentication.temporaryCredentials = res.credentials;

      var url =
          '${auth.getResourceOwnerAuthorizationURI(res.credentials.token)}&mobile=1';

      launch(url, forceWebView: true);
    });
  }

  Future<void> _getAccessToken(
      Authentication authentication, Function onError) async {
    Authentication.authorization
        .requestTokenCredentials(authentication.temporaryCredentials, '1')
        .then((response) {
      authentication.accessCredentials = response.credentials;
      authentication.needsAuthentication = false;
    }).catchError((error) {
      onError();
    });
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
