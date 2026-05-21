import 'package:flutter/foundation.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/invitation_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

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

    await AppAnalytics.instance.logInvitationAccepted();
  }

  Future<void> declineInvitation(String invitationId) async {
    await _client.rpc(
      'decline_group_invitation',
      params: {'invitation_id': invitationId},
    );

    await AppAnalytics.instance.logInvitationDeclined();
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

    await _sendInvitationPush(groupId: groupId, invitedEmail: normalizedEmail);

    await AppAnalytics.instance.logInvitationSent(role: role);
  }

  Future<void> _sendInvitationPush({
    required String groupId,
    required String invitedEmail,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-invitation-push',
        body: {'groupId': groupId, 'invitedEmail': invitedEmail},
      );

      debugPrint(
        'INVITATION PUSH RESULT: status=${response.status} data=${response.data}',
      );
    } catch (error, stackTrace) {
      debugPrint('INVITATION PUSH FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);

      await AppAnalytics.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'send_invitation_push_failed',
      );
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    await _client.rpc(
      'cancel_group_invitation',
      params: {'invitation_id': invitationId},
    );

    await AppAnalytics.instance.logInvitationCanceled();
  }
}
