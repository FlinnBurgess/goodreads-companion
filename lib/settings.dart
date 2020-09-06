import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class Settings extends ChangeNotifier {
  DateTime _lastDownloaded;

  Settings() {
    _lastDownloaded = DateTime.now();
  }

  Future<void> save() async {
    try {
      final file = await _localFile;
      return file.writeAsString(jsonEncode(this.toJson()));
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {'lastDownloaded': _lastDownloaded.toString()};
  }

  static Future<Settings> load() async {
    try {
      final file = await _localFile;
      String encodedSettings = await file.readAsString();

      return Settings.fromJson(encodedSettings);
    } catch (error) {
      print('Something went wrong while loading settings: $error');
      return Settings();
    }
  }

  Settings.fromJson(String json) {
    Map<String, dynamic> decoded = jsonDecode(json);
    _lastDownloaded = DateTime.parse(decoded['lastDownloaded']);
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/settings.json');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  DateTime get lastDownloaded => _lastDownloaded;

  set lastDownloaded(DateTime value) {
    _lastDownloaded = value;
    save();
  }
}
