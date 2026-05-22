import 'dart:convert';

import 'package:pesalistas/core/app_language.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/core/fields/book_localization_fields.dart';
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
      body: {
        'query': searchText,
        'limit': 20,
        'preferredLanguage': AppLanguage.openLibraryLanguageCode,
      },
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

  Future<Map<String, dynamic>?> lookupBookByIsbn(String isbn) async {
    final cleanIsbn = isbn.trim().replaceAll('-', '').replaceAll(' ', '');

    if (cleanIsbn.isEmpty) {
      return null;
    }

    final response = await _client.functions.invoke(
      'open-library-isbn',
      body: {
        'isbn': cleanIsbn,
        'preferredLanguage': AppLanguage.openLibraryLanguageCode,
      },
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

  Future<Map<String, dynamic>?> getCachedBook(String openLibraryKey) async {
    final cleanKey = openLibraryKey.trim();

    if (cleanKey.isEmpty) {
      return null;
    }

    final baseResult = await _client
        .from(AppTables.bookCatalog)
        .select()
        .eq(AppBookFields.openLibraryKey, cleanKey)
        .maybeSingle();

    if (baseResult == null) {
      return null;
    }

    final localization = await _getBookLocalization(
      openLibraryKey: cleanKey,
      languageCode: AppLanguage.openLibraryLanguageCode,
    );

    return _mergeBookWithLocalization(
      Map<String, dynamic>.from(baseResult),
      localization,
    );
  }

  Future<Map<String, dynamic>> cacheBook(Map<String, dynamic> bookRow) async {
    final baseRow = normalizeBookRow(bookRow);
    final openLibraryKey = baseRow[AppBookFields.openLibraryKey].toString();
    final languageCode = AppLanguage.openLibraryLanguageCode;

    final cachedBase = await _client
        .from(AppTables.bookCatalog)
        .upsert(baseRow, onConflict: AppBookFields.openLibraryKey)
        .select()
        .single();

    final localizationRow = normalizeBookLocalizationRow(
      bookRow: bookRow,
      openLibraryKey: openLibraryKey,
      languageCode: languageCode,
    );

    final cachedLocalization = await _client
        .from(AppTables.bookCatalogLocalizations)
        .upsert(localizationRow, onConflict: 'open_library_key,language_code')
        .select()
        .single();

    return _mergeBookWithLocalization(
      Map<String, dynamic>.from(cachedBase),
      Map<String, dynamic>.from(cachedLocalization),
    );
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

    final baseResponse = await _client
        .from(AppTables.bookCatalog)
        .select()
        .inFilter(AppBookFields.openLibraryKey, bookKeys);

    final baseBooks = List<Map<String, dynamic>>.from(baseResponse);

    if (baseBooks.isEmpty) {
      return [];
    }

    final languageCode = AppLanguage.openLibraryLanguageCode;

    final localizationResponse = await _client
        .from(AppTables.bookCatalogLocalizations)
        .select()
        .eq(AppBookLocalizationFields.languageCode, languageCode)
        .inFilter(AppBookLocalizationFields.openLibraryKey, bookKeys);

    final localizations = List<Map<String, dynamic>>.from(localizationResponse);

    final localizationsByKey = {
      for (final localization in localizations)
        localization[AppBookLocalizationFields.openLibraryKey].toString():
            localization,
    };

    return baseBooks.map((book) {
      final key = book[AppBookFields.openLibraryKey]?.toString();
      final localization = key == null ? null : localizationsByKey[key];

      return _mergeBookWithLocalization(book, localization);
    }).toList();
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

  Map<String, dynamic> normalizeBookLocalizationRow({
    required Map<String, dynamic> bookRow,
    required String openLibraryKey,
    required String languageCode,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();

    return {
      AppBookLocalizationFields.openLibraryKey: openLibraryKey,
      AppBookLocalizationFields.languageCode: languageCode,
      AppBookLocalizationFields.title: AppValueParsing.textOrNull(
        bookRow[AppBookFields.title],
      ),
      AppBookLocalizationFields.subtitle: AppValueParsing.textOrNull(
        bookRow[AppBookFields.subtitle],
      ),
      AppBookLocalizationFields.authors: AppValueParsing.textOrNull(
        bookRow[AppBookFields.authors],
      ),
      AppBookLocalizationFields.coverUrl: AppValueParsing.textOrNull(
        bookRow[AppBookFields.coverUrl],
      ),
      AppBookLocalizationFields.rawJson: _rawJson(bookRow),
      AppBookLocalizationFields.fetchedAt:
          AppValueParsing.textOrNull(bookRow[AppBookFields.fetchedAt]) ?? now,
      AppBookLocalizationFields.updatedAt: now,
    };
  }

  Future<Map<String, dynamic>?> _getBookLocalization({
    required String openLibraryKey,
    required String languageCode,
  }) async {
    final result = await _client
        .from(AppTables.bookCatalogLocalizations)
        .select()
        .eq(AppBookLocalizationFields.openLibraryKey, openLibraryKey)
        .eq(AppBookLocalizationFields.languageCode, languageCode)
        .maybeSingle();

    if (result == null) {
      return null;
    }

    return Map<String, dynamic>.from(result);
  }

  Map<String, dynamic> _mergeBookWithLocalization(
    Map<String, dynamic> base,
    Map<String, dynamic>? localization,
  ) {
    if (localization == null) {
      return base;
    }

    return {
      ...base,
      AppBookFields.title:
          AppValueParsing.textOrNull(
            localization[AppBookLocalizationFields.title],
          ) ??
          base[AppBookFields.title],
      AppBookFields.subtitle:
          AppValueParsing.textOrNull(
            localization[AppBookLocalizationFields.subtitle],
          ) ??
          base[AppBookFields.subtitle],
      AppBookFields.authors:
          AppValueParsing.textOrNull(
            localization[AppBookLocalizationFields.authors],
          ) ??
          base[AppBookFields.authors],
      AppBookFields.coverUrl:
          AppValueParsing.textOrNull(
            localization[AppBookLocalizationFields.coverUrl],
          ) ??
          base[AppBookFields.coverUrl],
      'localized_language_code':
          localization[AppBookLocalizationFields.languageCode],
      'localized_raw_json': localization[AppBookLocalizationFields.rawJson],
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
