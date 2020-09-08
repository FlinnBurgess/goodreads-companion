import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:goodreads_companion/user.dart';
import 'package:provider/provider.dart';

import 'book.dart';

class BookDisplay extends StatelessWidget {
  final Book book;

  const BookDisplay({Key key, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int avgReadingRate = Provider.of<User>(context).averageReadingRate;
    int daysToRead = avgReadingRate == null || book.numberOfPages == null
        ? null
        : (book.numberOfPages / avgReadingRate).ceil();

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Card(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                              height: 5,
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
                              height: 5,
                            ),
                            book.numberOfPages == null
                                ? null
                                : Text('Pages: ${book.numberOfPages}'),
                            daysToRead == null
                                ? null
                                : Text(
                                    'Estimated time to read: $daysToRead ${daysToRead > 1 ? 'days' : 'day'}.')
                          ].where((element) => element != null).toList(),
                        ))
                      ],
                    )
                  ])),
        ));
  }
}
