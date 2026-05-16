import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/item_assignee_fields.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/pages/recipe_ingredient_form_page.dart'
    // ignore: library_prefixes
    as AppValueParsing;
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemRepository {
  ItemRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getItemsForList(String listId) async {
    final response = await _client
        .from(AppTables.items)
        .select()
        .eq(AppItemFields.listId, listId)
        .order('position');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> completeItem(String itemId) async {
    await _client.rpc(
      'complete_item',
      params: {'target_item_id': itemId, 'completion_note': null},
    );
  }

  Future<void> reopenItem(String itemId) async {
    await _client
        .from(AppTables.items)
        .update({AppItemFields.status: AppItemStatus.open})
        .eq(AppItemFields.id, itemId);
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from(AppTables.items).delete().eq(AppItemFields.id, itemId);
  }

  String normalizeAssignmentScope(String value) {
    if (AppItemAssignmentScopes.isValid(value)) {
      return value;
    }

    return AppItemAssignmentScopes.none;
  }

  Future<List<Map<String, dynamic>>> getAssigneesForItem(String itemId) async {
    final response = await _client
        .from(AppTables.itemAssignees)
        .select()
        .eq(AppItemAssigneeFields.itemId, itemId)
        .order(AppItemAssigneeFields.createdAt, ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getAssigneesForItems(
    List<String> itemIds,
  ) async {
    final cleanItemIds = itemIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanItemIds.isEmpty) {
      return {};
    }

    final response = await _client
        .from(AppTables.itemAssignees)
        .select()
        .inFilter(AppItemAssigneeFields.itemId, cleanItemIds)
        .order(AppItemAssigneeFields.createdAt, ascending: true);

    final rows = List<Map<String, dynamic>>.from(response);
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final row in rows) {
      final itemId = row[AppItemAssigneeFields.itemId]?.toString();

      if (itemId == null || itemId.isEmpty) continue;

      grouped.putIfAbsent(itemId, () => []);
      grouped[itemId]!.add(row);
    }

    return grouped;
  }

  Future<void> replaceAssignees({
    required String itemId,
    required List<String> userIds,
  }) async {
    final cleanUserIds = userIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    await _client
        .from(AppTables.itemAssignees)
        .delete()
        .eq(AppItemAssigneeFields.itemId, itemId);

    if (cleanUserIds.isEmpty) {
      return;
    }

    final currentUserId = _client.auth.currentUser?.id;

    final rows = cleanUserIds.map((userId) {
      return {
        AppItemAssigneeFields.itemId: itemId,
        AppItemAssigneeFields.userId: userId,
        AppItemAssigneeFields.assignedBy: currentUserId,
      };
    }).toList();

    await _client.from(AppTables.itemAssignees).insert(rows);
  }

  Future<void> setItemAssignment({
    required String itemId,
    required String assignmentScope,
    required List<String> assigneeUserIds,
  }) async {
    final normalizedScope = normalizeAssignmentScope(assignmentScope);

    await _client
        .from(AppTables.items)
        .update({AppItemFields.assignmentScope: normalizedScope})
        .eq(AppItemFields.id, itemId);

    if (normalizedScope == AppItemAssignmentScopes.specific) {
      await replaceAssignees(itemId: itemId, userIds: assigneeUserIds);
    } else {
      await replaceAssignees(itemId: itemId, userIds: const []);
    }
  }

  Future<void> updateItem({
    required String itemId,
    required String title,
    String? description,
    bool updateTaskFields = false,
    int priority = 0,
    DateTime? deadlineAt,
    bool updateChoreFields = false,
    String? recurrenceType,
    int? recurrenceInterval,
    String? movieImdbId,
    bool updateMovieFields = false,
    DateTime? nextDueAt,
    String? assignmentScope,
    List<String>? assigneeUserIds,
  }) async {
    final values = <String, dynamic>{
      AppItemFields.title: title,
      AppItemFields.description: description,
    };

    if (updateTaskFields) {
      values.addAll({
        AppItemFields.priority: priority,
        AppItemFields.deadlineAt: deadlineAt?.toIso8601String(),
      });
    }

    if (updateChoreFields) {
      values.addAll({
        AppItemFields.recurrenceType: recurrenceType,
        AppItemFields.recurrenceInterval:
            recurrenceType == AppRecurrenceTypes.everyNDays.value
            ? recurrenceInterval
            : null,
        AppItemFields.nextDueAt: nextDueAt?.toIso8601String(),
      });
    }

    if (assignmentScope != null) {
      values[AppItemFields.assignmentScope] = normalizeAssignmentScope(
        assignmentScope,
      );
    }

    if (updateMovieFields) {
      values[AppItemFields.movieImdbId] = AppValueParsing.textOrNull(
        movieImdbId,
      );
    }

    await _client
        .from(AppTables.items)
        .update(values)
        .eq(AppItemFields.id, itemId);

    if (assignmentScope != null) {
      final normalizedScope = normalizeAssignmentScope(assignmentScope);

      if (normalizedScope == AppItemAssignmentScopes.specific) {
        await replaceAssignees(
          itemId: itemId,
          userIds: assigneeUserIds ?? const [],
        );
      } else {
        await replaceAssignees(itemId: itemId, userIds: const []);
      }
    }
  }

  Future<Map<String, dynamic>> createItem({
    required String listId,
    required String title,
    String? description,
    int priority = 0,
    String? status,
    int position = 0,
    DateTime? deadlineAt,
    String? recurrenceType,
    int? recurrenceInterval,
    DateTime? nextDueAt,
    String? movieImdbId,
    String assignmentScope = AppItemAssignmentScopes.none,
    List<String> assigneeUserIds = const [],
  }) async {
    final normalizedScope = normalizeAssignmentScope(assignmentScope);

    final created = await _client
        .from(AppTables.items)
        .insert({
          AppItemFields.listId: listId,
          AppItemFields.title: title,
          AppItemFields.description: description,
          AppItemFields.priority: priority,
          AppItemFields.status: status ?? AppItemStatus.open,
          AppItemFields.movieImdbId: AppValueParsing.textOrNull(movieImdbId),
          AppItemFields.position: position,
          AppItemFields.deadlineAt: deadlineAt?.toIso8601String(),
          AppItemFields.assignmentScope: normalizedScope,
          AppItemFields.recurrenceType: recurrenceType,
          AppItemFields.recurrenceInterval:
              recurrenceType == AppRecurrenceTypes.everyNDays.value
              ? recurrenceInterval
              : null,
          AppItemFields.nextDueAt: nextDueAt?.toIso8601String(),
          AppItemFields.createdBy: _client.auth.currentUser!.id,
        })
        .select()
        .single();

    final createdItem = Map<String, dynamic>.from(created);
    final createdItemId = createdItem[AppItemFields.id].toString();

    if (normalizedScope == AppItemAssignmentScopes.specific) {
      await replaceAssignees(itemId: createdItemId, userIds: assigneeUserIds);
    }

    return createdItem;
  }
}
