import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:goodreads_companion/book.dart';

class BookRecommendationsPage extends StatefulWidget {
  final List<Book> books;
  final List<Book> booksRead;

  BookRecommendationsPage(this.books, this.booksRead);

  @override
  _BookRecommendationsPageState createState() =>
      _BookRecommendationsPageState();
}

class _BookRecommendationsPageState extends State<BookRecommendationsPage> {
  Book selectedBook;
  var random = Random();
  int maxPages;
  int daysToRead;
  int averageReadingRate;
  int minimumRating;
  String selectedAuthor;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedAuthor = 'any';

    List<Book> booksWithData = widget.booksRead
        .where((book) =>
            book.dateStartedReading != null &&
            book.dateFinishedReading != null &&
            book.numberOfPages != null)
        .toList();

    if (booksWithData.isNotEmpty) {
      List<double> readingRates = booksWithData
          .map((book) =>
              book.numberOfPages /
              max(
                  book.dateFinishedReading
                      .difference(book.dateStartedReading)
                      .inDays,
                  1))
          .toList();

      averageReadingRate =
          (readingRates.reduce((a, b) => a + b) / readingRates.length).floor();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Book> booksWithData = widget.booksRead
        .where((book) =>
            book.dateStartedReading != null &&
            book.dateFinishedReading != null &&
            book.numberOfPages != null)
        .toList();

    List<double> readingRates = booksWithData
        .map((book) =>
            book.numberOfPages /
            max(
                book.dateFinishedReading
                    .difference(book.dateStartedReading)
                    .inDays,
                1))
        .toList();

    averageReadingRate =
        (readingRates.reduce((a, b) => a + b) / readingRates.length).floor();

    List<String> authors = [];

    widget.books.forEach((book) {
      authors.add(book.author);
    });

    authors = authors.toSet().toList();
    authors.sort((a, b) => a.compareTo(b));

    return SingleChildScrollView(
        child: Column(
      children: [
        Row(
          children: [
            Container(
                width: 300,
                child: TypeAheadField(
                  suggestionsCallback: (text) => authors
                      .where((author) =>
                          author.toLowerCase().contains(text.toLowerCase()))
                      .toList(),
                  itemBuilder: (_, match) => Container(child: Text(match)),
                  onSuggestionSelected: (selected) {
                    textEditingController.text = selected;
                    selectedAuthor = selected;
                  },
                  textFieldConfiguration: TextFieldConfiguration(
                      onChanged: (text) =>
                          selectedAuthor = (text == '' ? null : text),
                      controller: textEditingController,
                      decoration: InputDecoration(labelText: 'Author')),
                ))
          ],
        ),
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
                      setState(() => maxPages = null);
                    }
                    setState(() => maxPages = num.parse(input));
                  },
                ))
          ],
        ),
        Row(
          children: [
            Container(
                width: 300,
                child: averageReadingRate != null
                    ? TextField(
                        decoration:
                            new InputDecoration(labelText: "Days to read"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (input) {
                          if (input == '') {
                            setState(() => daysToRead = null);
                          }
                          setState(() => daysToRead = num.parse(input));
                        },
                      )
                    : Container())
          ],
        ),
        Row(
          children: [
            Container(
                width: 300,
                child: TextField(
                  decoration:
                      new InputDecoration(labelText: "Minimum avg rating"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (input) {
                    if (input == '') {
                      setState(() => minimumRating = null);
                    }
                    setState(() => minimumRating = num.parse(input));
                  },
                ))
          ],
        ),
        FlatButton(
          child: Text('Random book'),
          onPressed: () {
            print(selectedAuthor);
            List<Book> booksToSearch = List.from(widget.books);
            if (maxPages != null) {
              booksToSearch = booksToSearch
                  .where((book) =>
                      book.numberOfPages != null &&
                      book.numberOfPages < maxPages)
                  .toList();
            }
            if (daysToRead != null) {
              booksToSearch = booksToSearch
                  .where((book) =>
                      book.numberOfPages != null &&
                      (book.numberOfPages / averageReadingRate).ceil() <=
                          daysToRead)
                  .toList();
            }
            if (minimumRating != null) {
              booksToSearch = booksToSearch
                  .where((book) => book.averageRating >= minimumRating)
                  .toList();
            }
            if (selectedAuthor != null) {
              booksToSearch = booksToSearch
                  .where((book) => book.author == selectedAuthor)
                  .toList();
            }

            setState(() => selectedBook = booksToSearch.length == 0
                ? null
                : booksToSearch[random.nextInt(booksToSearch.length)]);
          },
        ),
        selectedBook == null
            ? Text('No matches found')
            : Text('${selectedBook.title}, author: ${selectedBook.author}')
      ],
    ));
  }
}
