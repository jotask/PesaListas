import 'package:flutter/material.dart';

class AppBookReadingStatus {
  const AppBookReadingStatus._();

  static const wishlist = 'wishlist';
  static const toRead = 'to_read';
  static const reading = 'reading';
  static const done = 'done';

  static const values = [wishlist, toRead, reading, done];

  static String normalize(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return toRead;
    }

    if (values.contains(text)) {
      return text;
    }

    if (text == 'open') {
      return toRead;
    }

    return toRead;
  }

  static String label(String value) {
    switch (normalize(value)) {
      case wishlist:
        return 'Wishlist';
      case reading:
        return 'Reading';
      case done:
        return 'Done';
      case toRead:
      default:
        return 'To read';
    }
  }

  static IconData icon(String value) {
    switch (normalize(value)) {
      case wishlist:
        return Icons.bookmark_border_outlined;
      case reading:
        return Icons.auto_stories_outlined;
      case done:
        return Icons.done_all_outlined;
      case toRead:
      default:
        return Icons.menu_book_outlined;
    }
  }
}
