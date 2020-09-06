import 'package:flutter/material.dart';
import 'package:goodreads_companion/library.dart';
import 'package:provider/provider.dart';

import 'user.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<User, Library>(
      builder: (context, user, library, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text('Current user: ${user.userId}'),
                  RaisedButton(
                    child: Text('Change user'),
                    onPressed: () => _confirmUserIdChange(context, user, library),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _confirmUserIdChange(BuildContext context, User user, Library library) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Are you sure?'),
              content: Text(
                  'Changing user will delete all of the currently saved books data.\nYou will have to download new book data every time you switch.'),
              actions: [
                RaisedButton(
                  color: Colors.red,
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                RaisedButton(
                  child: Text('Change User'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    user.reset();
                    library.reset();
                  },
                ),
              ],
            ));
  }
}
