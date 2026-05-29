import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/user_app_settings_fields.dart';
import 'package:pesalistas/core/shopping_stores.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAppSettingsRepository {
  UserAppSettingsRepository(this._client);

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<String?> getDefaultShoppingStoreKey() async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    final response = await _client
        .from(AppTables.userAppSettings)
        .select(AppUserAppSettingsFields.defaultShoppingStoreKey)
        .eq(AppUserAppSettingsFields.userId, userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final storeKey = AppValueParsing.textOrNull(
      response[AppUserAppSettingsFields.defaultShoppingStoreKey],
    );

    if (storeKey == null || !AppShoppingStores.values.contains(storeKey)) {
      return null;
    }

    return storeKey;
  }

  Future<void> saveDefaultShoppingStoreKey(String storeKey) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    if (!AppShoppingStores.values.contains(storeKey)) {
      return;
    }

    await _client.from(AppTables.userAppSettings).upsert({
      AppUserAppSettingsFields.userId: userId,
      AppUserAppSettingsFields.defaultShoppingStoreKey: storeKey,
      AppUserAppSettingsFields.updatedAt: DateTime.now()
          .toUtc()
          .toIso8601String(),
    }, onConflict: AppUserAppSettingsFields.userId);
  }
}
