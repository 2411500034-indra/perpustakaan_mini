class ApiBookModel {
  const ApiBookModel({
    required this.title,
    required this.authors,
    this.coverUrl,
    this.description,
  });

  final String title;
  final List<String> authors;
  final String? coverUrl;
  final String? description;

  factory ApiBookModel.fromJson(Map<String, dynamic> json) {
    final authorsJson = json['authors'];
    final authors = authorsJson is List
        ? authorsJson
            .whereType<Map<String, dynamic>>()
            .map((author) => author['name'])
            .whereType<String>()
            .toList()
        : <String>[];

    final coverId = json['cover_id'];
    final descriptionJson = json['description'];
    final description = switch (descriptionJson) {
      String value => value,
      Map<String, dynamic> value when value['value'] is String =>
        value['value'] as String,
      _ => null,
    };

    return ApiBookModel(
      title: json['title'] as String? ?? 'Untitled',
      authors: authors,
      coverUrl: coverId is int
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : null,
      description: description,
    );
  }
}
