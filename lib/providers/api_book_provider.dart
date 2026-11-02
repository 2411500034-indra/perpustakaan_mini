import 'package:flutter/foundation.dart';

import '../models/api_book_model.dart';
import '../services/api_service.dart';

enum ViewState { loading, loaded, error, empty }

class ApiBookProvider extends ChangeNotifier {
  ApiBookProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<ApiBookModel> books = [];
  ViewState state = ViewState.empty;
  Object? error;

  Future<void> fetchApiBooks() async {
    state = ViewState.loading;
    error = null;
    notifyListeners();

    try {
      books = await _apiService.fetchBooks();
      state = books.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (exception) {
      error = exception;
      state = ViewState.error;
    }

    notifyListeners();
  }
}
