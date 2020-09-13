import 'package:flutter/material.dart';
import 'package:goodreads_companion/library.dart';
import 'package:goodreads_companion/settings.dart';
import 'package:goodreads_companion/user.dart';
import 'package:provider/provider.dart';

class DataRefreshPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<Settings, Library, User>(
      builder: (context, settings, library, user, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Refresh Data'),
          ),
          body: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Due to Goodreads policy, the app is not able to store data for more than 24 hours.', textAlign: TextAlign.center,),
                      SizedBox(height: 10,),
                      Text(
                          'To continue using the app, please refresh your book data.', textAlign: TextAlign.center,),
                      SizedBox(height: 10,),
                      RaisedButton(
                        child: Text('Refresh Data'),
                        onPressed: () {
                          settings.lastDownloaded = DateTime.now();
                          library.reset();
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(90))),
                      ),
                      SizedBox(height: 60,),
                      Text(
                          'This is also a good opportunity to switch to a different user ID.', textAlign: TextAlign.center,),
                      SizedBox(height: 10,),
                      RaisedButton(
                        child: Text('Change User'),
                        onPressed: () {
                          settings.lastDownloaded = DateTime.now();
                          user.reset();
                          library.reset();
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(90))),
                      )
                    ],
                  ))),
        );
      },
    );
  }
}
