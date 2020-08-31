import 'book.dart';

class Shelf {
  int size;
  String name;
  List<Book> books;

  Shelf(this.name, this.size);

  Shelf.fromJson(Map json) {
    size = json['size'];
    name = json['name'];
    books = List<Map>.from(json['books'])
        .map((bookJson) => Book.fromJson(bookJson))
        .toList();
  }

  Map<String, dynamic> asJson() {
    return {
      'name': name,
      'size': size,
      'books': books.map((book) => book.asJson()).toList()
    };
  }
}
