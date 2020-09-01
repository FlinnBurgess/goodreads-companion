import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

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
            max(
                book.dateFinishedReading
                    .difference(book.dateStartedReading)
                    .inDays,
                1))
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

class StartedReadingDaysStatistic extends StatelessWidget {
  final List<Book> books;

  const StartedReadingDaysStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> startedReadingCount = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };

    List<Book> booksWithStartedReadingData = books
        .where((book) =>
            book.rawDateStartedReading != null &&
            book.rawDateStartedReading != '')
        .toList();

    if (booksWithStartedReadingData.isEmpty) {
      return Container(
          height: 60,
          child: Column(
            children: [
              Text('Most popular days to start reading'),
              Text('No data available')
            ],
          ));
    }

    booksWithStartedReadingData.forEach((book) {
      String startedReading = book.rawDateStartedReading;

      if (startedReading.contains('Mon')) {
        startedReadingCount['Monday']++;
      } else if (startedReading.contains('Tue')) {
        startedReadingCount['Tuesday']++;
      } else if (startedReading.contains('Wed')) {
        startedReadingCount['Wednesday']++;
      } else if (startedReading.contains('Thu')) {
        startedReadingCount['Thursday']++;
      } else if (startedReading.contains('Fri')) {
        startedReadingCount['Friday']++;
      } else if (startedReading.contains('Sat')) {
        startedReadingCount['Saturday']++;
      } else if (startedReading.contains('Sun')) {
        startedReadingCount['Sunday']++;
      }
    });

    var chartData = {};

    startedReadingCount.keys.forEach((day) {
      chartData[day] = () => startedReadingCount[day];
    });

    return Container(
        height: 250,
        child: Column(
          children: [
            Text('Most popular days to start reading'),
            PieChart(
              dataMap: startedReadingCount,
            )
          ],
        ));
  }
}

class FinishReadingDaysStatistic extends StatelessWidget {
  final List<Book> books;

  const FinishReadingDaysStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Book> booksWithFinishedReadingData = books
        .where((book) =>
            book.rawDateFinishedReading != null &&
            book.rawDateFinishedReading != '')
        .toList();

    if (booksWithFinishedReadingData.isEmpty) {
      return Container(
          height: 60,
          child: Column(
            children: [
              Text('Most popular days to finish reading'),
              Text('No data available')
            ],
          ));
    }

    Map<String, double> finishedReadingCount = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };

    booksWithFinishedReadingData.forEach((book) {
      String finishedReading = book.rawDateFinishedReading;

      if (finishedReading.contains('Mon')) {
        finishedReadingCount['Monday']++;
      } else if (finishedReading.contains('Tue')) {
        finishedReadingCount['Tuesday']++;
      } else if (finishedReading.contains('Wed')) {
        finishedReadingCount['Wednesday']++;
      } else if (finishedReading.contains('Thu')) {
        finishedReadingCount['Thursday']++;
      } else if (finishedReading.contains('Fri')) {
        finishedReadingCount['Friday']++;
      } else if (finishedReading.contains('Sat')) {
        finishedReadingCount['Saturday']++;
      } else if (finishedReading.contains('Sun')) {
        finishedReadingCount['Sunday']++;
      }
    });

    var chartData = {};

    finishedReadingCount.keys.forEach((day) {
      chartData[day] = () => finishedReadingCount[day];
    });

    return Container(
        height: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Most popular days to finish reading'),
            PieChart(
              dataMap: finishedReadingCount,
            )
          ],
        ));
  }
}

class NumberOfBooksStatistic extends StatelessWidget {
  final List<Book> books;

  const NumberOfBooksStatistic({Key key, this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        child: Column(
          children: [
            Text('Number of books in shelf'),
            Text('${books.length}')
          ],
        ));
  }
}
