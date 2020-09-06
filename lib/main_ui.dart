import 'package:flutter/material.dart';
import 'package:goodreads_companion/statistics.dart';
import 'package:provider/provider.dart';

import 'library.dart';
import 'recommendations.dart';

class MainUI extends StatefulWidget {
  @override
  _MainUIState createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  static const int BOOKS_LIST = 0;
  static const int STATISTICS = 1;
  static const int RECOMMEND = 2;
  static const int SETTINGS = 3;
  int _selectedPage = BOOKS_LIST;

  @override
  Widget build(BuildContext context) {
    return Consumer<Library>(builder: (context, library, _) {
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
    },);
  }
}
