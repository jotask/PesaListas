import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';

void main() {
  group('AppItemAssignmentScopes', () {
    test('accepts valid assignment scopes', () {
      expect(
        AppItemAssignmentScopes.isValid(AppItemAssignmentScopes.none),
        true,
      );
      expect(
        AppItemAssignmentScopes.isValid(AppItemAssignmentScopes.specific),
        true,
      );
      expect(
        AppItemAssignmentScopes.isValid(AppItemAssignmentScopes.all),
        true,
      );
    });

    test('rejects invalid assignment scopes', () {
      expect(AppItemAssignmentScopes.isValid(''), false);
      expect(AppItemAssignmentScopes.isValid('me'), false);
      expect(AppItemAssignmentScopes.isValid('everyone'), false);
      expect(AppItemAssignmentScopes.isValid('invalid'), false);
    });
  });

  group('AppItemFields', () {
    test('assignment field names match database columns/local keys', () {
      expect(AppItemFields.assignmentScope, 'assignment_scope');
      expect(AppItemFields.assignees, 'assignees');
    });
  });

  group('AppConfig', () {
    test('has a default currency', () {
      expect(AppConfig.defaultCurrency, isNotEmpty);
      expect(AppConfig.defaultCurrency, 'EUR');
    });
  });

  group('AppValueParsing', () {
    test('parses valid integers', () {
      expect(AppValueParsing.intOrNull(5), 5);
      expect(AppValueParsing.intOrNull('5'), 5);
      expect(AppValueParsing.intOrNull(' 5 '), 5);
      expect(AppValueParsing.intOrNull(5.0), 5);
    });

    test('returns null for invalid integers', () {
      expect(AppValueParsing.intOrNull(null), null);
      expect(AppValueParsing.intOrNull(''), null);
      expect(AppValueParsing.intOrNull('abc'), null);
      expect(AppValueParsing.intOrNull('5.5'), null);
    });
  });
}
