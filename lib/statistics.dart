import 'package:flutter/material.dart';

import 'book.dart';

class BooksReadStatistic extends StatelessWidget {
  final List<Book> books;

  const BooksReadStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var numberOfBooksRead = books.where((book) => book.dateFinishedReading != null).length;

    int percentageOfBooksRead = ((numberOfBooksRead / books.length) * 100).floor();

    return Container(
      child: Column(children: [Text('Books Read'), Text('$percentageOfBooksRead%')]),
    );
  }
}
