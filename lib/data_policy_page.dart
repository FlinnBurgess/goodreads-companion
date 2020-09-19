import 'package:flutter/material.dart';

class DataPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Policy'),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Data',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                  'The only personal data that this app stores are user preferences/settings, and information about your Goodreads books such as ratings.'),
              SizedBox(
                height: 5,
              ),
              Text(
                  'This data is stored locally on your device only and not shared externally.'),
              SizedBox(
                height: 20,
              ),
              Text(
                'Goodreads Data',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                  'This app downloads data about your Goodreads books and shelves.'),
              SizedBox(
                height: 5,
              ),
              Text('As per the Goodreads data policy, this information cannot be stored for longer than 24 hours.'),
              SizedBox(
                height: 5,
              ),
              Text(
                  'In order to adhere to the Goodreads policy, this app will become inaccessible 24 hours after downloading your book data, until you have refreshed the information.')
            ],
          )),
    );
  }
}
