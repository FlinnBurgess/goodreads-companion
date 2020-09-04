import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class User extends ChangeNotifier {
  bool _needsAuthentication = false;
  String _userId;

  User();

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
      'needsAuthentication': _needsAuthentication,
      'userId': _userId
    };
  }

  static Future<User> load() async {
    try {
      final file = await _localFile;
      String encodedUser = await file.readAsString();

      return User.fromJson(encodedUser);
    } catch (error) {
      print('Something went wrong while loading user info: $error');
      return User();
    }
  }

  User.fromJson(String json) {
    Map<String, dynamic> decoded = jsonDecode(json);

    _needsAuthentication = decoded['needsAuthentication'];
    _userId = decoded['userId'];
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/user.json');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
    save();
    notifyListeners();
  }

  bool get needsAuthentication => _needsAuthentication;

  set needsAuthentication(bool value) {
    _needsAuthentication = value;
    notifyListeners();
  }
}
