import 'package:flutter/material.dart';

import 'book.dart';
import 'statistics.dart';

class StatisticsPage extends StatelessWidget {
  final List<Book> books;

  const StatisticsPage(this.books, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      NumberOfBooksStatistic(
        books: books,
      ),
      Divider(indent: 50, thickness: 1.1,),
      BooksReadStatistic(
        books: books,
      ),
      Divider(endIndent: 50, thickness: 1.1,),
      AverageNumberOfPagesStatistic(
        books: books,
      ),
      Divider(indent: 50, thickness: 1.1,),
      TotalPagesReadStatistic(
        books: books,
      ),
      Divider(endIndent: 50, thickness: 1.1,),
      AverageTimeToReadStatistic(
        books: books,
      ),
      Divider(indent: 50, thickness: 1.1,),
      AverageReadingRateStatistic(
        books: books,
      ),
      Divider(endIndent: 50, thickness: 1.1,),
      StartedReadingDaysStatistic(
        books: books,
      ),
      Divider(indent: 50, thickness: 1.1,),
      FinishReadingDaysStatistic(books: books),
    ]));
  }
}
