import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../services/firestore_service.dart';

//Provider ini menerapkan pola ViewState. Statusnya berubah dari loading saat mengambil stream,
// menjadi loaded saat ada data, empty jika dokumen kosong, atau error jika terjadi kegagalan.
// Di akhir class, subscription stream di-dispose secara tepat
enum BookViewState { loading, loaded, error }

class BookProvider extends ChangeNotifier {
  BookProvider({
    FirebaseFirestore? firestore,
    FirestoreService? firestoreService,
    FirebaseAuth? firebaseAuth,
  }) : _firestoreService =
           firestoreService ?? FirestoreService(firestore: firestore),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _authSubscription = _firebaseAuth.authStateChanges().listen(
      (user) {
        if (user == null) {
          clearData();
        } else {
          fetchBooksStream();
        }
      },
      onError: (Object exception) {
        if (_isDisposed) return;
        error = exception;
        state = BookViewState.error;
        notifyListeners();
      },
    );
    fetchBooksStream();
  }

  final FirestoreService _firestoreService;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isDisposed = false;
  int _streamGeneration = 0;
  String? _activeUserId;
  //menggunakan query Firestore snapshots()
  //Proses pengurutan (sorting) dilakukan manual di
  //sisi client Dart menggunakan method .sort pada list buku berdasarkan borrowedAt
  List<BookModel> books = [];
  BookViewState state = BookViewState.loading;
  Object? error;

  void clearData() {
    if (_isDisposed) return;
    _streamGeneration++;
    _subscription?.cancel();
    _subscription = null;
    _activeUserId = null;
    books.clear();
    error = null;
    state = BookViewState.loading;
    notifyListeners();
  }

  void fetchBooksStream() {
    if (_firebaseAuth.currentUser == null) {
      clearData();
      return;
    }

    final userId = _firebaseAuth.currentUser!.uid;
    if (_activeUserId == userId && _subscription != null) return;

    _streamGeneration++;
    final generation = _streamGeneration;
    _subscription?.cancel();
    _activeUserId = userId;
    books.clear();
    error = null;
    state = BookViewState.loading;
    notifyListeners();

    _subscription = _firestoreService.getBooksStream().listen(
      (snapshot) {
        if (_isDisposed || generation != _streamGeneration) return;
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
        if (_isDisposed || generation != _streamGeneration) return;
        error = exception;
        state = BookViewState.error;
        notifyListeners();
      },
    );
  }

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
    _isDisposed = true;
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
