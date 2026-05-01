import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepository {
  InvitationRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    final response = await _client
        .from('group_invitations')
        .select('*, groups(name)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> acceptInvitation(String invitationId) async {
    await _client.rpc(
      'accept_group_invitation',
      params: {'invitation_id': invitationId},
    );
  }

  Future<void> inviteToGroup({
    required String groupId,
    required String email,
    String role = 'member',
  }) async {
    await _client
        .rpc(
          'invite_group_member',
          params: {
            'target_group_id': groupId,
            'target_email': email.trim().toLowerCase(),
            'target_role': role,
          },
        )
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw Exception('Invite RPC timed out');
          },
        );
  }

  Future<void> cancelInvitation(String invitationId) async {
    await _client
        .from('group_invitations')
        .update({'status': 'cancelled'})
        .eq('id', invitationId);
  }

  Future<List<Map<String, dynamic>>> getPendingInvitationsForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from('group_invitations')
        .select()
        .eq('group_id', groupId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
