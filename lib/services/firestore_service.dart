import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book_model.dart';

class FirestoreService {
  //operasional CRUD untuk data buku di Firestore
  FirestoreService({FirebaseFirestore? firestore})
    : _booksCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'books',
      );
  //Layanan Firestore menggunakan CollectionReference untuk operasi CRUD
  final CollectionReference<Map<String, dynamic>> _booksCollection;

  Future<void> addBook(BookModel book) async {
    await _booksCollection.add(book.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBooksStream() {
    return _booksCollection.snapshots();
  }

  Future<void> updateBook(BookModel book) async {
    await _booksCollection.doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String id) async {
    await _booksCollection.doc(id).delete();
  }
}
