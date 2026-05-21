import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDeviceRepository {
  NotificationDeviceRepository(this._client);

  final SupabaseClient _client;

  Future<void> upsertCurrentDeviceToken({
    required String fcmToken,
    required String platform,
    required String? appVersion,
  }) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      return;
    }

    await _client.from('notification_devices').upsert({
      'user_id': userId,
      'fcm_token': fcmToken,
      'platform': platform,
      'app_version': appVersion,
      'enabled': true,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'fcm_token');
  }

  Future<void> disableCurrentDeviceToken(String fcmToken) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      return;
    }

    await _client
        .from('notification_devices')
        .update({
          'enabled': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('fcm_token', fcmToken);
  }
}
