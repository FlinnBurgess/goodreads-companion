import 'package:flutter/material.dart';

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
                  Text(book.author)
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}
