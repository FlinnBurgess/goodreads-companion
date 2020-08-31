import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goodreads_companion/book.dart';

class BookRecommendationsPage extends StatefulWidget {
  final List<Book> books;

  BookRecommendationsPage(this.books);

  @override
  _BookRecommendationsPageState createState() =>
      _BookRecommendationsPageState();
}

class _BookRecommendationsPageState extends State<BookRecommendationsPage> {
  Book selectedBook;
  var random = Random();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatButton(
          child: Text('Random book'),
          onPressed: () => setState(() =>
              selectedBook = widget.books[random.nextInt(widget.books.length)]),
        ),
        selectedBook == null ? Container() : Text(selectedBook.title)
      ],
    );
  }
}
