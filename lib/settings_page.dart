import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:goodreads_companion/library.dart';
import 'package:goodreads_companion/settings.dart';
import 'package:provider/provider.dart';

import 'user.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<User, Library, Settings>(
      builder: (context, user, library, settings, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text('Current user: ${user.userId}'),
                  RaisedButton(
                    child: Text('Change user'),
                    onPressed: () =>
                        _confirmUserIdChange(context, user, library),
                  )
                ],
              ),
              Row(
                children: [
                  Text('Select your country: '),
                  CountryCodePicker(
                    onChanged: (selected) =>
                        settings.selectedCountry = selected.code,
                    initialSelection: settings.selectedCountry,
                    favorite: ['GB', 'US'],
                    showCountryOnly: true,
                    showOnlyCountryWhenClosed: true,
                  )
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: settings.excludeBooksReadInASingleDayFromStats,
                    onChanged: (value) =>
                        settings.excludeBooksReadInASingleDayFromStats = value,
                  ),
                  Text(
                      'Exclude books read in a single day from your statistics? This setting provides more accurate statistics if you know you have misentered reading dates.'),
                ],
              ),
              Text('Store buttons to show'),
              Row(
                children: [
                  Checkbox(
                    value: settings.showAmazonLink,
                    onChanged: (value) => settings.showAmazonLink = value,
                  ),
                  Text('Amazon'),
                  Checkbox(
                    value: settings.showAudibleLink,
                    onChanged: (value) => settings.showAudibleLink = value,
                  ),
                  Text('Audible'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: settings.showGoogleBooksLink,
                    onChanged: (value) => settings.showGoogleBooksLink = value,
                  ),
                  Text('Google Books'),
                  Checkbox(
                    value: settings.showBookDepositoryLink,
                    onChanged: (value) => settings.showBookDepositoryLink = value,
                  ),
                  Text('Book Depository'),
                ],
              ),
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
