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

  Future<void> createItem({
    required String listId,
    required String title,
    String? description,
  }) async {
    await _client.from('items').insert({
      'list_id': listId,
      'title': title,
      'description': description,
      'created_by': _client.auth.currentUser!.id,
    });
  }
}
