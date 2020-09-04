import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:oauth1/oauth1.dart';
import 'package:path_provider/path_provider.dart';

class Authentication extends ChangeNotifier {
  bool _needsAuthentication = false;
  Credentials _temporaryCredentials;
  Credentials _accessCredentials;

  static Platform platform = Platform(
      'https://www.goodreads.com/oauth/request_token',
      'https://www.goodreads.com/oauth/authorize',
      'https://www.goodreads.com/oauth/access_token',
      SignatureMethods.hmacSha1);
  static ClientCredentials clientCredentials = ClientCredentials(
      'f4gRbjUEvwrshiwBhwQ', 'mc7GsVj8cjOgwKkREkbKwQwR0eqeRtO0hBhs3LgC8');

  static Authorization authorization =
      Authorization(clientCredentials, platform);

  Authentication();

  Future<void> save() async {
    try {
      final file = await _localFile;
      return file.writeAsString(jsonEncode(this.toJson()));
    } catch (e) {
      print('Error saving authentication details: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'needsAuthentication': _needsAuthentication,
      'accessCredentials': _accessCredentials.toJSON()
    };
  }

  static Future<Authentication> load() async {
    try {
      final file = await _localFile;
      String encodedAuth = await file.readAsString();

      return Authentication.fromJson(encodedAuth);
    } catch (error) {
      print('Something went wrong while loading authentication info: $error');
      return Authentication();
    }
  }

  Authentication.fromJson(String json) {
    Map<String, dynamic> decoded = jsonDecode(json);

    _needsAuthentication = decoded['needsAuthentication'];
    _accessCredentials = Credentials.fromMap(
        Map<String, String>.from(decoded['accessCredentials']));
  }

  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/authentication.json');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  bool get needsAuthentication => _needsAuthentication;

  set needsAuthentication(bool value) {
    _needsAuthentication = value;
    notifyListeners();
  }

  Credentials get accessCredentials => _accessCredentials;

  set accessCredentials(Credentials value) {
    print('Saving acceess credntials');
    _accessCredentials = value;
    notifyListeners();
    save();
  }

  Credentials get temporaryCredentials => _temporaryCredentials;

  set temporaryCredentials(Credentials value) {
    _temporaryCredentials = value;
    notifyListeners();
  }
}
