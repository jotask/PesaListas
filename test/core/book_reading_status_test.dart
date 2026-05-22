import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/book_reading_status.dart';

void main() {
  group('AppBookReadingStatus.normalize', () {
    test('keeps valid statuses', () {
      for (final value in AppBookReadingStatus.values) {
        expect(AppBookReadingStatus.normalize(value), value);
      }
    });

    test('maps empty, null, invalid, and old open status to toRead', () {
      expect(AppBookReadingStatus.normalize(null), AppBookReadingStatus.toRead);
      expect(AppBookReadingStatus.normalize(''), AppBookReadingStatus.toRead);
      expect(
        AppBookReadingStatus.normalize('   '),
        AppBookReadingStatus.toRead,
      );
      expect(
        AppBookReadingStatus.normalize('open'),
        AppBookReadingStatus.toRead,
      );
      expect(
        AppBookReadingStatus.normalize('invalid'),
        AppBookReadingStatus.toRead,
      );
    });
  });

  group('AppBookReadingStatus.label', () {
    test('returns user-facing labels', () {
      expect(
        AppBookReadingStatus.label(AppBookReadingStatus.wishlist),
        'Wishlist',
      );
      expect(
        AppBookReadingStatus.label(AppBookReadingStatus.toRead),
        'To read',
      );
      expect(
        AppBookReadingStatus.label(AppBookReadingStatus.reading),
        'Reading',
      );
      expect(AppBookReadingStatus.label(AppBookReadingStatus.done), 'Done');
      expect(AppBookReadingStatus.label('unknown'), 'To read');
    });
  });

  group('AppBookReadingStatus.icon', () {
    test('returns stable icons for each status', () {
      expect(
        AppBookReadingStatus.icon(AppBookReadingStatus.wishlist),
        Icons.bookmark_border_outlined,
      );
      expect(
        AppBookReadingStatus.icon(AppBookReadingStatus.toRead),
        Icons.menu_book_outlined,
      );
      expect(
        AppBookReadingStatus.icon(AppBookReadingStatus.reading),
        Icons.auto_stories_outlined,
      );
      expect(
        AppBookReadingStatus.icon(AppBookReadingStatus.done),
        Icons.done_all_outlined,
      );
    });
  });
}
