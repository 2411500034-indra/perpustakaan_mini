import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../services/firestore_service.dart';

enum BookViewState { loading, loaded, error }

class BookProvider extends ChangeNotifier {
  BookProvider({
    FirebaseFirestore? firestore,
    FirestoreService? firestoreService,
  }) : _firestoreService =
           firestoreService ?? FirestoreService(firestore: firestore) {
    _subscription = _firestoreService.getBooksStream().listen(
      (snapshot) {
        final loadedBooks = snapshot.docs
            .map((document) => BookModel.fromMap(document.id, document.data()))
            .toList();
        loadedBooks.sort((first, second) {
          final firstBorrowedAt = first.borrowedAt;
          final secondBorrowedAt = second.borrowedAt;
          if (firstBorrowedAt == null) {
            return secondBorrowedAt == null ? 0 : 1;
          }
          if (secondBorrowedAt == null) return -1;
          return firstBorrowedAt.compareTo(secondBorrowedAt);
        });
        books = loadedBooks;
        state = BookViewState.loaded;
        error = null;
        notifyListeners();
      },
      onError: (Object exception) {
        error = exception;
        state = BookViewState.error;
        notifyListeners();
      },
    );
  }

  final FirestoreService _firestoreService;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<BookModel> books = [];
  BookViewState state = BookViewState.loading;
  Object? error;

  Future<void> addBook(BookModel book) async {
    await _firestoreService.addBook(book);
  }

  Future<void> updateBook(BookModel book) async {
    await _firestoreService.updateBook(book);
  }

  Future<void> deleteBook(String id) async {
    await _firestoreService.deleteBook(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
