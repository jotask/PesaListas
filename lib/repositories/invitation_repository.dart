import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/invitation_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepository {
  InvitationRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    final response = await _client
        .from(AppTables.groupInvitations)
        .select('*, groups(name)')
        .eq(AppInvitationFields.status, 'pending')
        .order(AppInvitationFields.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPendingInvitationsForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from(AppTables.groupInvitations)
        .select()
        .eq(AppInvitationFields.groupId, groupId)
        .eq(AppInvitationFields.status, 'pending')
        .order(AppInvitationFields.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> acceptInvitation(String invitationId) async {
    await _client.rpc(
      'accept_group_invitation',
      params: {'invitation_id': invitationId},
    );
  }

  Future<void> declineInvitation(String invitationId) async {
    await _client.rpc(
      'decline_group_invitation',
      params: {'invitation_id': invitationId},
    );
  }

  Future<void> inviteToGroup({
    required String groupId,
    required String email,
    String role = 'member',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    await _client.rpc(
      'invite_group_member',
      params: {
        'target_group_id': groupId,
        'target_email': normalizedEmail,
        'target_role': role,
      },
    );
  }

  Future<void> cancelInvitation(String invitationId) async {
    await _client.rpc(
      'cancel_group_invitation',
      params: {'invitation_id': invitationId},
    );
  }
}
