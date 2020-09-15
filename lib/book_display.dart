import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:goodreads_companion/user.dart';
import 'package:provider/provider.dart';

import 'book.dart';
import 'settings.dart';

class BookDisplay extends StatelessWidget {
  final Book book;

  const BookDisplay(this.book, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Settings, User>(
      builder: (context, settings, user, _) {
        int avgReadingRate = user.averageReadingRate;
        int daysToRead = avgReadingRate == null || book.numberOfPages == null
            ? null
            : (book.numberOfPages / avgReadingRate).ceil();

        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Card(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(book.imageUrl),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  book.author,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RatingBarIndicator(
                                  rating: book.averageRating,
                                  itemBuilder: (_, __) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                book.numberOfPages == null
                                    ? null
                                    : Text('${book.numberOfPages} pages'),
                                SizedBox(height: 5,),
                                daysToRead == null
                                    ? null
                                    : Text(
                                        'Estimated time to read: $daysToRead ${daysToRead > 1 ? 'days' : 'day'}.')
                              ].where((element) => element != null).toList(),
                            ))
                          ],
                        ),
                        settings.showBookDepositoryLink ||
                                settings.showGoogleBooksLink ||
                                settings.showAudibleLink ||
                                settings.showAmazonLink
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'Buy this book:',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ))
                            : null,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            settings.showAmazonLink
                                ? RaisedButton(
                                    child: Text('Amazon'),
                                    onPressed: () => null,
                                  )
                                : null,
                            settings.showAudibleLink
                                ? RaisedButton(
                                    child: Text('Audible'),
                                    onPressed: () => null,
                                  )
                                : null,
                          ].where((element) => element != null).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            settings.showGoogleBooksLink
                                ? RaisedButton(
                                    child: Text('Google Books'),
                                    onPressed: () => null,
                                  )
                                : null,
                            settings.showBookDepositoryLink
                                ? RaisedButton(
                                    child: Text('Book Depository'),
                                    onPressed: () => null,
                                  )
                                : null,
                          ].where((element) => element != null).toList(),
                        )
                      ].where((element) => element != null).toList())),
            ));
      },
    );
  }
}
