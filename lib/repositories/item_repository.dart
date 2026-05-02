import 'package:supabase_flutter/supabase_flutter.dart';

class ItemRepository {
  ItemRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getItemsForList(String listId) async {
    final response = await _client
        .from('items')
        .select()
        .eq('list_id', listId)
        .order('position');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> completeItem(String itemId) async {
    await _client.rpc(
      'complete_item',
      params: {'target_item_id': itemId, 'completion_note': null},
    );
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from('items').delete().eq('id', itemId);
  }

  Future<void> updateItem({
    required String itemId,
    required String title,
    String? description,
  }) async {
    await _client
        .from('items')
        .update({'title': title, 'description': description})
        .eq('id', itemId);
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
    await _client.from('items').insert({
      'list_id': listId,
      'title': title,
      'description': description,
      'priority': priority,
      'deadline_at': deadlineAt?.toIso8601String(),
      'recurrence_type': recurrenceType,
      'recurrence_interval': recurrenceInterval,
      'next_due_at': nextDueAt?.toIso8601String(),
      'created_by': _client.auth.currentUser!.id,
    });
  }
}
