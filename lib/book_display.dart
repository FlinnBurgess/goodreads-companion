import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'book.dart';

class BookDisplay extends StatelessWidget {
  final Book book;

  const BookDisplay({Key key, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Text('Number of pages: ${book.numberOfPages}'),
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}
