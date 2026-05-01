import 'package:supabase_flutter/supabase_flutter.dart';

class GroupRepository {
  GroupRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getMyGroups() async {
    final response = await _client
        .from('groups')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createGroup({required String name, String? description}) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('groups').insert({
      'name': name,
      'description': description,
      'created_by': userId,
    });
  }
}
