import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';

void main() {
  group('AppItemAssignmentScopes.isValid', () {
    test('accepts known values', () {
      expect(AppItemAssignmentScopes.isValid(AppItemAssignmentScopes.none), true);
      expect(AppItemAssignmentScopes.isValid(AppItemAssignmentScopes.specific), true);
      expect(AppItemAssignmentScopes.isValid(AppItemAssignmentScopes.all), true);
    });

    test('rejects unknown values', () {
      expect(AppItemAssignmentScopes.isValid(''), false);
      expect(AppItemAssignmentScopes.isValid('me'), false);
      expect(AppItemAssignmentScopes.isValid('everyone'), false);
      expect(AppItemAssignmentScopes.isValid('invalid'), false);
    });
  });
}
