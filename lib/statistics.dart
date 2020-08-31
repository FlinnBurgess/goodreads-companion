import 'dart:math';

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
      child: Column(children: [
        Text('Books Read'),
        Text('$numberOfBooksRead ($percentageOfBooksRead%)')
      ]),
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

class AverageTimeToReadStatistic extends StatelessWidget {
  final List<Book> books;

  const AverageTimeToReadStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Book> booksRead = books
        .where((book) =>
            book.dateStartedReading != null && book.dateFinishedReading != null)
        .toList();

    if (booksRead.isEmpty) {
      return Container(
          height: 60,
          child: Column(
            children: [
              Text('Average time to read'),
              Text('You haven\'t finished any of the books in this shelf!')
            ],
          ));
    }

    List<int> daysTakenToRead = booksRead
        .map((book) =>
            book.dateFinishedReading.difference(book.dateStartedReading).inDays)
        .toList();

    int averageDaysToRead =
        (daysTakenToRead.reduce((a, b) => a + b) / daysTakenToRead.length)
            .floor();

    return Container(
        height: 60,
        child: Column(
          children: [
            Text('Average number of days taken to read'),
            Text('$averageDaysToRead')
          ],
        ));
  }
}

class AverageReadingRateStatistic extends StatelessWidget {
  final List<Book> books;

  const AverageReadingRateStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Book> booksWithData = books
        .where((book) =>
            book.dateStartedReading != null &&
            book.dateFinishedReading != null &&
            book.numberOfPages != null)
        .toList();

    if (booksWithData.isEmpty) {
      return Container(
          height: 60,
          child: Column(
            children: [Text('Average time to read'), Text('No data available')],
          ));
    }

    List<double> readingRates = booksWithData
        .map((book) =>
            book.numberOfPages /
            max(book.dateFinishedReading.difference(book.dateStartedReading).inDays, 1))
        .toList();

    int averageReadingRate =
        (readingRates.reduce((a, b) => a + b) / readingRates.length).floor();

    return Container(
        height: 60,
        child: Column(
          children: [
            Text('Average reading rate'),
            Text('$averageReadingRate pages a day')
          ],
        ));
  }
}
