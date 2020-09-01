import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int maxPages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 300,
                child: TextField(
                  decoration: new InputDecoration(labelText: "Max pages"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (input) {
                    if (input == '') {
                      print('Empty');
                      setState(() => maxPages = null);
                    }
                    setState(() => maxPages = num.parse(input));
                  },
                ))
          ],
        ),
        FlatButton(
          child: Text('Random book'),
          onPressed: () {
            List<Book> booksToSearch = List.from(widget.books);
            if (maxPages != null) {
              booksToSearch = booksToSearch
                  .where((book) =>
              book.numberOfPages != null &&
                  book.numberOfPages < maxPages)
                  .toList();
            }
            setState(() =>
            selectedBook =
            booksToSearch[random.nextInt(booksToSearch.length)]);
          },
        ),
        selectedBook == null
            ? Text('No matches found')
            : Text(
            '${selectedBook.title}, number of pages: ${selectedBook
                .numberOfPages}')
      ],
    );
  }
}
