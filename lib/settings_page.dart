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
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current User', style: TextStyle(fontSize: 20),),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text('${user.userId}'),
                      SizedBox(
                        width: 10,
                      ),
                      RaisedButton(
                        child: Text('Change user'),
                        onPressed: () =>
                            _confirmUserIdChange(context, user, library),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                      )
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider()),
                  Text('Country', style: TextStyle(fontSize: 20),),
                  SizedBox(height: 10,),
                  CountryCodePicker(
                    onChanged: (selected) =>
                        settings.selectedCountry = selected.code,
                    initialSelection: settings.selectedCountry,
                    favorite: ['GB', 'US'],
                    showCountryOnly: true,
                    showOnlyCountryWhenClosed: true,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider()),
                  Text('Store buttons to show', style: TextStyle(fontSize: 20),),
                  SizedBox(height: 10,),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: settings.showAmazonLink,
                            onChanged: (value) =>
                                settings.showAmazonLink = value,
                          ),
                          Text('Amazon'),
                        ],
                      )),
                      SizedBox(
                        width: 40,
                      ),
                      Container(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: settings.showAudibleLink,
                            onChanged: (value) =>
                                settings.showAudibleLink = value,
                          ),
                          Text('Audible'),
                        ],
                      )),
                      SizedBox(
                        width: 40,
                      ),
                      Container(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: settings.showGoogleBooksLink,
                            onChanged: (value) =>
                                settings.showGoogleBooksLink = value,
                          ),
                          Text('Google Books'),
                        ],
                      )),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: settings.showBookDepositoryLink,
                            onChanged: (value) =>
                                settings.showBookDepositoryLink = value,
                          ),
                          Text('Book Depository'),
                        ],
                      )),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider()),
                  Text('Other Settings', style: TextStyle(fontSize: 20),),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Checkbox(
                        value: settings.excludeBooksReadInASingleDayFromStats,
                        onChanged: (value) => settings
                            .excludeBooksReadInASingleDayFromStats = value,
                      ),
                      Flexible(
                          child: Text(
                        'Exclude books read in a single day from your statistics? (Misentered dates may make your calculated reading rate less accurate)',
                      )),
                    ],
                  ),
                ],
              )),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
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
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
              ],
            ));
  }
}
