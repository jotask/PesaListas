import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/vote_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoteRepository {
  VoteRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getMyVote(String itemId) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from(AppTables.itemVotes)
        .select()
        .eq(AppVoteFields.itemId, itemId)
        .eq(AppVoteFields.userId, userId)
        .maybeSingle();

    return response;
  }

  Future<void> upsertVote({
    required String itemId,
    required int points,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from(AppTables.itemVotes).upsert({
      AppVoteFields.itemId: itemId,
      AppVoteFields.userId: userId,
      AppVoteFields.points: points,
      AppVoteFields.comment: comment,
    });
  }
}
