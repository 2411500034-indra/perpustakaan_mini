import 'package:dio/dio.dart';

import '../models/api_book_model.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<ApiBookModel>> fetchBooks() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://openlibrary.org/subjects/fiction.json?limit=15',
    );
    final works = response.data?['works'];

    if (works is! List) {
      throw const FormatException('Invalid response: expected a works list.');
    }

    return works
        .whereType<Map<String, dynamic>>()
        .map(ApiBookModel.fromJson)
        .toList();
  }
}
