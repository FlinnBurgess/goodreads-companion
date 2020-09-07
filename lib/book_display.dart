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

    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Image.network(book.imageUrl),
              Flexible(
                  child: Column(
                children: [
                  Text(
                    book.title,
                    textAlign: TextAlign.start,
                  ),
                  Text(book.author),
                  Row(
                    children: [
                      Text('Avg Rating'),
                      RatingBarIndicator(
                        rating: book.averageRating,
                        itemBuilder: (_, __) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                      )
                    ],
                  ),
                  book.numberOfPages == null ? null : Text('Number of pages: ${book.numberOfPages}'),
                  daysToRead == null
                      ? null
                      : Text(
                          'Estimated time to read: $daysToRead ${daysToRead > 1 ? 'days' : 'day'}.')
                ].where((element) => element != null).toList(),
              ))
            ],
          ),
        ],
      ),
    );
  }
}
