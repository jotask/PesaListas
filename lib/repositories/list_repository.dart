import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/book_reading_status.dart';
import 'package:pesalistas/core/date_only.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/shopping_item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class ListRepository {
  ListRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getListsForGroup(String groupId) async {
    final response = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .filter(AppListFields.archivedAt, 'is', null)
        .order(AppListFields.createdAt, ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getListsForGroups(
    List<String> groupIds,
  ) async {
    final cleanGroupIds = groupIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanGroupIds.isEmpty) {
      return [];
    }

    final response = await _client
        .from(AppTables.lists)
        .select()
        .inFilter(AppListFields.groupId, cleanGroupIds)
        .filter(AppListFields.archivedAt, 'is', null)
        .order(AppListFields.updatedAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, String>> getHomeListSummaries(
    List<Map<String, dynamic>> lists,
  ) async {
    final summaries = <String, String>{};

    if (lists.isEmpty) {
      return summaries;
    }

    final itemBackedListIds = lists
        .where((list) {
          final type = list[AppListFields.listType]?.toString();

          return type == AppListTypes.generic.value ||
              type == AppListTypes.tasks.value ||
              type == AppListTypes.chores.value ||
              type == AppListTypes.movies.value ||
              type == AppListTypes.books.value ||
              type == AppListTypes.ideas.value ||
              type == AppListTypes.activities.value;
        })
        .map((list) => list[AppListFields.id]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();

    if (itemBackedListIds.isNotEmpty) {
      final response = await _client
          .from(AppTables.items)
          .select(
            '${AppItemFields.listId}, '
            '${AppItemFields.status}, '
            '${AppItemFields.deadlineAt}, '
            '${AppItemFields.nextDueAt}',
          )
          .inFilter(AppItemFields.listId, itemBackedListIds);

      final rows = List<Map<String, dynamic>>.from(response);
      final itemsByListId = <String, List<Map<String, dynamic>>>{};

      for (final row in rows) {
        final listId = row[AppItemFields.listId]?.toString();

        if (listId == null || listId.isEmpty) {
          continue;
        }

        itemsByListId.putIfAbsent(listId, () => []);
        itemsByListId[listId]!.add(row);
      }

      for (final list in lists) {
        final listId = list[AppListFields.id]?.toString();
        final listType = list[AppListFields.listType]?.toString();

        if (listId == null || !itemBackedListIds.contains(listId)) {
          continue;
        }

        summaries[listId] = _itemBackedSummary(
          listType: listType,
          items: itemsByListId[listId] ?? const [],
        );
      }
    }

    await _addShoppingSummaries(lists: lists, summaries: summaries);
    await _addRecipeSummaries(lists: lists, summaries: summaries);
    await _addMealPlanSummaries(lists: lists, summaries: summaries);

    return summaries;
  }

  Future<void> _addShoppingSummaries({
    required List<Map<String, dynamic>> lists,
    required Map<String, String> summaries,
  }) async {
    final shoppingLists = lists.where((list) {
      return list[AppListFields.listType]?.toString() ==
          AppListTypes.shopping.value;
    }).toList();

    final groupIds = shoppingLists
        .map((list) => list[AppListFields.groupId]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (groupIds.isEmpty) {
      return;
    }

    final response = await _client
        .from(AppTables.shoppingListItems)
        .select(
          '${AppShoppingItemFields.groupId}, ${AppShoppingItemFields.checked}',
        )
        .inFilter(AppShoppingItemFields.groupId, groupIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final rowsByGroupId = <String, List<Map<String, dynamic>>>{};

    for (final row in rows) {
      final groupId = row[AppShoppingItemFields.groupId]?.toString();

      if (groupId == null || groupId.isEmpty) {
        continue;
      }

      rowsByGroupId.putIfAbsent(groupId, () => []);
      rowsByGroupId[groupId]!.add(row);
    }

    for (final list in shoppingLists) {
      final listId = list[AppListFields.id]?.toString();
      final groupId = list[AppListFields.groupId]?.toString();

      if (listId == null || groupId == null) {
        continue;
      }

      final items = rowsByGroupId[groupId] ?? const [];
      final bought = items.where((item) {
        return item[AppShoppingItemFields.checked] == true;
      }).length;

      final toBuy = items.length - bought;

      if (items.isEmpty) {
        summaries[listId] = 'No shopping items yet';
      } else if (toBuy == 0) {
        summaries[listId] = 'All ${_plural(items.length, 'item')} bought';
      } else if (bought == 0) {
        summaries[listId] = '${_plural(toBuy, 'item')} to buy';
      } else {
        summaries[listId] =
            '${_plural(toBuy, 'item')} to buy · ${_plural(bought, 'bought')}';
      }
    }
  }

  Future<void> _addRecipeSummaries({
    required List<Map<String, dynamic>> lists,
    required Map<String, String> summaries,
  }) async {
    final recipeLists = lists.where((list) {
      return list[AppListFields.listType]?.toString() ==
          AppListTypes.recipes.value;
    }).toList();

    final groupIds = recipeLists
        .map((list) => list[AppListFields.groupId]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (groupIds.isEmpty) {
      return;
    }

    final response = await _client
        .from(AppTables.recipes)
        .select(AppRecipeFields.groupId)
        .inFilter(AppRecipeFields.groupId, groupIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final countByGroupId = <String, int>{};

    for (final row in rows) {
      final groupId = row[AppRecipeFields.groupId]?.toString();

      if (groupId == null || groupId.isEmpty) {
        continue;
      }

      countByGroupId[groupId] = (countByGroupId[groupId] ?? 0) + 1;
    }

    for (final list in recipeLists) {
      final listId = list[AppListFields.id]?.toString();
      final groupId = list[AppListFields.groupId]?.toString();

      if (listId == null || groupId == null) {
        continue;
      }

      final count = countByGroupId[groupId] ?? 0;
      summaries[listId] = count == 0
          ? 'No recipes yet'
          : _plural(count, 'recipe');
    }
  }

  Future<void> _addMealPlanSummaries({
    required List<Map<String, dynamic>> lists,
    required Map<String, String> summaries,
  }) async {
    final mealPlanLists = lists.where((list) {
      return list[AppListFields.listType]?.toString() ==
          AppListTypes.mealPlan.value;
    }).toList();

    final groupIds = mealPlanLists
        .map((list) => list[AppListFields.groupId]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (groupIds.isEmpty) {
      return;
    }

    final response = await _client
        .from(AppTables.mealPlans)
        .select('${AppMealPlanFields.groupId}, ${AppMealPlanFields.plannedFor}')
        .inFilter(AppMealPlanFields.groupId, groupIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final today = AppDateOnly.today();

    final todayByGroupId = <String, int>{};
    final upcomingByGroupId = <String, int>{};

    for (final row in rows) {
      final groupId = row[AppMealPlanFields.groupId]?.toString();

      if (groupId == null || groupId.isEmpty) {
        continue;
      }

      final plannedFor = AppDateOnly.fromValue(
        row[AppMealPlanFields.plannedFor],
      );

      if (plannedFor == null) {
        continue;
      }

      if (plannedFor == today) {
        todayByGroupId[groupId] = (todayByGroupId[groupId] ?? 0) + 1;
      } else if (plannedFor.isAfter(today)) {
        upcomingByGroupId[groupId] = (upcomingByGroupId[groupId] ?? 0) + 1;
      }
    }

    for (final list in mealPlanLists) {
      final listId = list[AppListFields.id]?.toString();
      final groupId = list[AppListFields.groupId]?.toString();

      if (listId == null || groupId == null) {
        continue;
      }

      final todayCount = todayByGroupId[groupId] ?? 0;
      final upcomingCount = upcomingByGroupId[groupId] ?? 0;

      if (todayCount == 0 && upcomingCount == 0) {
        summaries[listId] = 'No upcoming meals';
      } else if (todayCount > 0 && upcomingCount > 0) {
        summaries[listId] =
            '${_plural(todayCount, 'meal')} today · ${_plural(upcomingCount, 'upcoming')}';
      } else if (todayCount > 0) {
        summaries[listId] = '${_plural(todayCount, 'meal')} today';
      } else {
        summaries[listId] = _plural(upcomingCount, 'upcoming meal');
      }
    }
  }

  String _itemBackedSummary({
    required String? listType,
    required List<Map<String, dynamic>> items,
  }) {
    if (listType == AppListTypes.chores.value) {
      return _choreSummary(items);
    }

    if (listType == AppListTypes.movies.value) {
      return _movieSummary(items);
    }

    if (listType == AppListTypes.books.value) {
      return _bookSummary(items);
    }

    if (listType == AppListTypes.ideas.value) {
      return items.isEmpty ? 'No ideas yet' : _plural(items.length, 'idea');
    }

    if (listType == AppListTypes.activities.value) {
      return items.isEmpty
          ? 'No activities yet'
          : _plural(items.length, 'activity');
    }

    if (listType == AppListTypes.tasks.value) {
      return _taskSummary(items);
    }

    return _genericItemSummary(items);
  }

  String _taskSummary(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 'No tasks yet';
    }

    final open = items.where((item) {
      return !AppItemStatus.isDone(item[AppItemFields.status]);
    }).length;

    final done = items.length - open;

    if (open == 0) {
      return 'All ${_plural(done, 'task')} done';
    }

    if (done == 0) {
      return '${_plural(open, 'task')} open';
    }

    return '${_plural(open, 'task')} open · ${_plural(done, 'done')}';
  }

  String _genericItemSummary(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 'No items yet';
    }

    final open = items.where((item) {
      return !AppItemStatus.isDone(item[AppItemFields.status]);
    }).length;

    final done = items.length - open;

    if (done == 0) {
      return _plural(open, 'item');
    }

    return '${_plural(open, 'open')} · ${_plural(done, 'done')}';
  }

  String _choreSummary(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 'No chores yet';
    }

    final active = items.where((item) {
      return !AppItemStatus.isDone(item[AppItemFields.status]);
    }).toList();

    final overdue = active.where((item) {
      return AppDateOnly.isBeforeToday(
        AppDateOnly.fromValue(item[AppItemFields.nextDueAt]),
      );
    }).length;

    final dueToday = active.where((item) {
      return AppDateOnly.isToday(
        AppDateOnly.fromValue(item[AppItemFields.nextDueAt]),
      );
    }).length;

    if (overdue > 0 && dueToday > 0) {
      return '${_plural(overdue, 'overdue')} · ${_plural(dueToday, 'due today')}';
    }

    if (overdue > 0) {
      return _plural(overdue, 'overdue');
    }

    if (dueToday > 0) {
      return _plural(dueToday, 'due today');
    }

    return _plural(active.length, 'active chore');
  }

  String _movieSummary(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 'No movies yet';
    }

    final watched = items.where((item) {
      return AppItemStatus.isDone(item[AppItemFields.status]);
    }).length;

    final toWatch = items.length - watched;

    if (toWatch == 0) {
      return 'All ${_plural(watched, 'movie')} watched';
    }

    if (watched == 0) {
      return '${_plural(toWatch, 'movie')} to watch';
    }

    return '${_plural(toWatch, 'movie')} to watch · ${_plural(watched, 'watched')}';
  }

  String _bookSummary(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return 'No books yet';
    }

    final reading = items.where((item) {
      return AppBookReadingStatus.normalize(item[AppItemFields.status]) ==
          AppBookReadingStatus.reading;
    }).length;

    final toRead = items.where((item) {
      return AppBookReadingStatus.normalize(item[AppItemFields.status]) ==
          AppBookReadingStatus.toRead;
    }).length;

    final wishlist = items.where((item) {
      return AppBookReadingStatus.normalize(item[AppItemFields.status]) ==
          AppBookReadingStatus.wishlist;
    }).length;

    final done = items.where((item) {
      return AppBookReadingStatus.normalize(item[AppItemFields.status]) ==
          AppBookReadingStatus.done;
    }).length;

    final parts = [
      if (reading > 0) _plural(reading, 'reading'),
      if (toRead > 0) '${_plural(toRead, 'book')} to read',
      if (wishlist > 0) _plural(wishlist, 'wishlist'),
      if (done > 0) _plural(done, 'done'),
    ];

    if (parts.isEmpty) {
      return _plural(items.length, 'book');
    }

    return parts.take(2).join(' · ');
  }

  String _plural(int count, String singular) {
    if (count == 1) {
      return '1 $singular';
    }

    if (singular == 'bought' ||
        singular == 'done' ||
        singular == 'overdue' ||
        singular == 'due today' ||
        singular == 'reading' ||
        singular == 'wishlist' ||
        singular == 'upcoming') {
      return '$count $singular';
    }

    return '$count ${singular}s';
  }

  Future<List<Map<String, dynamic>>> getArchivedListsForGroup(
    String groupId,
  ) async {
    final response = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .not(AppListFields.archivedAt, 'is', null)
        .order(AppListFields.archivedAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createList({
    required String groupId,
    required String name,
    required String listType,
  }) async {
    await _client.from(AppTables.lists).insert({
      AppListFields.groupId: groupId,
      AppListFields.name: name,
      AppListFields.listType: listType,
      AppListFields.createdBy: _client.auth.currentUser!.id,
    });

    await AppAnalytics.instance.logListCreated(listType: listType);
  }

  Future<void> updateListInfo({
    required String listId,
    required String name,
    String? description,
  }) async {
    await _client
        .from(AppTables.lists)
        .update({
          AppListFields.name: name,
          AppListFields.description: description,
        })
        .eq(AppListFields.id, listId);
  }

  Future<Map<String, dynamic>> ensureShoppingListForGroup({
    required String groupId,
  }) async {
    final existing = await _client
        .from(AppTables.lists)
        .select()
        .eq(AppListFields.groupId, groupId)
        .eq(AppListFields.listType, AppListTypes.shopping.value)
        .isFilter(AppListFields.archivedAt, null)
        .maybeSingle();

    if (existing != null) {
      return existing;
    }

    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null) {
      throw StateError('User must be signed in to create a shopping list.');
    }

    try {
      final created = await _client
          .from(AppTables.lists)
          .insert({
            AppListFields.groupId: groupId,
            AppListFields.name: 'Shopping',
            AppListFields.description: null,
            AppListFields.listType: AppListTypes.shopping.value,
            AppListFields.createdBy: currentUserId,
          })
          .select()
          .single();

      await AppAnalytics.instance.logShoppingListEnsured(created: true);

      return created;
    } catch (_) {
      final existingAfterConflict = await _client
          .from(AppTables.lists)
          .select()
          .eq(AppListFields.groupId, groupId)
          .eq(AppListFields.listType, AppListTypes.shopping.value)
          .isFilter(AppListFields.archivedAt, null)
          .maybeSingle();

      if (existingAfterConflict != null) {
        return existingAfterConflict;
      }

      rethrow;
    }
  }

  Future<void> archiveList(String listId) async {
    await _client
        .from(AppTables.lists)
        .update({
          AppListFields.archivedAt: DateTime.now().toUtc().toIso8601String(),
        })
        .eq(AppListFields.id, listId);

    await AppAnalytics.instance.logListArchived();
  }

  Future<void> restoreList(String listId) async {
    await _client
        .from(AppTables.lists)
        .update({AppListFields.archivedAt: null})
        .eq(AppListFields.id, listId);

    await AppAnalytics.instance.logListRestored();
  }

  Future<void> deleteList(String listId) async {
    await _client.from(AppTables.lists).delete().eq(AppListFields.id, listId);

    await AppAnalytics.instance.logListDeleted();
  }
}
