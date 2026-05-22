import 'dart:convert';

import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookRepository {
  BookRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    final searchText = query.trim();

    if (searchText.isEmpty) {
      return [];
    }

    final response = await _client.functions.invoke(
      'open-library-search',
      body: {'query': searchText, 'limit': 20},
    );

    if (response.status < 200 || response.status >= 300) {
      final data = _asMap(response.data);

      throw Exception(
        data['error']?.toString() ??
            'Open Library search failed with status ${response.status}.',
      );
    }

    final data = _asMap(response.data);
    final books = data['books'];

    if (books is! List) {
      return [];
    }

    return books
        .whereType<Map>()
        .map((book) => Map<String, dynamic>.from(book))
        .where((book) {
          final key = book[AppBookFields.openLibraryKey]?.toString();
          final title = book[AppBookFields.title]?.toString();

          return key != null &&
              key.trim().isNotEmpty &&
              title != null &&
              title.trim().isNotEmpty;
        })
        .toList();
  }

  Future<Map<String, dynamic>?> getCachedBook(String openLibraryKey) async {
    final cleanKey = openLibraryKey.trim();

    if (cleanKey.isEmpty) {
      return null;
    }

    final result = await _client
        .from(AppTables.bookCatalog)
        .select()
        .eq(AppBookFields.openLibraryKey, cleanKey)
        .maybeSingle();

    return result;
  }

  Future<Map<String, dynamic>> cacheBook(Map<String, dynamic> bookRow) async {
    final normalized = normalizeBookRow(bookRow);

    final result = await _client
        .from(AppTables.bookCatalog)
        .upsert(normalized, onConflict: AppBookFields.openLibraryKey)
        .select()
        .single();

    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> fetchAndCacheBookByOpenLibraryKey(
    String openLibraryKey,
  ) async {
    final cached = await getCachedBook(openLibraryKey);

    if (cached != null) {
      return cached;
    }

    throw Exception(
      'Book is not cached yet. Search and select the book before linking it.',
    );
  }

  Future<void> linkBookToItem({
    required String itemId,
    required Map<String, dynamic> book,
  }) async {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    final cached = await cacheBook(book);

    final openLibraryKey = cached[AppBookFields.openLibraryKey]
        ?.toString()
        .trim();

    if (openLibraryKey == null || openLibraryKey.isEmpty) {
      throw Exception('Book did not include an Open Library key.');
    }

    await _client
        .from(AppTables.items)
        .update({AppItemFields.bookOpenLibraryKey: openLibraryKey})
        .eq(AppItemFields.id, cleanItemId);
  }

  Future<void> unlinkBookFromItem(String itemId) async {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    await _client
        .from(AppTables.items)
        .update({AppItemFields.bookOpenLibraryKey: null})
        .eq(AppItemFields.id, cleanItemId);
  }

  Future<List<Map<String, dynamic>>> getCachedBooksForItems(
    List<Map<String, dynamic>> items,
  ) async {
    final bookKeys = items
        .map((item) => item[AppItemFields.bookOpenLibraryKey]?.toString())
        .whereType<String>()
        .where((key) => key.trim().isNotEmpty)
        .toSet()
        .toList();

    if (bookKeys.isEmpty) {
      return [];
    }

    final response = await _client
        .from(AppTables.bookCatalog)
        .select()
        .inFilter(AppBookFields.openLibraryKey, bookKeys);

    return List<Map<String, dynamic>>.from(response);
  }

  Map<String, dynamic> normalizeBookRow(Map<String, dynamic> row) {
    final now = DateTime.now().toUtc().toIso8601String();

    final openLibraryKey = AppValueParsing.textOrNull(
      row[AppBookFields.openLibraryKey],
    );

    if (openLibraryKey == null || openLibraryKey.isEmpty) {
      throw Exception('Book row is missing open_library_key.');
    }

    return {
      AppBookFields.openLibraryKey: openLibraryKey,
      AppBookFields.title:
          AppValueParsing.textOrNull(row[AppBookFields.title]) ??
          'Unknown book',
      AppBookFields.subtitle: AppValueParsing.textOrNull(
        row[AppBookFields.subtitle],
      ),
      AppBookFields.authors: AppValueParsing.textOrNull(
        row[AppBookFields.authors],
      ),
      AppBookFields.firstPublishYear: AppValueParsing.intOrNull(
        row[AppBookFields.firstPublishYear],
      ),
      AppBookFields.coverId: AppValueParsing.intOrNull(
        row[AppBookFields.coverId],
      ),
      AppBookFields.coverUrl: AppValueParsing.textOrNull(
        row[AppBookFields.coverUrl],
      ),
      AppBookFields.editionCount: AppValueParsing.intOrNull(
        row[AppBookFields.editionCount],
      ),
      AppBookFields.isbn10: _stringListOrNull(row[AppBookFields.isbn10]),
      AppBookFields.isbn13: _stringListOrNull(row[AppBookFields.isbn13]),
      AppBookFields.language: _stringListOrNull(row[AppBookFields.language]),
      AppBookFields.source:
          AppValueParsing.textOrNull(row[AppBookFields.source]) ??
          'open_library',
      AppBookFields.rawJson: _rawJson(row),
      AppBookFields.fetchedAt:
          AppValueParsing.textOrNull(row[AppBookFields.fetchedAt]) ?? now,
      AppBookFields.updatedAt: now,
    };
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Fall through.
      }
    }

    return {'value': value?.toString()};
  }

  List<String>? _stringListOrNull(dynamic value) {
    if (value is! List) {
      return null;
    }

    final values = value
        .map((item) => item?.toString().trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();

    if (values.isEmpty) {
      return null;
    }

    return values;
  }

  Future<Map<String, dynamic>?> lookupBookByIsbn(String isbn) async {
    final cleanIsbn = isbn.trim().replaceAll('-', '').replaceAll(' ', '');

    if (cleanIsbn.isEmpty) {
      return null;
    }

    final response = await _client.functions.invoke(
      'open-library-isbn',
      body: {'isbn': cleanIsbn},
    );

    final data = _asMap(response.data);

    if (response.status < 200 || response.status >= 300) {
      throw Exception(
        data['error']?.toString() ??
            'Open Library ISBN lookup failed with status ${response.status}.',
      );
    }

    if (data['found'] != true) {
      return null;
    }

    final book = data['book'];

    if (book is Map<String, dynamic>) {
      return cacheBook(book);
    }

    if (book is Map) {
      return cacheBook(Map<String, dynamic>.from(book));
    }

    return null;
  }

  Map<String, dynamic> _rawJson(Map<String, dynamic> row) {
    final raw = row[AppBookFields.rawJson];

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return row;
  }
}
