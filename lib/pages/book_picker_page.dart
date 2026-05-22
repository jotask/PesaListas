import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/pages/book_isbn_scanner_page.dart';
import 'package:pesalistas/repositories/book_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookPickerPage extends StatefulWidget {
  const BookPickerPage({super.key});

  @override
  State<BookPickerPage> createState() => _BookPickerPageState();
}

class _BookPickerPageState extends State<BookPickerPage> {
  late final BookRepository bookRepository;

  final searchController = TextEditingController();

  Timer? searchDebounce;

  String query = '';
  List<Map<String, dynamic>> results = [];

  bool searching = false;
  bool selecting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    bookRepository = BookRepository(Supabase.instance.client);
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();

    super.dispose();
  }

  Future<void> searchBooks() async {
    final searchText = query.trim();

    searchDebounce?.cancel();

    if (searchText.isEmpty) {
      setState(() {
        results = [];
        errorMessage = null;
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      searching = true;
      errorMessage = null;
    });

    try {
      final books = await bookRepository.searchBooks(searchText);

      if (!mounted) return;

      setState(() {
        results = books;
        searching = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        searching = false;
      });
    }
  }

  Future<void> scanIsbn() async {
    final book = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/book_isbn_scanner'),
        builder: (_) => const BookIsbnScannerPage(),
      ),
    );

    if (book == null) return;

    await selectBook(book);
  }

  void updateQuery(String value) {
    setState(() => query = value);

    searchDebounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        results = [];
        errorMessage = null;
      });

      return;
    }

    searchDebounce = Timer(const Duration(milliseconds: 400), searchBooks);
  }

  Future<void> selectBook(Map<String, dynamic> book) async {
    if (selecting) return;

    setState(() => selecting = true);

    try {
      final cached = await bookRepository.cacheBook(book);

      if (!mounted) return;

      Navigator.of(context).pop(cached);
    } catch (error) {
      if (!mounted) return;

      setState(() => selecting = false);

      showErrorSnackBar(context, 'Failed to select book.', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSearch = query.trim().isNotEmpty && !searching && !selecting;

    return Scaffold(
      appBar: AppBar(title: const Text('Find book')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _BookPickerHeaderCard(),
            const SizedBox(height: 12),
            SearchBar(
              controller: searchController,
              leading: const Icon(Icons.search),
              hintText: 'Search by title or author',
              enabled: !searching && !selecting,
              onChanged: updateQuery,
              onSubmitted: (_) => searchBooks(),
              trailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: searching || selecting
                        ? null
                        : () {
                            searchDebounce?.cancel();
                            searchController.clear();

                            setState(() {
                              query = '';
                              results = [];
                              errorMessage = null;
                            });
                          },
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  onPressed: canSearch ? searchBooks : null,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: searching || selecting ? null : scanIsbn,
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: const Text('Scan ISBN barcode'),
              ),
            ),
            if (searching || selecting) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              AppMessageCard(
                icon: Icons.error_outline,
                message: errorMessage!,
                tone: AppMessageCardTone.error,
              ),
            ],
            if (!searching && results.isEmpty && query.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              const AppMessageCard(
                icon: Icons.search_outlined,
                message: 'Search for a book to link it to this list item.',
              ),
            ],
            if (results.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${results.length} result(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              for (final book in results)
                _BookResultCard(book: book, onTap: () => selectBook(book)),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookPickerHeaderCard extends StatelessWidget {
  const _BookPickerHeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.menu_book_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Open Library',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Choose the main book/work you want to read. Edition selection will be improved later.',
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

class _BookResultCard extends StatelessWidget {
  const _BookResultCard({required this.book, required this.onTap});

  final Map<String, dynamic> book;
  final VoidCallback onTap;

  String get title {
    return AppValueParsing.textOrNull(book[AppBookFields.title]) ??
        'Unknown book';
  }

  String? get subtitle {
    return AppValueParsing.textOrNull(book[AppBookFields.subtitle]);
  }

  String? get authors {
    return AppValueParsing.textOrNull(book[AppBookFields.authors]);
  }

  String? get coverUrl {
    return AppValueParsing.textOrNull(book[AppBookFields.coverUrl]);
  }

  int? get firstPublishYear {
    return AppValueParsing.intOrNull(book[AppBookFields.firstPublishYear]);
  }

  int? get editionCount {
    return AppValueParsing.intOrNull(book[AppBookFields.editionCount]);
  }

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      ?authors,
      if (firstPublishYear != null) firstPublishYear.toString(),
      if (editionCount != null) '$editionCount edition(s)',
    ];

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(coverUrl: coverUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        meta.join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = coverUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 84,
        color: theme.colorScheme.surfaceContainerHighest,
        child: url == null
            ? Icon(
                Icons.menu_book_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                // ignore: unnecessary_underscores
                errorBuilder: (_, __, _) {
                  return Icon(
                    Icons.menu_book_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  );
                },
              ),
      ),
    );
  }
}
