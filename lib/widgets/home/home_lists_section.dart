import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/group_detail_page.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/repositories/activity_repository.dart';
import 'package:pesalistas/widgets/common/app_list_type_pill.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class HomeListsSection extends StatefulWidget {
  const HomeListsSection({
    super.key,
    required this.groups,
    required this.lists,
    required this.listSummaries,
    required this.loading,
    required this.creatingGroup,
    required this.onCreateGroup,
    required this.onHomeChanged,
    required this.unreadActivityByListId,
    this.onOpenList,
  });

  final List<Map<String, dynamic>> groups;
  final List<Map<String, dynamic>> lists;
  final Map<String, String> listSummaries;
  final bool loading;
  final bool creatingGroup;
  final VoidCallback onCreateGroup;
  final VoidCallback onHomeChanged;
  final Map<String, ListUnreadActivity> unreadActivityByListId;
  final Future<void> Function(Map<String, dynamic> list)? onOpenList;

  @override
  State<HomeListsSection> createState() => _HomeListsSectionState();
}

class _HomeListsSectionState extends State<HomeListsSection> {
  final Set<String> collapsedGroupIds = {};

  Map<String, List<Map<String, dynamic>>> get listsByGroupId {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final list in widget.lists) {
      final groupId = list[AppListFields.groupId]?.toString();

      if (groupId == null || groupId.isEmpty) {
        continue;
      }

      grouped.putIfAbsent(groupId, () => []);
      grouped[groupId]!.add(list);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final aDate = listSortDate(a);
        final bDate = listSortDate(b);

        return bDate.compareTo(aDate);
      });
    }

    return grouped;
  }

  List<Map<String, dynamic>> get sortedGroups {
    final byGroup = listsByGroupId;
    final groups = [...widget.groups];

    groups.sort((a, b) {
      final aId = a[AppGroupFields.id]?.toString();
      final bId = b[AppGroupFields.id]?.toString();

      final aLists = aId == null ? const [] : byGroup[aId] ?? const [];
      final bLists = bId == null ? const [] : byGroup[bId] ?? const [];

      final aDate = aLists.isNotEmpty
          ? listSortDate(aLists.first)
          : groupSortDate(a);
      final bDate = bLists.isNotEmpty
          ? listSortDate(bLists.first)
          : groupSortDate(b);

      return bDate.compareTo(aDate);
    });

    return groups;
  }

  DateTime listSortDate(Map<String, dynamic> list) {
    return dateFromValue(list[AppListFields.updatedAt]) ??
        dateFromValue(list[AppListFields.createdAt]) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime groupSortDate(Map<String, dynamic> group) {
    return dateFromValue(group[AppGroupFields.createdAt]) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? dateFromValue(dynamic value) {
    final text = value?.toString();

    if (text == null || text.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }

  void toggleGroup(String groupId) {
    setState(() {
      if (collapsedGroupIds.contains(groupId)) {
        collapsedGroupIds.remove(groupId);
      } else {
        collapsedGroupIds.add(groupId);
      }
    });
  }

  Future<void> openGroup(Map<String, dynamic> group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/group_detail'),
        builder: (_) => GroupDetailPage(group: group),
      ),
    );

    if (!mounted) return;

    widget.onHomeChanged();
  }

  Future<void> openList(Map<String, dynamic> list) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/list_detail'),
        builder: (_) => ListDetailPage(list: list),
      ),
    );

    if (!mounted) return;

    widget.onHomeChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.groups.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.groups_2_outlined,
        title: context.l10n.noGroupsYet,
        subtitle: context.l10n.createYourFirstSharedSpace,
        trailing: const Icon(Icons.add_circle_outline),
        onTap: widget.creatingGroup ? null : widget.onCreateGroup,
      );
    }

    final byGroup = listsByGroupId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HomeDashboardHeader(),
        const SizedBox(height: 12),
        for (final group in sortedGroups) ...[
          _HomeGroupSection(
            group: group,
            lists: byGroup[group[AppGroupFields.id]?.toString()] ?? const [],
            listSummaries: widget.listSummaries,
            collapsed: collapsedGroupIds.contains(
              group[AppGroupFields.id]?.toString(),
            ),
            onToggle: () {
              final groupId = group[AppGroupFields.id]?.toString();

              if (groupId == null || groupId.isEmpty) {
                return;
              }

              toggleGroup(groupId);
            },
            onOpenGroup: () => openGroup(group),
            onOpenList: widget.onOpenList ?? openList,
            unreadActivityByListId: widget.unreadActivityByListId,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HomeDashboardHeader extends StatelessWidget {
  const _HomeDashboardHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your shared spaces',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeGroupSection extends StatelessWidget {
  const _HomeGroupSection({
    required this.group,
    required this.lists,
    required this.listSummaries,
    required this.collapsed,
    required this.onToggle,
    required this.onOpenGroup,
    required this.onOpenList,
    required this.unreadActivityByListId,
  });

  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> lists;
  final Map<String, String> listSummaries;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback onOpenGroup;
  final Future<void> Function(Map<String, dynamic> list) onOpenList;
  final Map<String, ListUnreadActivity> unreadActivityByListId;

  String get groupName {
    final value = group[AppGroupFields.name]?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'Shared space';
    }

    return value;
  }

  String get subtitle {
    if (lists.isEmpty) {
      return 'No active lists yet';
    }

    if (lists.length == 1) {
      return '1 active list';
    }

    return '${lists.length} active lists';
  }

  int get unreadCount {
    var total = 0;

    for (final list in lists) {
      final listId = list[AppListFields.id]?.toString();

      if (listId == null || listId.isEmpty) {
        continue;
      }

      total += unreadActivityByListId[listId]?.unreadCount ?? 0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.groups_2_outlined,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    _UnreadBadge(count: unreadCount),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: onOpenGroup,
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Group settings',
                  ),
                  Icon(
                    collapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                  ),
                ],
              ),
            ),
          ),
          if (!collapsed) ...[
            const Divider(height: 1),
            if (lists.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: _NoListsInGroupMessage(),
              )
            else
              for (final list in lists)
                _HomeListRow(
                  list: list,
                  summaryText:
                      listSummaries[list[AppListFields.id]?.toString()],
                  onTap: () => onOpenList(list),
                  unreadActivity:
                      unreadActivityByListId[list[AppListFields.id]
                          ?.toString()],
                ),
          ],
        ],
      ),
    );
  }
}

