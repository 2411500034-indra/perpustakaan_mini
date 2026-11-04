import 'package:cloud_firestore/cloud_firestore.dart';
//operasional CRUD untuk data buku di Firestore
class BookModel {
  const BookModel({
    //atribut buku 
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.borrower,
    this.borrowedAt,
  });

  final String id;
  final String title;
  final String author;
  final String status;
  final String borrower;
  final DateTime? borrowedAt;

  factory BookModel.fromMap(String id, Map<String, dynamic> data) {
    return BookModel(
      id: id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      status: data['status'] as String? ?? 'Tersedia',
      borrower: data['borrower'] as String? ?? '',
      borrowedAt: switch (data['borrowedAt']) {
        Timestamp value => value.toDate(),
        DateTime value => value,
        _ => null,
      },
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'status': status,
    'borrower': borrower,
    'borrowedAt': borrowedAt == null ? null : Timestamp.fromDate(borrowedAt!),
  };
}
