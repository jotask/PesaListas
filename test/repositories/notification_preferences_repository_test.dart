import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/repositories/notification_preferences_repository.dart';

void main() {
  group('NotificationPreferences.fromMap', () {
    test('parses true booleans and treats missing values as false', () {
      final preferences = NotificationPreferences.fromMap({
        'enabled': true,
        'invitations_enabled': false,
        'assignments_enabled': true,
      });

      expect(preferences.enabled, isTrue);
      expect(preferences.invitationsEnabled, isFalse);
      expect(preferences.assignmentsEnabled, isTrue);
      expect(preferences.dueSoonEnabled, isFalse);
      expect(preferences.dueNowEnabled, isFalse);
    });

    test('does not coerce non-boolean truthy values', () {
      final preferences = NotificationPreferences.fromMap({
        'enabled': 'true',
        'invitations_enabled': 1,
        'assignments_enabled': true,
      });

      expect(preferences.enabled, isFalse);
      expect(preferences.invitationsEnabled, isFalse);
      expect(preferences.assignmentsEnabled, isTrue);
    });
  });

  group('NotificationPreferences.toUpdateMap', () {
    test('serializes database field names and updated_at timestamp', () {
      const preferences = NotificationPreferences(
        enabled: true,
        invitationsEnabled: false,
        assignmentsEnabled: true,
        dueSoonEnabled: false,
        dueNowEnabled: true,
      );

      final map = preferences.toUpdateMap();

      expect(map['enabled'], isTrue);
      expect(map['invitations_enabled'], isFalse);
      expect(map['assignments_enabled'], isTrue);
      expect(map['due_soon_enabled'], isFalse);
      expect(map['due_now_enabled'], isTrue);
      expect(DateTime.tryParse(map['updated_at'].toString()), isNotNull);
    });
  });

  group('NotificationPreferences.copyWith', () {
    test('overrides provided values and preserves omitted values', () {
      const preferences = NotificationPreferences(
        enabled: true,
        invitationsEnabled: true,
        assignmentsEnabled: false,
        dueSoonEnabled: false,
        dueNowEnabled: true,
      );

      final next = preferences.copyWith(enabled: false, dueSoonEnabled: true);

      expect(next.enabled, isFalse);
      expect(next.invitationsEnabled, isTrue);
      expect(next.assignmentsEnabled, isFalse);
      expect(next.dueSoonEnabled, isTrue);
      expect(next.dueNowEnabled, isTrue);
    });
  });
}
