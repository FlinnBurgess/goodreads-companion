import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportMePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Support Me'),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                    'Hi! Thanks for using the GR Bookshelf Companion app. If you are enjoying the app, here are some ways you can support me',
                    textAlign: TextAlign.center)),
            SizedBox(
              height: 15,
            ),
            RaisedButton(
                child: Text('Buy me a coffee'),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                onPressed: () =>
                    launch('https://www.buymeacoffee.com/flinnburgess')),
            SizedBox(
              height: 15,
            ),
            RaisedButton(
                child: Text('Rate the app'),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                onPressed: () => launch(
                    'https://play.google.com/store/apps/details?id=com.flinnburgess.goodreads_companion')),
            SizedBox(
              height: 15,
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                    'You can also support me by buying books from your shelves using the store buttons listed. Any purchases made using these links will result in a small amount of commission for me.',
                    textAlign: TextAlign.center)),
            SizedBox(
              height: 15,
            ),Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                    'If you spot any bugs or have suggestions for how I can improve the app, feel free to contact me at flinn@thetimelydeveloper.com',
                    textAlign: TextAlign.center)),
          ],
        ))));
  }
}
