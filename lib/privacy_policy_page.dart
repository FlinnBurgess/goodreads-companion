import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'In downloading data about your Goodreads books and shelves, this app will store some personal information such as your book ratings and user ID.'),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'If this data is not publicly available then the app will only be able to access and store the information with your express consent.'),
                  SizedBox(
                    height: 5,
                  ),
                  Text('This information is not shared or used anywhere outside of this app.'),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Goodreads Access',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'In order to use some features of the app you may be asked to log in to Goodreads. This app does not record or store any of your login details.'),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'After logging in, Goodreads provides the app with a token that gives it permission to perform Goodreads actions on your behalf.'),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'You can revoke this access at any point through the account settings page of the Goodreads website.'),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Internet Permissions',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'This app requires internet access in order to download shelf data and perform any account actions necessary to the functionality of the app.'),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Affiliate Marketing',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      'This app uses affiliate marketing. This means that if you click one of the store buttons to buy a book, then the corresponding store will track you and associate your purchase with this app.'),
                ],
              ))),
    );
  }
}
