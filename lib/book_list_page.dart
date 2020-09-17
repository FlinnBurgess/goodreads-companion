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
  String titleFilter;
  final TextEditingController authorController = TextEditingController();
  final TextEditingController maxPagesController = TextEditingController();
  final TextEditingController avgRatingController = TextEditingController();
  final TextEditingController daysToReadController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  BookListSortType sortBy = BookListSortType.title;
  SortDirection sortDirection = SortDirection.ascending;

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

    books = _sortBooks(books);

    books = books.toSet().toList();

    print('untouched books length: ${widget.books.length}');
    print('de-duplicated books length: ${books.length}');

    return Stack(children: [
      Padding(
          padding: EdgeInsets.only(top: 60),
          child: Container(
              child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (_, index) => BookDisplay(
              books[index],
            ),
          ))),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 1)
              ]),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    child: Text('Filter'),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _isFiltered()
                                ? Colors.amber[800]
                                : Colors.transparent,
                            width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    onPressed: () => showModalBottomSheet(
                      isScrollControlled: true,
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
                              SizedBox(
                                height: 10,
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
                                        itemBuilder: (_, match) => Center(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      top: 5, bottom: 5),
                                                  child: Text(match, textAlign: TextAlign.center,)),
                                                  Divider(),
                                            ])),
                                        onSuggestionSelected: (selected) {
                                          authorController.text = selected;
                                          setState(() {
                                            selectedAuthor = selected;
                                          });
                                        },
                                        textFieldConfiguration:
                                            TextFieldConfiguration(
                                                onChanged: (text) => setState(
                                                    () => selectedAuthor =
                                                        (text == ''
                                                            ? null
                                                            : text)),
                                                controller: authorController,
                                                decoration: InputDecoration(
                                                    labelText: 'Author',
                                                    border:
                                                        OutlineInputBorder(),
                                                    filled: true,
                                                    fillColor: Colors.white)),
                                      )),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Container(
                                      width: inputSize,
                                      child: TextField(
                                        controller: titleController,
                                        decoration: new InputDecoration(
                                            labelText: "Title",
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white),
                                        onChanged: (input) {
                                          if (input == '') {
                                            setState(() => titleFilter = null);
                                          }
                                          setState(() => titleFilter = input);
                                        },
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 10,
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
                                                  labelText: "Days to read",
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              onChanged: (input) {
                                                if (input == '') {
                                                  setState(
                                                      () => daysToRead = null);
                                                }
                                                setState(() => daysToRead =
                                                    num.parse(input));
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
                                            labelText: "Average rating",
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        onChanged: (input) {
                                          if (input == '') {
                                            setState(
                                                () => minimumRating = null);
                                          }
                                          setState(() =>
                                              minimumRating = num.parse(input));
                                        },
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: inputSize,
                                      child: TextField(
                                        controller: maxPagesController,
                                        decoration: new InputDecoration(
                                            labelText: "Max Pages",
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        onChanged: (input) {
                                          if (input == '') {
                                            setState(() => maxPages = null);
                                          }
                                          setState(() =>
                                              maxPages = num.parse(input));
                                        },
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Center(
                                    child: RaisedButton(
                                      child: Text('Clear Filters'),
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      onPressed: () => setState(() {
                                        selectedAuthor = null;
                                        maxPages = null;
                                        minimumRating = null;
                                        daysToRead = null;
                                        titleFilter = null;
                                        avgRatingController.text = '';
                                        maxPagesController.text = '';
                                        authorController.text = '';
                                        daysToReadController.text = '';
                                        titleController.text = '';
                                      }),
                                    ),
                                  ))
                            ],
                          )),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Sort'),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setModalState) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 25),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Center(
                                  child: Text(
                                    'Sort',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                Wrap(
                                  children: <Widget>[
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio(
                                            value: BookListSortType.title,
                                            groupValue: sortBy,
                                            onChanged: (value) {
                                              setState(() => sortBy = value);
                                              setModalState(
                                                  () => sortBy = value);
                                            },
                                          ),
                                          Text('Title'),
                                        ]),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio(
                                            value: BookListSortType.author,
                                            groupValue: sortBy,
                                            onChanged: (value) {
                                              setState(() => sortBy = value);
                                              setModalState(
                                                  () => sortBy = value);
                                            },
                                          ),
                                          Text('Author'),
                                        ]),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio(
                                            value:
                                                BookListSortType.numberOfPages,
                                            groupValue: sortBy,
                                            onChanged: (value) {
                                              setState(() => sortBy = value);
                                              setModalState(
                                                  () => sortBy = value);
                                            },
                                          ),
                                          Text('No. Pages'),
                                        ]),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio(
                                            value: BookListSortType.userRating,
                                            groupValue: sortBy,
                                            onChanged: (value) {
                                              setState(() => sortBy = value);
                                              setModalState(
                                                  () => sortBy = value);
                                            },
                                          ),
                                          Text('Your Rating'),
                                        ]),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio(
                                            value: BookListSortType.avgRating,
                                            groupValue: sortBy,
                                            onChanged: (value) {
                                              setState(() => sortBy = value);
                                              setModalState(
                                                  () => sortBy = value);
                                            },
                                          ),
                                          Text('Average Rating'),
                                        ]),
                                  ],
                                ),
                                Divider(
                                  thickness: 1.2,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio(
                                      value: SortDirection.ascending,
                                      groupValue: sortDirection,
                                      onChanged: (value) {
                                        setState(() => sortDirection = value);
                                        setModalState(
                                            () => sortDirection = value);
                                      },
                                    ),
                                    Text('Ascending'),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Radio(
                                      value: SortDirection.descending,
                                      groupValue: sortDirection,
                                      onChanged: (value) {
                                        setState(() => sortDirection = value);
                                        setModalState(
                                            () => sortDirection = value);
                                      },
                                    ),
                                    Text('Descending'),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              ))),
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

    if (titleFilter != null) {
      books = books
          .where((book) =>
              book.title.toLowerCase().contains(titleFilter.toLowerCase()))
          .toList();
    }

    return books;
  }

  List<Book> _sortBooks(List<Book> books) {
    switch (sortBy) {
      case BookListSortType.title:
        books.sort((book1, book2) {
          if (book1.title == null) {
            return 1;
          } else if (book2.title == null) {
            return -1;
          }

          return book1.title.compareTo(book2.title) *
              (sortDirection == SortDirection.ascending ? 1 : -1);
        });
        break;
      case BookListSortType.author:
        books.sort((book1, book2) {
          if (book1.author == null) {
            return 1;
          } else if (book2.author == null) {
            return -1;
          }

          return book1.author.compareTo(book2.author) *
              (sortDirection == SortDirection.ascending ? 1 : -1);
        });
        break;
      case BookListSortType.avgRating:
        books.sort((book1, book2) {
          if (book1.averageRating == null) {
            return 1;
          } else if (book2.averageRating == null) {
            return -1;
          }

          return book1.averageRating.compareTo(book2.averageRating) *
              (sortDirection == SortDirection.ascending ? 1 : -1);
        });
        break;
      case BookListSortType.userRating:
        books.sort((book1, book2) {
          if (book1.userRating == null) {
            return 1;
          } else if (book2.userRating == null) {
            return -1;
          }

          return book1.userRating.compareTo(book2.userRating) *
              (sortDirection == SortDirection.ascending ? 1 : -1);
        });
        break;
      case BookListSortType.numberOfPages:
        books.sort((book1, book2) {
          if (book1.numberOfPages == null) {
            return 1;
          } else if (book2.numberOfPages == null) {
            return -1;
          }

          return book1.numberOfPages.compareTo(book2.numberOfPages) *
              (sortDirection == SortDirection.ascending ? 1 : -1);
        });
        break;
    }

    return books;
  }

  bool _isFiltered() {
    return maxPages != null ||
        selectedAuthor != null ||
        daysToRead != null ||
        minimumRating != null ||
        titleFilter != null;
  }
}

enum BookListSortType { author, title, avgRating, userRating, numberOfPages }
enum SortDirection { ascending, descending }
