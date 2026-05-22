import 'package:flutter/foundation.dart';
import 'package:pesalistas/core/app_analytics.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/controllers/app_notification_controller.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_assignee_fields.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
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

    await _client
        .from(AppTables.items)
        .update({AppItemFields.status: AppItemStatus.done})
        .eq(AppItemFields.id, itemId);

    await AppNotificationController.cancelItemReminders(itemId);
    await AppAnalytics.instance.logItemCompleted();
  }

  Future<void> reopenItem(String itemId) async {
    await _client
        .from(AppTables.items)
        .update({AppItemFields.status: AppItemStatus.open})
        .eq(AppItemFields.id, itemId);

    await AppAnalytics.instance.logItemReopened();
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from(AppTables.items).delete().eq(AppItemFields.id, itemId);

    await AppNotificationController.cancelItemReminders(itemId);
    await AppAnalytics.instance.logItemDeleted();
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
    int? movieTmdbId,
    bool updateMovieFields = false,
    String? bookOpenLibraryKey,
    bool updateBookFields = false,
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
      values[AppItemFields.movieTmdbId] = movieTmdbId;
    }

    if (updateBookFields) {
      values[AppItemFields.bookOpenLibraryKey] = AppValueParsing.textOrNull(
        bookOpenLibraryKey,
      );
    }

    await _client
        .from(AppTables.items)
        .update(values)
        .eq(AppItemFields.id, itemId);

    if (assignmentScope != null) {
      final previousAssignees = await getAssigneesForItem(itemId);
      final previousUserIds = previousAssignees
          .map((row) => row[AppItemAssigneeFields.userId]?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      final normalizedScope = normalizeAssignmentScope(assignmentScope);

      if (normalizedScope == AppItemAssignmentScopes.specific) {
        final nextUserIds = (assigneeUserIds ?? const [])
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();

        await replaceAssignees(itemId: itemId, userIds: nextUserIds.toList());

        final newlyAssignedUserIds = nextUserIds
            .where((id) => !previousUserIds.contains(id))
            .toList();

        await _sendItemAssignedPush(
          itemId: itemId,
          assigneeUserIds: newlyAssignedUserIds,
        );
      } else {
        await replaceAssignees(itemId: itemId, userIds: const []);
      }
    }

    await AppNotificationController.scheduleTaskDeadlineReminders(
      itemId: itemId,
      title: title,
      deadlineAt: updateTaskFields ? deadlineAt : null,
    );

    await AppNotificationController.scheduleChoreDueReminders(
      itemId: itemId,
      title: title,
      nextDueAt: updateChoreFields ? nextDueAt : null,
    );

    await AppAnalytics.instance.logItemUpdated();
  }

  Future<void> updateBookReadingStatus({
    required String itemId,
    required String status,
  }) async {
    final cleanItemId = itemId.trim();
    final cleanStatus = status.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    if (cleanStatus.isEmpty) {
      throw ArgumentError('Status is required.');
    }

    final values = <String, dynamic>{
      AppItemFields.status: cleanStatus,
      AppItemFields.updatedAt: DateTime.now().toUtc().toIso8601String(),
    };

    if (cleanStatus == 'done') {
      values[AppItemFields.completedAt] = DateTime.now()
          .toUtc()
          .toIso8601String();
      values[AppItemFields.completedBy] = _client.auth.currentUser?.id;
    } else {
      values[AppItemFields.completedAt] = null;
      values[AppItemFields.completedBy] = null;
    }

    await _client
        .from(AppTables.items)
        .update(values)
        .eq(AppItemFields.id, cleanItemId);
  }

  Future<void> _sendItemAssignedPush({
    required String itemId,
    required List<String> assigneeUserIds,
  }) async {
    final cleanUserIds = assigneeUserIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanUserIds.isEmpty) {
      return;
    }

    try {
      final response = await _client.functions.invoke(
        'send-item-assigned-push',
        body: {'itemId': itemId, 'assigneeUserIds': cleanUserIds},
      );

      debugPrint(
        'ITEM ASSIGNED PUSH RESULT: status=${response.status} data=${response.data}',
      );
    } catch (error, stackTrace) {
      debugPrint('ITEM ASSIGNED PUSH FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);

      await AppAnalytics.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'send_item_assigned_push_failed',
      );
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
    int? movieTmdbId,
    String? bookOpenLibraryKey,
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
          AppItemFields.movieTmdbId: movieTmdbId,
          AppItemFields.bookOpenLibraryKey: AppValueParsing.textOrNull(
            bookOpenLibraryKey,
          ),
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

      await _sendItemAssignedPush(
        itemId: createdItemId,
        assigneeUserIds: assigneeUserIds,
      );
    }

    await AppAnalytics.instance.logItemCreated(
      assignmentScope: normalizedScope,
      hasDeadline: deadlineAt != null,
      isRecurring: recurrenceType != null && recurrenceType.trim().isNotEmpty,
      hasMovie: movieTmdbId != null,
    );

    await AppNotificationController.scheduleTaskDeadlineReminders(
      itemId: createdItemId,
      title: title,
      deadlineAt: deadlineAt,
    );

    await AppNotificationController.scheduleChoreDueReminders(
      itemId: createdItemId,
      title: title,
      nextDueAt: nextDueAt,
    );

    return createdItem;
  }
}
