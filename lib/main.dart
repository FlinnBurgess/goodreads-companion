import 'package:flutter/material.dart';
import 'package:goodreads_companion/recommendations.dart';
import 'package:goodreads_companion/shelf.dart';
import 'package:goodreads_companion/statistics.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';

import 'book.dart';
import 'library.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Library library = await Library.load();

  runApp(ChangeNotifierProvider(create: (_) => library, child: MyApp()));
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

  @override
  Widget build(BuildContext context) {
    return Consumer<Library>(builder: (context, library, _) {
      _populateLibrary(library);

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
              return Column(children: [
                BooksReadStatistic(
                  books: books,
                ),
                AverageNumberOfPagesStatistic(
                  books: books,
                ),
                TotalPagesReadStatistic(
                  books: books,
                )
              ]);
            case RECOMMEND:
              return BookRecommendationsPage(books);
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
      } else if (library.shelves.isNotEmpty) {
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

  void _populateLibrary(Library library) async {
    if (library.shelves.isEmpty && !library.populationStarted) {
      library.populationStarted = true;
      http.Response response = await http.get(
          'https://www.goodreads.com/shelf/list.xml?key=f4gRbjUEvwrshiwBhwQ&user_id=45519898');
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
            'https://www.goodreads.com/review/list/45519898.xml?key=f4gRbjUEvwrshiwBhwQ&v=2&shelf=$shelfName&per_page=$BOOK_RETRIEVAL_PAGE_SIZE';
        List<XmlElement> allReviewsXml = [];

        while (booksRemaining > 0) {
          http.Response response = await http.get(url + '&page=$page');
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
