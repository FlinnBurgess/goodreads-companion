import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:goodreads_companion/shelf.dart';
import 'package:path_provider/path_provider.dart';

import 'book.dart';

class Library extends ChangeNotifier {
  Map<String, Shelf> _shelves;
  bool populationStarted = false;
  bool _readyToPopulate = false;

  Library() {
    populationStarted = false;
  }

  void addShelf(String name, int size) {
    if (_shelves == null) {
      _shelves = {};
    }

    _shelves[name] = Shelf(name, size);
    notifyListeners();
  }

  void addBooksToShelf(String shelfName, List<Book> books) {
    _shelves[shelfName].books = books;
    notifyListeners();
  }

  void updateShelfPopulationProgress(String shelfName, int increase) {
    _shelves[shelfName].populationProgress = min(_shelves[shelfName].populationProgress + 200, _shelves[shelfName].size);
    notifyListeners();
  }

  bool isPopulated() {
    if (_shelves == null) {
      return false;
    }
    return _shelves.values.where((shelf) => shelf.books == null).isEmpty;
  }

  void reset() {
    _shelves = null;
    populationStarted = false;
    _readyToPopulate = false;
    notifyListeners();
  }

  Future<void> save() async {
    try {
      final file = await _localFile;
      return file.writeAsString(jsonEncode(this.toJson()));
    } catch (e) {
      print('Error saving library: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'shelves': _shelves.map((name, shelf) => MapEntry(name, shelf.asJson()))
    };
  }

  static Future<Library> load() async {
    try {
      final file = await _localFile;
      String encodedLibrary = await file.readAsString();

      return Library.fromJson(encodedLibrary);
    } catch (error) {
      print('Something went wrong while loading your books: $error');
      return Library();
    }
  }

  Library.fromJson(String json) {
    Map<String, dynamic> decoded = jsonDecode(json);

    _shelves = Map.from(decoded['shelves'])
        .map((name, shelfJson) => MapEntry(name, Shelf.fromJson(shelfJson)));
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/library.json');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Map<String, Shelf> get shelves => _shelves;

  bool get readyToPopulate => _readyToPopulate;

  set readyToPopulate(bool value) {
    _readyToPopulate = value;
    notifyListeners();
  }
}
