import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/item_status.dart';

void main() {
  group('AppItemStatus.isDone', () {
    test('returns true only for done', () {
      expect(AppItemStatus.isDone(AppItemStatus.done), true);
      expect(AppItemStatus.isDone('done'), true);
      expect(AppItemStatus.isDone(AppItemStatus.open), false);
      expect(AppItemStatus.isDone(null), false);
      expect(AppItemStatus.isDone(' Done '), false);
    });
  });
}
