import 'package:flutter/material.dart';

import 'book.dart';

class BooksReadStatistic extends StatelessWidget {
  final List<Book> books;

  const BooksReadStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var numberOfBooksRead =
        books.where((book) => book.dateFinishedReading != null).length;

    int percentageOfBooksRead =
        ((numberOfBooksRead / books.length) * 100).floor();

    return Container(
      height: 60,
      child: Column(
          children: [Text('Books Read'), Text('$percentageOfBooksRead%')]),
    );
  }
}

class AverageNumberOfPagesStatistic extends StatelessWidget {
  final List<Book> books;

  const AverageNumberOfPagesStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> numberOfPagesData = books
        .where((book) => book.numberOfPages != null)
        .map((book) => book.numberOfPages)
        .toList();

    if (numberOfPagesData.isEmpty) {
      return Container(
          height: 60,
          child: Column(
            children: [
              Text('Average number of pages'),
              Text('No data available')
            ],
          ));
    }

    int averagePages =
        (numberOfPagesData.reduce((a, b) => a + b) / numberOfPagesData.length)
            .floor();

    return Container(
        height: 60,
        child: Column(
          children: [Text('Average number of pages'), Text('$averagePages')],
        ));
  }
}

class TotalPagesReadStatistic extends StatelessWidget {
  final List<Book> books;

  const TotalPagesReadStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Book> booksRead = books
        .where((book) =>
            book.numberOfPages != null && book.dateFinishedReading != null)
        .toList();

    if (booksRead.isEmpty) {
      return Container(
          height: 60,
          child: Column(
            children: [Text('Total pages read'), Text('No data available')],
          ));
      return Text('No data available');
    }

    int totalPages =
        booksRead.map((book) => book.numberOfPages).reduce((a, b) => a + b);

    return Container(
        height: 60,
        child: Column(
          children: [Text('Total number of pages read'), Text('$totalPages')],
        ));
  }
}
