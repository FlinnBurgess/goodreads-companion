import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:goodreads_companion/book.dart';
import 'package:goodreads_companion/book_display.dart';

class RandomBookPage extends StatefulWidget {
  final List<Book> books;
  final List<Book> booksRead;

  RandomBookPage(this.books, this.booksRead);

  @override
  _RandomBookPageState createState() => _RandomBookPageState();
}

class _RandomBookPageState extends State<RandomBookPage> {
  Book selectedBook;
  var random = Random();
  int maxPages;
  int daysToRead;
  int averageReadingRate;
  int minimumRating;
  String selectedAuthor;
  final TextEditingController textEditingController = TextEditingController();
  Widget resultDisplay;

  @override
  void initState() {
    super.initState();

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

    resultDisplay = Text('Press the button to get a book');
  }

  @override
  Widget build(BuildContext context) {
    double inputSize = min(MediaQuery.of(context).size.width * 0.4, 250);

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

    return Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    resultDisplay,
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      child: Text('Random book'),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      onPressed: () {
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
                                  (book.numberOfPages / averageReadingRate)
                                          .ceil() <=
                                      daysToRead)
                              .toList();
                        }
                        if (minimumRating != null) {
                          booksToSearch = booksToSearch
                              .where(
                                  (book) => book.averageRating >= minimumRating)
                              .toList();
                        }
                        if (selectedAuthor != null &&
                            selectedAuthor.trim() != '') {
                          booksToSearch = booksToSearch
                              .where((book) =>
                                  book.author == selectedAuthor.trim())
                              .toList();
                        }

                        print(booksToSearch.length);

                        setState(() => resultDisplay = booksToSearch.length == 0
                            ? Text('No matches found')
                            : BookDisplay(booksToSearch[
                                random.nextInt(booksToSearch.length)]));
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: inputSize,
                            child: TypeAheadField(
                              suggestionsCallback: (text) => authors
                                  .where((author) => author
                                      .toLowerCase()
                                      .contains(text.toLowerCase()))
                                  .toList(),
                              itemBuilder: (_, match) => Container(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text(match)),
                              onSuggestionSelected: (selected) {
                                textEditingController.text = selected;
                                selectedAuthor = selected;
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                  onChanged: (text) => selectedAuthor =
                                      (text == '' ? null : text),
                                  controller: textEditingController,
                                  decoration:
                                      InputDecoration(labelText: 'Author', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
                            )),
                        SizedBox(
                          width: 25,
                        ),
                        Container(
                            width: inputSize,
                            child: TextField(
                              decoration: new InputDecoration(
                                  labelText: "Max pages",
                                  border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
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
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: inputSize,
                            child: averageReadingRate != null
                                ? TextField(
                                    decoration: new InputDecoration(
                                        labelText: "Days to read", border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (input) {
                                      if (input == '') {
                                        setState(() => daysToRead = null);
                                      }
                                      setState(
                                          () => daysToRead = num.parse(input));
                                    },
                                  )
                                : Container()),
                        SizedBox(
                          width: 25,
                        ),
                        Container(
                            width: inputSize,
                            child: TextField(
                              decoration: new InputDecoration(
                                  labelText: "Average rating", border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (input) {
                                if (input == '') {
                                  setState(() => minimumRating = null);
                                }
                                setState(
                                    () => minimumRating = num.parse(input));
                              },
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.1),
                        child: Text(
                          'Leave all boxes empty to get a completely random book',
                          textAlign: TextAlign.center,
                        )),
                  ],
                ))));
  }
}
