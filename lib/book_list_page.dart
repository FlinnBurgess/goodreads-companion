import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import 'book.dart';
import 'book_display.dart';
import 'user.dart';

class BookListPage extends StatefulWidget {
  final List<Book> books;

  const BookListPage(this.books, {Key key}) : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  String selectedAuthor;
  int maxPages;
  int minimumRating;
  int daysToRead;
  final TextEditingController authorController = TextEditingController();
  final TextEditingController maxPagesController = TextEditingController();
  final TextEditingController avgRatingController = TextEditingController();
  final TextEditingController daysToReadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double inputSize = min(MediaQuery.of(context).size.width * 0.4, 250);

    List<String> authors = [];

    widget.books.forEach((book) {
      authors.add(book.author);
    });

    authors = authors.toSet().toList();
    authors.sort((a, b) => a.compareTo(b));

    var books = _applyFilters(widget.books,
        Provider.of<User>(context, listen: false).averageReadingRate);

    return Column(children: [
      Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                child: Text('Filter'),
                color: _isFiltered() ? Colors.amber : Colors.white,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Text(
                              'Filter',
                              style: TextStyle(fontSize: 20),
                            ),
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
                                        padding:
                                            EdgeInsets.only(top: 5, bottom: 5),
                                        child: Text(match)),
                                    onSuggestionSelected: (selected) {
                                      authorController.text = selected;
                                      selectedAuthor = selected;
                                    },
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                            onChanged: (text) => setState(() =>
                                                selectedAuthor =
                                                    (text == '' ? null : text)),
                                            controller: authorController,
                                            decoration: InputDecoration(
                                                labelText: 'Author')),
                                  )),
                              SizedBox(
                                width: 25,
                              ),
                              Container(
                                  width: inputSize,
                                  child: TextField(
                                    controller: maxPagesController,
                                    decoration: new InputDecoration(
                                        labelText: "Max pages"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (input) {
                                      if (input == '') {
                                        setState(() => maxPages = null);
                                      }
                                      setState(
                                          () => maxPages = num.parse(input));
                                    },
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: inputSize,
                                  child: Provider.of<User>(context)
                                              .averageReadingRate !=
                                          null
                                      ? TextField(
                                          controller: daysToReadController,
                                          decoration: new InputDecoration(
                                              labelText: "Days to read"),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          onChanged: (input) {
                                            if (input == '') {
                                              setState(() => daysToRead = null);
                                            }
                                            setState(() =>
                                                daysToRead = num.parse(input));
                                          },
                                        )
                                      : Container()),
                              SizedBox(
                                width: 25,
                              ),
                              Container(
                                  width: inputSize,
                                  child: TextField(
                                    controller: avgRatingController,
                                    decoration: new InputDecoration(
                                        labelText: "Average rating"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (input) {
                                      if (input == '') {
                                        setState(() => minimumRating = null);
                                      }
                                      setState(() =>
                                          minimumRating = num.parse(input));
                                    },
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: RaisedButton(
                              child: Text('Clear Filters'),
                              onPressed: () => setState(() {
                                selectedAuthor = null;
                                maxPages = null;
                                minimumRating = null;
                                daysToRead = null;
                                avgRatingController.text = '';
                                maxPagesController.text = '';
                                authorController.text = '';
                                daysToReadController.text = '';
                              }),
                            ),
                          )
                        ],
                      )),
                ),
              ),
              RaisedButton(
                child: Text('Sort'),
                onPressed: () => null,
              ),
            ],
          )),
      Expanded(
          child: Container(
              child: ListView.builder(
        itemCount: books.length,
        itemBuilder: (_, index) => BookDisplay(
          book: books[index],
        ),
      )))
    ]);
  }

  List<Book> _applyFilters(List<Book> books, int avgReadingRate) {
    if (selectedAuthor != null) {
      books = books
          .where((book) =>
              book.author.toLowerCase().contains(selectedAuthor.toLowerCase()))
          .toList();
    }

    if (maxPages != null) {
      books = books
          .where((book) =>
              book.numberOfPages != null && book.numberOfPages <= maxPages)
          .toList();
    }

    if (minimumRating != null) {
      books =
          books.where((book) => book.averageRating >= minimumRating).toList();
    }

    if (daysToRead != null) {
      books = books
          .where((book) =>
              book.numberOfPages != null &&
              (book.numberOfPages / avgReadingRate).ceil() <= daysToRead)
          .toList();
    }

    return books;
  }

  bool _isFiltered() {
    return maxPages != null || selectedAuthor != null || daysToRead != null || minimumRating != null;
  }
}
