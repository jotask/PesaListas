import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  MemberRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await _client
        .from('group_members')
        .select(
          'role, created_at, profiles(id, username, display_name, avatar_url)',
        )
        .eq('group_id', groupId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }
}