class _NoListsInGroupMessage extends StatelessWidget {
  const _NoListsInGroupMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.playlist_add_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Open this group to create your first list.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeListRow extends StatelessWidget {
  const _HomeListRow({
    required this.list,
    required this.summaryText,
    required this.onTap,
    required this.unreadActivity,
  });

  final Map<String, dynamic> list;
  final String? summaryText;
  final VoidCallback onTap;
  final ListUnreadActivity? unreadActivity;

  String get name {
    final value = list[AppListFields.name]?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'Untitled list';
    }

    return value;
  }

  String get listType {
    return list[AppListFields.listType]?.toString() ??
        AppListTypes.generic.value;
  }

  DateTime? get updatedAt {
    final value = list[AppListFields.updatedAt]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toLocal();
  }

  bool get hasUnread {
    return unreadActivity?.hasUnread == true;
  }

  String updatedLabel(BuildContext context) {
    final date = updatedAt;

    if (date == null) {
      return 'Updated recently';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Updated just now';
    }

    if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return 'Updated ${difference.inHours}h ago';
    }

    if (difference.inDays == 1) {
      return 'Updated yesterday';
    }

    if (difference.inDays < 7) {
      return 'Updated ${difference.inDays}d ago';
    }

    return 'Updated ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String summary(BuildContext context) {
    final text = summaryText?.trim();

    if (text == null || text.isEmpty) {
      final config = AppListTypes.fromValue(listType);

      return '${config.label(context)} · ${updatedLabel(context)}';
    }

    return '$text · ${updatedLabel(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = AppListTypes.fromValue(listType);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                config.icon,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    summary(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppListTypePill(
                    icon: config.icon,
                    label: config.label(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (hasUnread) ...[
              _UnreadBadge(count: unreadActivity!.unreadCount),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  String get label {
    if (count > 99) {
      return '99+';
    }

    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: colors.onError,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
