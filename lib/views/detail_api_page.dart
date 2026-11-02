import 'package:flutter/material.dart';

import '../models/api_book_model.dart';

class DetailApiPage extends StatelessWidget {
  const DetailApiPage({required this.book, super.key});

  final ApiBookModel book;

  @override
  Widget build(BuildContext context) {
    final authors = book.authors.isEmpty
        ? 'Penulis tidak diketahui'
        : book.authors.join(', ');
    final description = book.description?.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 200,
                height: 280,
                child: book.coverUrl == null
                    ? const _DetailCoverPlaceholder()
                    : Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const _DetailCoverPlaceholder(),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            authors,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            description == null || description.isEmpty
                ? 'Deskripsi belum tersedia.'
                : description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _DetailCoverPlaceholder extends StatelessWidget {
  const _DetailCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.menu_book, size: 72)),
    );
  }
}
