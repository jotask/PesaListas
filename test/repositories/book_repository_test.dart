import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/core/fields/book_localization_fields.dart';
import 'package:pesalistas/repositories/book_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _client() {
  return SupabaseClient('https://example.supabase.co', 'dummy-anon-key');
}

void main() {
  group('BookRepository.normalizeBookRow', () {
    test('normalizes valid Open Library rows', () {
      final repository = BookRepository(_client());

      final row = repository.normalizeBookRow({
        AppBookFields.openLibraryKey: ' /works/OL123W ',
        AppBookFields.title: ' Dune ',
        AppBookFields.subtitle: ' Part One ',
        AppBookFields.authors: ' Frank Herbert ',
        AppBookFields.firstPublishYear: '1965',
        AppBookFields.coverId: '12345',
        AppBookFields.coverUrl: ' https://covers.example/dune.jpg ',
        AppBookFields.editionCount: '42',
        AppBookFields.isbn10: [' 0441172717 ', '', null],
        AppBookFields.isbn13: ['9780441172719'],
        AppBookFields.language: [' eng ', ' spa '],
      });

      expect(row[AppBookFields.openLibraryKey], '/works/OL123W');
      expect(row[AppBookFields.title], 'Dune');
      expect(row[AppBookFields.subtitle], 'Part One');
      expect(row[AppBookFields.authors], 'Frank Herbert');
      expect(row[AppBookFields.firstPublishYear], 1965);
      expect(row[AppBookFields.coverId], 12345);
      expect(row[AppBookFields.coverUrl], 'https://covers.example/dune.jpg');
      expect(row[AppBookFields.editionCount], 42);
      expect(row[AppBookFields.isbn10], ['0441172717']);
      expect(row[AppBookFields.isbn13], ['9780441172719']);
      expect(row[AppBookFields.language], ['eng', 'spa']);
      expect(row[AppBookFields.source], 'open_library');
      expect(row[AppBookFields.rawJson], isA<Map<String, dynamic>>());
      expect(
        DateTime.tryParse(row[AppBookFields.fetchedAt].toString()),
        isNotNull,
      );
      expect(
        DateTime.tryParse(row[AppBookFields.updatedAt].toString()),
        isNotNull,
      );
    });

    test('uses fallback title and default source', () {
      final repository = BookRepository(_client());

      final row = repository.normalizeBookRow({
        AppBookFields.openLibraryKey: '/works/OL1W',
        AppBookFields.title: '   ',
        AppBookFields.source: '   ',
      });

      expect(row[AppBookFields.title], 'Unknown book');
      expect(row[AppBookFields.source], 'open_library');
    });

    test('throws when open library key is missing', () {
      final repository = BookRepository(_client());

      expect(
        () => repository.normalizeBookRow({AppBookFields.title: 'No key'}),
        throwsException,
      );
    });
  });

  group('BookRepository.normalizeBookLocalizationRow', () {
    test('normalizes localized display fields', () {
      final repository = BookRepository(_client());

      final row = repository.normalizeBookLocalizationRow(
        bookRow: {
          AppBookFields.title: ' Duna ',
          AppBookFields.subtitle: ' Edición especial ',
          AppBookFields.authors: ' Frank Herbert ',
          AppBookFields.coverUrl: ' https://covers.example/duna.jpg ',
          AppBookFields.rawJson: {'source': 'test'},
        },
        openLibraryKey: '/works/OL893415W',
        languageCode: 'es',
      );

      expect(row[AppBookLocalizationFields.openLibraryKey], '/works/OL893415W');
      expect(row[AppBookLocalizationFields.languageCode], 'es');
      expect(row[AppBookLocalizationFields.title], 'Duna');
      expect(row[AppBookLocalizationFields.subtitle], 'Edición especial');
      expect(row[AppBookLocalizationFields.authors], 'Frank Herbert');
      expect(
        row[AppBookLocalizationFields.coverUrl],
        'https://covers.example/duna.jpg',
      );
      expect(row[AppBookLocalizationFields.rawJson], {'source': 'test'});
      expect(
        DateTime.tryParse(row[AppBookLocalizationFields.fetchedAt].toString()),
        isNotNull,
      );
      expect(
        DateTime.tryParse(row[AppBookLocalizationFields.updatedAt].toString()),
        isNotNull,
      );
    });
  });
}
