import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_text.dart';

void main() {
  group('AppItemText.title', () {
    test('returns trimmed title', () {
      expect(
        AppItemText.title({
          AppItemFields.title: ' Buy milk ',
        }, fallback: 'Fallback'),
        'Buy milk',
      );
    });

    test('returns fallback for missing or blank title', () {
      expect(AppItemText.title({}, fallback: 'Fallback'), 'Fallback');
      expect(
        AppItemText.title({AppItemFields.title: '   '}, fallback: 'Fallback'),
        'Fallback',
      );
    });
  });

  group('AppItemText.description', () {
    test('returns trimmed description', () {
      expect(
        AppItemText.description({AppItemFields.description: ' Notes '}),
        'Notes',
      );
    });

    test('returns null for missing or blank description', () {
      expect(AppItemText.description({}), null);
      expect(AppItemText.description({AppItemFields.description: '   '}), null);
    });
  });
}
