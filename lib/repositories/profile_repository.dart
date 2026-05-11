import 'package:flutter/foundation.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<void> syncCurrentProfileFromAuth({
    String debugLabel = 'ProfileSync',
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      debugPrint('[$debugLabel] No authenticated user. Skipping profile sync.');
      return;
    }

    final metadata = user.userMetadata ?? {};

    final displayName = _firstNonEmpty([
      metadata['full_name'],
      metadata['name'],
      metadata['display_name'],
      user.email,
    ]);

    final avatarUrl = _firstNonEmpty([
      metadata['avatar_url'],
      metadata['picture'],
    ]);

    debugPrint('[$debugLabel] Auth user found: ${user.id}', wrapWidth: 1024);

    debugPrint(
      '[$debugLabel] Metadata displayName: ${displayName ?? "EMPTY"}',
      wrapWidth: 1024,
    );

    debugPrint(
      '[$debugLabel] Metadata avatarUrl: ${avatarUrl == null ? "EMPTY" : "FOUND"}',
      wrapWidth: 1024,
    );

    try {
      await _client.rpc('sync_my_profile_from_auth');

      debugPrint('[$debugLabel] Profile sync RPC finished.', wrapWidth: 1024);

      final savedProfile = await _client
          .from(AppTables.profiles)
          .select(
            '${AppProfileFields.id}, '
            '${AppProfileFields.username}, '
            '${AppProfileFields.displayName}, '
            '${AppProfileFields.avatarUrl}',
          )
          .eq(AppProfileFields.id, user.id)
          .maybeSingle();

      if (savedProfile == null) {
        debugPrint(
          '[$debugLabel] WARNING: No profile row found after sync RPC.',
          wrapWidth: 1024,
        );
        return;
      }

      final savedDisplayName = savedProfile[AppProfileFields.displayName]
          ?.toString();

      final savedAvatarUrl = savedProfile[AppProfileFields.avatarUrl]
          ?.toString();

      debugPrint(
        '[$debugLabel] Saved profile display_name: ${_safeDisplay(savedDisplayName)}',
        wrapWidth: 1024,
      );

      debugPrint(
        '[$debugLabel] Saved profile avatar_url: ${savedAvatarUrl == null || savedAvatarUrl.isEmpty ? "EMPTY" : "SAVED"}',
        wrapWidth: 1024,
      );

      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          (savedAvatarUrl == null || savedAvatarUrl.isEmpty)) {
        debugPrint(
          '[$debugLabel] WARNING: Auth metadata had avatar_url, but profiles.avatar_url is still empty.',
          wrapWidth: 1024,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('[$debugLabel] PROFILE SYNC ERROR: $error', wrapWidth: 1024);

      debugPrint('[$debugLabel] STACK TRACE: $stackTrace', wrapWidth: 1024);
    }
  }

  Future<Map<String, dynamic>?> updateCurrentProfileDisplayName({
    required String displayName,
  }) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _client
        .from(AppTables.profiles)
        .update({AppProfileFields.displayName: displayName})
        .eq(AppProfileFields.id, userId)
        .select()
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      return null;
    }

    final response = await _client
        .from(AppTables.profiles)
        .select()
        .eq(AppProfileFields.id, userId)
        .maybeSingle();

    return response;
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;

      final text = value.toString().trim();

      if (text.isNotEmpty) return text;
    }

    return null;
  }

  String _safeDisplay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'EMPTY';
    }

    return value.trim();
  }
}
