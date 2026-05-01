import 'package:supabase_flutter/supabase_flutter.dart';

class ListRepository {
  ListRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getListsForGroup(String groupId) async {
    final response = await _client
        .from('lists')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createList({
    required String groupId,
    required String name,
    String? description,
    String listType = 'generic',
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('lists').insert({
      'group_id': groupId,
      'name': name,
      'description': description,
      'list_type': listType,
      'created_by': userId,
    });
  }
}
