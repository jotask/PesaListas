import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupRepository {
  GroupRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getMyGroups() async {
    final response = await _client
        .from(AppTables.groups)
        .select()
        .order(AppGroupFields.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createGroup({required String name, String? description}) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from(AppTables.groups).insert({
      AppGroupFields.name: name,
      AppGroupFields.description: description,
      AppGroupFields.createdBy: userId,
    });
  }
}
