import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListRepository {
  ListRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getListsForGroup(String groupId) async {
    final response = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .order(AppListFields.createdAt);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateListInfo({
    required String listId,
    required String name,
    String? description,
  }) async {
    await _client
        .from(AppTables.lists)
        .update({
          AppListFields.name: name,
          AppListFields.description: description,
        })
        .eq(AppListFields.id, listId);
  }

  Future<void> createList({
    required String groupId,
    required String name,
    required String listType,
  }) async {
    await _client.from(AppTables.lists).insert({
      AppListFields.groupId: groupId,
      AppListFields.name: name,
      AppListFields.listType: listType,
      AppListFields.createdBy: _client.auth.currentUser!.id,
    });
  }
}
