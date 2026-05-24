import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListUnreadActivity {
  const ListUnreadActivity({
    required this.listId,
    required this.unreadCount,
    this.latestActivityAt,
    this.latestTitle,
    this.latestBody,
  });

  final String listId;
  final int unreadCount;
  final DateTime? latestActivityAt;
  final String? latestTitle;
  final String? latestBody;

  bool get hasUnread => unreadCount > 0;

  factory ListUnreadActivity.fromMap(Map<String, dynamic> map) {
    final rawCount = map['unread_count'];
    final rawDate = map['latest_activity_at'];

    return ListUnreadActivity(
      listId: map['list_id']?.toString() ?? '',
      unreadCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
      latestActivityAt: rawDate == null
          ? null
          : DateTime.tryParse(rawDate.toString())?.toLocal(),
      latestTitle: map['latest_title']?.toString(),
      latestBody: map['latest_body']?.toString(),
    );
  }
}

class ItemUnreadActivity {
  const ItemUnreadActivity({
    required this.itemId,
    required this.unreadCount,
    this.latestActivityAt,
    this.latestEventType,
    this.latestTitle,
    this.latestBody,
  });

  final String itemId;
  final int unreadCount;
  final DateTime? latestActivityAt;
  final String? latestEventType;
  final String? latestTitle;
  final String? latestBody;

  bool get hasUnread => unreadCount > 0;

  factory ItemUnreadActivity.fromMap(Map<String, dynamic> map) {
    final rawCount = map['unread_count'];
    final rawDate = map['latest_activity_at'];

    return ItemUnreadActivity(
      itemId: map['item_id']?.toString() ?? '',
      unreadCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
      latestActivityAt: rawDate == null
          ? null
          : DateTime.tryParse(rawDate.toString())?.toLocal(),
      latestEventType: map['latest_event_type']?.toString(),
      latestTitle: map['latest_title']?.toString(),
      latestBody: map['latest_body']?.toString(),
    );
  }
}

class EntityUnreadActivity {
  const EntityUnreadActivity({
    required this.entityType,
    required this.entityId,
    required this.unreadCount,
    this.latestActivityAt,
    this.latestEventType,
    this.latestTitle,
    this.latestBody,
  });

  final String entityType;
  final String entityId;
  final int unreadCount;
  final DateTime? latestActivityAt;
  final String? latestEventType;
  final String? latestTitle;
  final String? latestBody;

  bool get hasUnread => unreadCount > 0;

  String get key => keyFor(entityType: entityType, entityId: entityId);

  static String keyFor({required String entityType, required String entityId}) {
    return '${entityType.trim()}:${entityId.trim()}';
  }

  factory EntityUnreadActivity.fromMap(Map<String, dynamic> map) {
    final rawCount = map['unread_count'];
    final rawDate = map['latest_activity_at'];

    return EntityUnreadActivity(
      entityType: map['entity_type']?.toString() ?? '',
      entityId: map['entity_id']?.toString() ?? '',
      unreadCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? '') ?? 0,
      latestActivityAt: rawDate == null
          ? null
          : DateTime.tryParse(rawDate.toString())?.toLocal(),
      latestEventType: map['latest_event_type']?.toString(),
      latestTitle: map['latest_title']?.toString(),
      latestBody: map['latest_body']?.toString(),
    );
  }
}

class ActivityRepository {
  ActivityRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, EntityUnreadActivity>> getUnreadEntityActivityForList(
    String listId,
  ) async {
    final cleanListId = listId.trim();

    if (cleanListId.isEmpty) {
      return {};
    }

    final response = await _client.rpc(
      'get_unread_entity_activity_for_list',
      params: {'target_list_id': cleanListId},
    );

    if (response is! List) {
      return {};
    }

    final result = <String, EntityUnreadActivity>{};

    for (final row in response) {
      if (row is! Map) {
        continue;
      }

      final activity = EntityUnreadActivity.fromMap(
        Map<String, dynamic>.from(row),
      );

      if (activity.entityType.isEmpty ||
          activity.entityId.isEmpty ||
          !activity.hasUnread) {
        continue;
      }

      result[activity.key] = activity;
    }

    return result;
  }

  Future<Map<String, ListUnreadActivity>> getUnreadActivityByList(
    List<String> listIds,
  ) async {
    final cleanListIds = listIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanListIds.isEmpty) {
      return {};
    }

    final response = await _client.rpc(
      'get_unread_activity_by_list',
      params: {'target_list_ids': cleanListIds},
    );

    if (response is! List) {
      return {};
    }

    final result = <String, ListUnreadActivity>{};

    for (final row in response) {
      if (row is! Map) {
        continue;
      }

      final activity = ListUnreadActivity.fromMap(
        Map<String, dynamic>.from(row),
      );

      if (activity.listId.isEmpty || !activity.hasUnread) {
        continue;
      }

      result[activity.listId] = activity;
    }

