import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/member_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  MemberRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await _client
        .from(AppTables.groupMembers)
        .select('*, profiles(id, username, display_name, avatar_url)')
        .eq(AppMemberFields.groupId, groupId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  }) async {
    await _client.rpc(
      'remove_group_member',
      params: {'target_group_id': groupId, 'target_user_id': userId},
    );
  }

  Future<void> transferGroupOwnership({
    required String groupId,
    required String newOwnerUserId,
  }) async {
    await _client.rpc(
      'transfer_group_ownership',
      params: {'target_group_id': groupId, 'new_owner_user_id': newOwnerUserId},
    );
  }

  Future<void> updateGroupMemberRole({
    required String groupId,
    required String userId,
    required String role,
  }) async {
    await _client.rpc(
      'update_group_member_role',
      params: {
        'target_group_id': groupId,
        'target_user_id': userId,
        'target_role': role,
      },
    );
  }
}
