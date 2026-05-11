import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListRepository {
  ListRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getListsForGroup(String groupId) async {
    final response = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .filter(AppListFields.archivedAt, 'is', null)
        .order(AppListFields.createdAt, ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getArchivedListsForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .not(AppListFields.archivedAt, 'is', null)
        .order(AppListFields.archivedAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
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

  Future<Map<String, dynamic>> ensureShoppingListForGroup({
    required String groupId,
  }) async {
    final existing = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .eq(AppListFields.listType, AppListTypes.shopping.value)
        .isFilter(AppListFields.archivedAt, null)
        .maybeSingle();

    if (existing != null) {
      return existing;
    }

    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null) {
      throw StateError('User must be signed in to create a shopping list.');
    }

    try {
      final created = await _client
          .from(AppTables.lists)
          .insert({
            AppListFields.groupId: groupId,
            AppListFields.name: 'Shopping',
            AppListFields.description: null,
            AppListFields.listType: AppListTypes.shopping.value,
            AppListFields.createdBy: currentUserId,
          })
          .select()
          .single();

      return created;
    } catch (_) {
      final existingAfterConflict = await _client
          .from(AppTables.lists)
          .select()
          .eq(AppListFields.groupId, groupId)
          .eq(AppListFields.listType, AppListTypes.shopping.value)
          .isFilter(AppListFields.archivedAt, null)
          .maybeSingle();

      if (existingAfterConflict != null) {
        return existingAfterConflict;
      }

      rethrow;
    }
  }

  Future<void> archiveList(String listId) async {
    await _client
        .from(AppTables.lists)
        .update({
          AppListFields.archivedAt: DateTime.now().toUtc().toIso8601String(),
        })
        .eq(AppListFields.id, listId);
  }

  Future<void> restoreList(String listId) async {
    await _client
        .from(AppTables.lists)
        .update({AppListFields.archivedAt: null})
        .eq(AppListFields.id, listId);
  }

  Future<void> deleteList(String listId) async {
    await _client.from(AppTables.lists).delete().eq(AppListFields.id, listId);
  }
}