    return result;
  }

  Future<Map<String, ItemUnreadActivity>> getUnreadItemActivityForList(
    String listId,
  ) async {
    final cleanListId = listId.trim();

    if (cleanListId.isEmpty) {
      return {};
    }

    final response = await _client.rpc(
      'get_unread_item_activity_for_list',
      params: {'target_list_id': cleanListId},
    );

    if (response is! List) {
      return {};
    }

    final result = <String, ItemUnreadActivity>{};

    for (final row in response) {
      if (row is! Map) {
        continue;
      }

      final activity = ItemUnreadActivity.fromMap(
        Map<String, dynamic>.from(row),
      );

      if (activity.itemId.isEmpty || !activity.hasUnread) {
        continue;
      }

      result[activity.itemId] = activity;
    }

    return result;
  }

  Future<void> markListAsRead(String listId) async {
    final cleanListId = listId.trim();

    if (cleanListId.isEmpty) {
      return;
    }

    await _client.rpc(
      'mark_list_as_read',
      params: {'target_list_id': cleanListId},
    );
  }

  Future<void> createActivityEvent({
    required String groupId,
    required String eventType,
    required String title,
    String? listId,
    String? itemId,
    String? entityType,
    String? entityId,
    String body = '',
    Map<String, dynamic> metadata = const {},
  }) async {
    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null) {
      return;
    }

    await _client.from(AppTables.listActivityEvents).insert({
      'group_id': groupId,
      'list_id': listId,
      'item_id': itemId,
      'actor_id': currentUserId,
      'event_type': eventType,
      'title': title,
      'body': body,
      'metadata': metadata,
      'entity_type': entityType ?? (itemId == null ? null : 'item'),
      'entity_id': entityId ?? itemId,
    });
  }

  Future<Map<String, dynamic>?> _getList(String listId) async {
    final response = await _client
        .from(AppTables.lists)
        .select(
          '${AppListFields.id}, '
          '${AppListFields.groupId}, '
          '${AppListFields.name}',
        )
        .eq(AppListFields.id, listId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>?> _getListForGroupAndType({
    required String groupId,
    required String listType,
  }) async {
    final response = await _client
        .from(AppTables.lists)
        .select(
          '${AppListFields.id}, '
          '${AppListFields.groupId}, '
          '${AppListFields.name}',
        )
        .eq(AppListFields.groupId, groupId)
        .eq(AppListFields.listType, listType)
        .filter(AppListFields.archivedAt, 'is', null)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<void> createGroupListActivity({
    required String groupId,
    required String listType,
    required String eventType,
    required String body,
    String? title,
    Map<String, dynamic> metadata = const {},
    String? entityType,
    String? entityId,
  }) async {
    final list = await _getListForGroupAndType(
      groupId: groupId,
      listType: listType,
    );

    if (list == null) {
      return;
    }

    final listId = list[AppListFields.id]?.toString();
    final listName = list[AppListFields.name]?.toString().trim();

    if (listId == null || listId.isEmpty) {
      return;
    }

    await createActivityEvent(
      groupId: groupId,
      listId: listId,
      eventType: eventType,
      title: title == null || title.trim().isEmpty
          ? listName == null || listName.isEmpty
                ? 'List'
                : listName
          : title,
      body: body,
      entityType: entityType,
      entityId: entityId,
      metadata: metadata,
    );
  }

  Future<void> createItemActivity({
    required String itemId,
    required String eventType,
    required String body,
    Map<String, dynamic> metadata = const {},
  }) async {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) {
      return;
    }

    final itemResponse = await _client
        .from(AppTables.items)
        .select(
          '${AppItemFields.id}, '
          '${AppItemFields.listId}, '
          '${AppItemFields.title}',
        )
        .eq(AppItemFields.id, cleanItemId)
        .maybeSingle();

    if (itemResponse == null) {
      return;
    }

    final item = Map<String, dynamic>.from(itemResponse);
    final listId = item[AppItemFields.listId]?.toString();
    final itemTitle = item[AppItemFields.title]?.toString().trim();

    if (listId == null || listId.isEmpty) {
      return;
    }

    final list = await _getList(listId);

    if (list == null) {
      return;
    }

    final groupId = list[AppListFields.groupId]?.toString();
    final listTitle = list[AppListFields.name]?.toString().trim();

    if (groupId == null || groupId.isEmpty) {
      return;
    }

    await createActivityEvent(
      groupId: groupId,
      listId: listId,
      itemId: cleanItemId,
      eventType: eventType,
      title: listTitle == null || listTitle.isEmpty ? 'List' : listTitle,
      body: body,
      metadata: {
        if (itemTitle != null && itemTitle.isNotEmpty) 'item_title': itemTitle,
        ...metadata,
      },
    );
  }
}
