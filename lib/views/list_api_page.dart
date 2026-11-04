import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_book_model.dart';
import '../providers/api_book_provider.dart';
import 'detail_api_page.dart';

class ListApiPage extends StatefulWidget {
  const ListApiPage({super.key});

  @override
  State<ListApiPage> createState() => _ListApiPageState();
}

class _ListApiPageState extends State<ListApiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ApiBookProvider>().fetchApiBooks();
    });
  }

  Future<void> _openDetails(ApiBookModel book) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailApiPage(book: book),
      ),
    );
  }

//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Referensi')),
      body: Consumer<ApiBookProvider>(
        builder: (context, provider, _) {
          switch (provider.state) {
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat katalog'
                        '${provider.error == null ? '.' : ': ${provider.error}'}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: provider.fetchApiBooks,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            case ViewState.empty:
              return const Center(
                child: Text('Belum ada buku untuk ditampilkan.'),
              );
            case ViewState.loaded:
              if (provider.books.isEmpty) {
                return const Center(
                  child: Text('Belum ada buku untuk ditampilkan.'),
                );
              }
              return RefreshIndicator(
                onRefresh: provider.fetchApiBooks,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisExtent: 300,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: provider.books.length,
                  itemBuilder: (context, index) {
                    final book = provider.books[index];
                    return _ApiBookCard(
                      book: book,
                      onTap: () => _openDetails(book),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _ApiBookCard extends StatelessWidget {
  const _ApiBookCard({required this.book, required this.onTap});

  final ApiBookModel book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final authors = book.authors.isEmpty
        ? 'Penulis tidak diketahui'
        : book.authors.join(', ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: book.coverUrl == null
                  ? const _CoverPlaceholder()
                  : Image.network(
                      book.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _CoverPlaceholder(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authors,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.menu_book, size: 56)),
    );
  }
}
