import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodreads_companion/user.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';

import 'authentication.dart';

class UserIDInputPage extends StatefulWidget {
  final String userIdInputError;

  UserIDInputPage(this.userIdInputError);

  @override
  _UserIDInputPageState createState() => _UserIDInputPageState();
}

class _UserIDInputPageState extends State<UserIDInputPage> {
  String userIdInput;
  String userIdInputError;
  Widget userCheckResultMessage;

  @override
  void initState() {
    userIdInputError = widget.userIdInputError;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<User, Authentication>(
      builder: (context, user, authentication, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goodreads Companion'),
          ),
          body: Center(
            child: Column(
              children: [
                Text('Enter your goodreads ID'),
                Text(
                    'This is the number shown in the URL of the goodreads website when you click on "My Books"'),
                Row(children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        decoration:
                            new InputDecoration(labelText: "Goodreads ID"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (input) {
                          if (input.replaceAll(' ', '') == '') {
                            setState(() => userIdInput = null);
                          }
                          setState(() => userIdInput = input);
                        },
                      )),
                  RaisedButton(
                    child: Text('Check ID'),
                    onPressed: () {
                      setState(() {
                        userCheckResultMessage = null;
                      });

                      if (userIdInput == null ||
                          userIdInput.replaceAll(' ', '') == '') {
                        return;
                      }

                      userCheckResultMessage = CircularProgressIndicator();

                      get('https://www.goodreads.com/user/show/$userIdInput.xml?key=${Authentication.API_KEY}')
                          .then((response) {
                        if (response.statusCode == 404) {
                          setState(() {
                            userCheckResultMessage = Text(
                              'User does not exist',
                              style: TextStyle(color: Colors.red),
                            );
                          });
                        } else {
                          var xml = XmlDocument.parse(response.body);
                          var name = xml
                              .getElement('GoodreadsResponse')
                              .getElement('user')
                              .getElement('name')
                              .text;
                          var private = xml
                              .getElement('GoodreadsResponse')
                              .getElement('user')
                              .getElement('private');
                          var imageUrl = xml
                              .getElement('GoodreadsResponse')
                              .getElement('user')
                              .getElement('image_url')
                              .text;

                          setState(() {
                            userCheckResultMessage = Row(children: [
                              Text(
                                '$name (${private == null ? 'public' : 'private'})',
                                style: TextStyle(color: Colors.green),
                              ),
                              Image.network(imageUrl)
                            ]);
                          });
                        }
                      });
                    },
                  )
                ]),
                userCheckResultMessage == null
                    ? Container()
                    : userCheckResultMessage,
                RaisedButton(
                  onPressed: () {
                    setState(() {
                      userIdInputError = null;
                    });
                    if (userIdInput == null ||
                        userIdInput.replaceAll(' ', '') == '') {
                      setState(() {
                        userIdInputError = 'Please enter a user ID';
                      });
                    } else {
                      get('https://www.goodreads.com/shelf/list.xml?key=${Authentication.API_KEY}&user_id=$userIdInput}')
                          .then((response) {
                        if (response.statusCode == 404) {
                          setState(() {
                            userIdInputError =
                                'User $userIdInput doesn\'t seem to exist! Double check that you entered the correct ID.';
                          });
                        } else {
                          authentication.needsAuthentication = false;
                          user.userId = userIdInput;
                        }
                      });
                    }
                  },
                  child: Text('Save'),
                ),
                userIdInputError == null
                    ? Container()
                    : Text(
                        userIdInputError,
                        style: TextStyle(color: Colors.red),
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}
