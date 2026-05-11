import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/member_fields.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupRepository {
  GroupRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getMyGroups() async {
    final response = await _client
        .from(AppTables.groups)
        .select('''
          *,
          ${AppMemberFields.groupMembers}:group_members(
            ${AppMemberFields.userId},
            ${AppMemberFields.role},
            ${AppMemberFields.profiles}:profiles(
              ${AppProfileFields.id},
              ${AppProfileFields.username},
              ${AppProfileFields.displayName},
              ${AppProfileFields.avatarUrl}
            )
          )
          ''')
        .order(AppGroupFields.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createGroup({required String name, String? description}) async {
    await _client.from(AppTables.groups).insert({
      AppGroupFields.name: name,
      AppGroupFields.description: description,
      AppGroupFields.createdBy: _client.auth.currentUser!.id,
    });
  }

  Future<void> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    await _client
        .from(AppTables.groups)
        .update({
          AppGroupFields.name: name,
          AppGroupFields.description: description,
        })
        .eq(AppGroupFields.id, groupId);
  }
}
