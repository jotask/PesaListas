import 'package:supabase_flutter/supabase_flutter.dart';

class VoteRepository {
  VoteRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getMyVote(String itemId) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('item_votes')
        .select()
        .eq('item_id', itemId)
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  Future<void> upsertVote({
    required String itemId,
    required int points,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('item_votes').upsert({
      'item_id': itemId,
      'user_id': userId,
      'points': points,
      'comment': comment,
    });
  }
}
