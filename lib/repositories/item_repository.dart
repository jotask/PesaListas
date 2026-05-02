import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/recurrence_types.dart';
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
    DateTime? nextDueAt,
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

    await _client
        .from(AppTables.items)
        .update(values)
        .eq(AppItemFields.id, itemId);
  }

  Future<void> createItem({
    required String listId,
    required String title,
    String? description,
    int priority = 0,
    DateTime? deadlineAt,
    String? recurrenceType,
    int? recurrenceInterval,
    DateTime? nextDueAt,
  }) async {
    await _client.from(AppTables.items).insert({
      AppItemFields.listId: listId,
      AppItemFields.title: title,
      AppItemFields.description: description,
      AppItemFields.priority: priority,
      AppItemFields.deadlineAt: deadlineAt?.toIso8601String(),
      AppItemFields.recurrenceType: recurrenceType,
      AppItemFields.recurrenceInterval: recurrenceInterval,
      AppItemFields.nextDueAt: nextDueAt?.toIso8601String(),
      AppItemFields.createdBy: _client.auth.currentUser!.id,
    });
  }
}
