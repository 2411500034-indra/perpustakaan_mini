import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';

class HomeCrudPage extends StatelessWidget {
  const HomeCrudPage({super.key});

  Future<void> _showBookForm(BuildContext context, {BookModel? book}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    final borrowerController = TextEditingController(
      text: book?.borrower ?? '',
    );
    var status = book?.status ?? 'Tersedia';
    var isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              setSheetState(() => isSaving = true);
              final updatedBook = BookModel(
                id: book?.id ?? '',
                title: titleController.text.trim(),
                author: authorController.text.trim(),
                status: status,
                borrower: status == 'Dipinjam'
                    ? borrowerController.text.trim()
                    : '',
                borrowedAt: status == 'Dipinjam'
                    ? book?.borrowedAt ?? DateTime.now()
                    : null,
              );

              try {
                final bookProvider = context.read<BookProvider>();
                if (book == null) {
                  await bookProvider.addBook(updatedBook);
                } else {
                  await bookProvider.updateBook(updatedBook);
                }
                if (context.mounted) Navigator.of(context).pop();
              } catch (exception) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menyimpan buku: $exception')),
                );
                setSheetState(() => isSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        book == null ? 'Tambah Buku' : 'Edit Buku',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          border: OutlineInputBorder(),
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: authorController,
                        decoration: const InputDecoration(
                          labelText: 'Penulis',
                          border: OutlineInputBorder(),
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Tersedia',
                            child: Text('Tersedia'),
                          ),
                          DropdownMenuItem(
                            value: 'Dipinjam',
                            child: Text('Dipinjam'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setSheetState(() => status = value);
                          }
                        },
                      ),
                      if (status == 'Dipinjam') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: borrowerController,
                          decoration: const InputDecoration(
                            labelText: 'Peminjam',
                            border: OutlineInputBorder(),
                          ),
                          validator: _requiredValidator,
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: isSaving ? null : save,
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                book == null ? 'Simpan' : 'Simpan Perubahan',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    authorController.dispose();
    borrowerController.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bagian ini wajib diisi.';
    return null;
  }

  Future<void> _confirmDelete(BuildContext context, BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus buku?'),
        content: Text('Buku "${book.title}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<BookProvider>().deleteBook(book.id);
    } catch (exception) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus buku: $exception')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan Mini'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              try {
                context.read<BookProvider>().clearData();
                await context.read<AuthProvider>().logout();
              } catch (exception) {
                if (!context.mounted) return;
                context.read<BookProvider>().fetchBooksStream();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal logout: $exception')),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          if (provider.state == BookViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == BookViewState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat buku: ${provider.error}'),
              ),
            );
          }
          if (provider.books.isEmpty) {
            return const Center(
              child: Text('Belum ada buku. Tambahkan buku untuk memulai.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.books.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final book = provider.books[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      book.status == 'Tersedia'
                          ? Icons.menu_book
                          : Icons.bookmark_added,
                    ),
                  ),
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author}\n${book.status}'
                    '${book.borrower.isEmpty ? '' : ' • ${book.borrower}'}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showBookForm(context, book: book);
                      } else if (action == 'delete') {
                        _confirmDelete(context, book);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
      ),
    );
  }
}
