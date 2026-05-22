import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.enabled,
    required this.invitationsEnabled,
    required this.assignmentsEnabled,
    required this.dueSoonEnabled,
    required this.dueNowEnabled,
  });

  final bool enabled;
  final bool invitationsEnabled;
  final bool assignmentsEnabled;
  final bool dueSoonEnabled;
  final bool dueNowEnabled;

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      enabled: map['enabled'] == true,
      invitationsEnabled: map['invitations_enabled'] == true,
      assignmentsEnabled: map['assignments_enabled'] == true,
      dueSoonEnabled: map['due_soon_enabled'] == true,
      dueNowEnabled: map['due_now_enabled'] == true,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'enabled': enabled,
      'invitations_enabled': invitationsEnabled,
      'assignments_enabled': assignmentsEnabled,
      'due_soon_enabled': dueSoonEnabled,
      'due_now_enabled': dueNowEnabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  NotificationPreferences copyWith({
    bool? enabled,
    bool? invitationsEnabled,
    bool? assignmentsEnabled,
    bool? dueSoonEnabled,
    bool? dueNowEnabled,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      invitationsEnabled: invitationsEnabled ?? this.invitationsEnabled,
      assignmentsEnabled: assignmentsEnabled ?? this.assignmentsEnabled,
      dueSoonEnabled: dueSoonEnabled ?? this.dueSoonEnabled,
      dueNowEnabled: dueNowEnabled ?? this.dueNowEnabled,
    );
  }
}

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._client);

  final SupabaseClient _client;

  Future<NotificationPreferences> getOrCreateForCurrentUser() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      throw StateError('User must be signed in.');
    }

    final response = await _client
        .from('notification_preferences')
        .upsert({'user_id': userId}, onConflict: 'user_id')
        .select()
        .single();

    return NotificationPreferences.fromMap(Map<String, dynamic>.from(response));
  }

  Future<NotificationPreferences> updateForCurrentUser(
    NotificationPreferences preferences,
  ) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      throw StateError('User must be signed in.');
    }

    final response = await _client
        .from('notification_preferences')
        .update(preferences.toUpdateMap())
        .eq('user_id', userId)
        .select()
        .single();

    return NotificationPreferences.fromMap(Map<String, dynamic>.from(response));
  }
}
