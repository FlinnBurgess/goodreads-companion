import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class Settings extends ChangeNotifier {
  DateTime _lastDownloaded;
  bool _lowDataMode = false;
  bool _excludeBooksReadInASingleDayFromStats = false;
  bool _userHasSelectedACountry = false;
  String _selectedCountry = 'US';
  bool _showAmazonLink = true;
  bool _showAudibleLink = true;
  bool _showGoogleBooksLink = true;
  bool _showBookDepositoryLink = true;

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
    return {
      'lastDownloaded': _lastDownloaded.toString(),
      'selectedCountry': _selectedCountry,
      'userHasSelectedCountry': _userHasSelectedACountry,
      'excludeBooksReadInASingleDayFromStats':
          _excludeBooksReadInASingleDayFromStats,
      'showAmazonLink': _showAmazonLink,
      'showAudibleLink': _showAudibleLink,
      'showGoogleBooksLink': _showGoogleBooksLink,
      'showBookDepositoryLink': _showBookDepositoryLink
    };
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
    _selectedCountry = decoded['selectedCountry'];
    _userHasSelectedACountry = decoded['userHasSelectedCountry'];
    _excludeBooksReadInASingleDayFromStats =
        decoded['excludeBooksReadInASingleDayFromStats'];
    _showAmazonLink = decoded['showAmazonLink'];
    _showAudibleLink = decoded['showAudibleLink'];
    _showGoogleBooksLink = decoded['showGoogleBooksLink'];
    _showBookDepositoryLink = decoded['showBookDepositoryLink'];
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

  String get selectedCountry => _selectedCountry;

  set selectedCountry(String value) {
    _userHasSelectedACountry = true;
    _selectedCountry = value;
    notifyListeners();
    save();
  }

  bool get excludeBooksReadInASingleDayFromStats =>
      _excludeBooksReadInASingleDayFromStats;

  set excludeBooksReadInASingleDayFromStats(bool value) {
    _excludeBooksReadInASingleDayFromStats = value;
    notifyListeners();
    save();
  }

  bool get showBookDepositoryLink => _showBookDepositoryLink;

  set showBookDepositoryLink(bool value) {
    _showBookDepositoryLink = value;
    notifyListeners();
    save();
  }

  bool get showGoogleBooksLink => _showGoogleBooksLink;

  set showGoogleBooksLink(bool value) {
    _showGoogleBooksLink = value;
    notifyListeners();
    save();
  }

  bool get showAudibleLink => _showAudibleLink;

  set showAudibleLink(bool value) {
    _showAudibleLink = value;
    notifyListeners();
    save();
  }

  bool get showAmazonLink => _showAmazonLink;

  set showAmazonLink(bool value) {
    _showAmazonLink = value;
    notifyListeners();
    save();
  }
}
