import 'package:flutter/material.dart';
import 'package:goodreads_companion/authentication.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  String authenticationErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<Authentication>(
      builder: (context, authentication, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goodreads Companion'),
          ),
          body: Center(
            child: Column(
              children: [
                Text('In order to access your books'),
                RaisedButton(
                  onPressed: () {
                    _authenticateUser(authentication);
                  },
                  child: Text('Log in to Goodreads'),
                ),
                RaisedButton(
                  onPressed: () {
                    var authenticationErrorResponse = () => setState(() {
                          authenticationErrorMessage =
                              'Something went wrong! Make sure that you entered your username and password while logging in; opening the app isn\'t enough on its own.\nAlternatively, you can make your goodreads account public in the settings in order to skip this step.';
                        });

                    _getAccessToken(
                        authentication, authenticationErrorResponse);
                  },
                  child: Text('Done'),
                ),
                authenticationErrorMessage == null
                    ? Container()
                    : Text(
                        authenticationErrorMessage,
                        style: TextStyle(color: Colors.red),
                      )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _authenticateUser(Authentication authentication) async {
    Authentication.authorization
        .requestTemporaryCredentials('oob')
        .then((res) async {
      authentication.temporaryCredentials = res.credentials;

      var url =
          '${Authentication.authorization.getResourceOwnerAuthorizationURI(res.credentials.token)}&mobile=1';

      launch(url, forceWebView: true);
    });
  }

  Future<void> _getAccessToken(
      Authentication authentication, Function onError) async {
    Authentication.authorization
        .requestTokenCredentials(authentication.temporaryCredentials, '1')
        .then((response) {
      authentication.accessCredentials = response.credentials;
      authentication.needsAuthentication = false;
    }).catchError((error) {
      onError();
    });
  }
}
