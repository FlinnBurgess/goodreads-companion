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
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: Column(
                      children: [
                        Text(
                          'The account of the ID you entered is set to private, please log in to your Goodreads account to continue.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            _authenticateUser(authentication);
                          },
                          child: Text('Log in to Goodreads'),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                        ),
                        SizedBox(height: 20,),
                        RaisedButton(
                          onPressed: () {
                            var authenticationErrorResponse =
                                () => setState(() {
                                      authenticationErrorMessage =
                                          'Something went wrong! Make sure that you entered your username and password while logging in; opening the app isn\'t enough on its own.\nAlternatively, you can make your goodreads account public in the settings in order to skip this step.';
                                    });

                            _getAccessToken(
                                authentication, authenticationErrorResponse);
                          },
                          child: Text('Done'),
                          color: Colors.greenAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                        ),
                        authenticationErrorMessage == null ? null : SizedBox(height: 20,),
                        authenticationErrorMessage == null
                            ? null
                            : Text(
                                authenticationErrorMessage,
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              )
                      ].where((element) => element != null).toList(),
                    ))),
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
