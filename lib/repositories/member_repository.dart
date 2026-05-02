import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/member_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  MemberRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await _client
        .from(AppTables.groupMembers)
        .select('*, profiles(id, username, display_name, avatar_url)')
        .eq(AppMemberFields.groupId, groupId)
        .order(AppMemberFields.joinedAt);

    return List<Map<String, dynamic>>.from(response);
  }
}
