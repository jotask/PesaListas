import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/repositories/book_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookIsbnScannerPage extends StatefulWidget {
  const BookIsbnScannerPage({super.key});

  @override
  State<BookIsbnScannerPage> createState() => _BookIsbnScannerPageState();
}

class _BookIsbnScannerPageState extends State<BookIsbnScannerPage> {
  late final MobileScannerController scannerController;
  late final BookRepository bookRepository;

  final isbnController = TextEditingController();

  bool lookingUpBook = false;
  bool cameraPaused = false;

  String? scannedIsbn;
  String? errorMessage;
  Map<String, dynamic>? book;

  @override
  void initState() {
    super.initState();

    scannerController = MobileScannerController();
    bookRepository = BookRepository(Supabase.instance.client);
  }

  @override
  void dispose() {
    scannerController.dispose();
    isbnController.dispose();

    super.dispose();
  }

  void handleDetection(BarcodeCapture capture) {
    if (lookingUpBook || cameraPaused) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first.rawValue?.trim();

    if (barcode == null || barcode.isEmpty) return;
    if (barcode == scannedIsbn) return;

    lookupIsbn(barcode);
  }

  String normalizeIsbn(String value) {
    return value.trim().replaceAll('-', '').replaceAll(' ', '').toUpperCase();
  }

  bool isPossibleIsbn(String value) {
    final isbn = normalizeIsbn(value);

    if (isbn.length == 13 && RegExp(r'^\d{13}$').hasMatch(isbn)) {
      return isbn.startsWith('978') || isbn.startsWith('979');
    }

    if (isbn.length == 10 && RegExp(r'^\d{9}[\dX]$').hasMatch(isbn)) {
      return true;
    }

    return false;
  }

  Future<void> lookupIsbn(String rawValue) async {
    final cleanIsbn = normalizeIsbn(rawValue);

    if (cleanIsbn.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      lookingUpBook = true;
      cameraPaused = true;
      scannedIsbn = cleanIsbn;
      isbnController.text = cleanIsbn;
      errorMessage = null;
      book = null;
    });

    await scannerController.stop();

    if (!isPossibleIsbn(cleanIsbn)) {
      setState(() {
        lookingUpBook = false;
        errorMessage =
            'This barcode does not look like a book ISBN. Try another barcode or enter the ISBN manually.';
      });
      return;
    }

    try {
      final loadedBook = await bookRepository.lookupBookByIsbn(cleanIsbn);

      if (!mounted) return;

      setState(() {
        book = loadedBook;
        lookingUpBook = false;

        if (loadedBook == null) {
          errorMessage = 'No book found for ISBN $cleanIsbn.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        lookingUpBook = false;
      });
    }
  }

  Future<void> resumeScanner() async {
    setState(() {
      cameraPaused = false;
      errorMessage = null;
    });

    await scannerController.start();
  }

  void selectBook() {
    final currentBook = book;

    if (currentBook == null) {
      showErrorSnackBar(context, 'Scan or load a book first.');
      return;
    }

    Navigator.of(context).pop(currentBook);
  }

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentBook = book;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan ISBN')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: scannerController,
                  onDetect: handleDetection,
                ),
                _ScannerOverlay(
                  lookingUpBook: lookingUpBook,
                  cameraPaused: cameraPaused,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ManualIsbnLookupCard(
                    controller: isbnController,
                    loading: lookingUpBook,
                    onLookup: () => lookupIsbn(isbnController.text),
                    onResumeScanner: resumeScanner,
                  ),
                  const SizedBox(height: 12),
                  if (lookingUpBook)
                    const AppMessageCard(
                      icon: Icons.sync_outlined,
                      message: 'Loading book info...',
                    )
                  else if (errorMessage != null)
                    AppMessageCard(
                      icon: Icons.error_outline,
                      message: errorMessage!,
                      tone: AppMessageCardTone.error,
                    )
                  else if (currentBook != null)
                    _ScannedBookCard(book: currentBook, onSelect: selectBook)
                  else
                    const AppMessageCard(
                      icon: Icons.menu_book_outlined,
                      message: 'Scan or enter an ISBN to load book data.',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({
    required this.lookingUpBook,
    required this.cameraPaused,
  });

  final bool lookingUpBook;
  final bool cameraPaused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.75),
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                lookingUpBook
                    ? 'Looking up book...'
                    : cameraPaused
                    ? 'Scanner paused'
                    : 'Point camera at the book ISBN barcode',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualIsbnLookupCard extends StatelessWidget {
  const _ManualIsbnLookupCard({
    required this.controller,
    required this.loading,
    required this.onLookup,
    required this.onResumeScanner,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onLookup;
  final VoidCallback onResumeScanner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'ISBN',
                hintText: '9780441172719',
                prefixIcon: Icon(Icons.qr_code_2_outlined),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onLookup(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : onResumeScanner,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Scan again'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading ? null : onLookup,
                    icon: const Icon(Icons.search),
                    label: const Text('Lookup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannedBookCard extends StatelessWidget {
  const _ScannedBookCard({required this.book, required this.onSelect});

  final Map<String, dynamic> book;
  final VoidCallback onSelect;

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final title = text(book[AppBookFields.title], fallback: 'Unknown book');
    final authors = text(book[AppBookFields.authors]);
    final year = text(book[AppBookFields.firstPublishYear]);
    final coverUrl = text(book[AppBookFields.coverUrl], fallback: '');
    final isbn13 = book[AppBookFields.isbn13];
    final isbn10 = book[AppBookFields.isbn10];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(authors),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (year != '—') _InfoChip(label: year),
                          if (isbn13 is List && isbn13.isNotEmpty)
                            _InfoChip(label: 'ISBN ${isbn13.first}'),
                          if (isbn10 is List && isbn10.isNotEmpty)
                            _InfoChip(label: 'ISBN ${isbn10.first}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSelect,
              icon: const Icon(Icons.check),
              label: const Text('Use this book'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (coverUrl.isEmpty) {
      return Container(
        width: 58,
        height: 84,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.menu_book_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        coverUrl,
        width: 58,
        height: 84,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 58,
            height: 84,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.menu_book_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
