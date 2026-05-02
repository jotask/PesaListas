import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/vote_fields.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';
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

  Future<Map<String, Map<String, dynamic>>> getVoteSummariesForItems(
    List<String> itemIds,
  ) async {
    if (itemIds.isEmpty) {
      return {};
    }

    final currentUserId = _client.auth.currentUser!.id;

    final response = await _client
        .from(AppTables.itemVotes)
        .select(
          '${AppVoteFields.itemId}, '
          '${AppVoteFields.userId}, '
          '${AppVoteFields.points}',
        )
        .inFilter(AppVoteFields.itemId, itemIds);

    final rows = List<Map<String, dynamic>>.from(response);

    final summaries = <String, Map<String, dynamic>>{};

    for (final itemId in itemIds) {
      summaries[itemId] = {
        AppVoteSummaryFields.totalPoints: 0,
        AppVoteSummaryFields.voteCount: 0,
        AppVoteSummaryFields.averagePoints: 0.0,
        AppVoteSummaryFields.myPoints: null,
      };
    }

    for (final row in rows) {
      final itemId = row[AppVoteFields.itemId]?.toString();

      if (itemId == null || itemId.isEmpty) {
        continue;
      }

      final points = _parseInt(row[AppVoteFields.points]);

      if (points == null) {
        continue;
      }

      final summary = summaries[itemId];

      if (summary == null) {
        continue;
      }

      final previousTotal =
          _parseInt(summary[AppVoteSummaryFields.totalPoints]) ?? 0;

      final previousCount =
          _parseInt(summary[AppVoteSummaryFields.voteCount]) ?? 0;

      final newTotal = previousTotal + points;
      final newCount = previousCount + 1;

      summary[AppVoteSummaryFields.totalPoints] = newTotal;
      summary[AppVoteSummaryFields.voteCount] = newCount;
      summary[AppVoteSummaryFields.averagePoints] = newCount == 0
          ? 0.0
          : newTotal / newCount;

      final voteUserId = row[AppVoteFields.userId]?.toString();

      if (voteUserId == currentUserId) {
        summary[AppVoteSummaryFields.myPoints] = points;
      }
    }

    return summaries;
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

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}
