import 'package:flutter/material.dart';
import 'package:goodreads_companion/book_list_page.dart';
import 'package:goodreads_companion/settings_page.dart';
import 'package:goodreads_companion/statistics_page.dart';
import 'package:provider/provider.dart';

import 'library.dart';
import 'random_book.dart';

class MainUI extends StatefulWidget {
  @override
  _MainUIState createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  static const int BOOKS_LIST = 0;
  static const int STATISTICS = 1;
  static const int RANDOM_BOOK = 2;
  static const int SETTINGS = 3;
  int _selectedPage = BOOKS_LIST;

  var _pageTitles = {
    BOOKS_LIST: 'All Books',
    STATISTICS: 'Statistics',
    RANDOM_BOOK: 'Random Book',
    SETTINGS: 'Settings'
  };

  @override
  Widget build(BuildContext context) {
    var bottomNavBar = BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey[700],
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.library_books), title: Text('Book lists')),
        BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart), title: Text('Statistics')),
        BottomNavigationBarItem(
            icon: Icon(Icons.repeat), title: Text('Random Book')),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), title: Text('Settings'))
      ],
      currentIndex: _selectedPage,
      onTap: (index) => setState(() => _selectedPage = index),
    );

    return Consumer<Library>(
      builder: (context, library, _) {
        var tabs = library.shelves.keys
            .map((shelfName) =>
            Tab(
              text: shelfName
                  .split('-')
                  .map((word) => word[0].toUpperCase() + word.substring(1))
                  .join(' '),
            ))
            .toList();

        var tabPages = library.shelves.keys.map((shelfName) {
          var books = library.shelves[shelfName].books;
          switch (_selectedPage) {
            case BOOKS_LIST:
              return BookListPage(books);
            case STATISTICS:
              return StatisticsPage(books,);
            case RANDOM_BOOK:
              return RandomBookPage(books, library.shelves['read'].books);
            case SETTINGS:
              return SettingsPage();
            default:
              return Text('Number of books: ${books.length}');
          }
        }).toList();

        if (_selectedPage == SETTINGS) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_pageTitles[_selectedPage]),
            ),
            body: SettingsPage(),
            bottomNavigationBar: bottomNavBar,
          );
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(_pageTitles[_selectedPage]),
              bottom: TabBar(isScrollable: true, tabs: tabs),
            ),
            body: TabBarView(
              children: tabPages,
            ),
            bottomNavigationBar: bottomNavBar,
          ),
        );
      },
    );
  }
}
