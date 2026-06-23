import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/group_detail_page.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/repositories/activity_repository.dart';

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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF19A873)),
      );
    }

    if (widget.groups.isEmpty) {
      return _NoGroupsCard(
        creatingGroup: widget.creatingGroup,
        onCreateGroup: widget.onCreateGroup,
      );
    }

    final byGroup = listsByGroupId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeListsHeader(
          groupCount: widget.groups.length,
          listCount: widget.lists.length,
          creatingGroup: widget.creatingGroup,
          onCreateGroup: widget.onCreateGroup,
        ),
        const SizedBox(height: 12),
        for (final group in sortedGroups) ...[
          _HomeGroupCard(
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

class _HomeListsHeader extends StatelessWidget {
  const _HomeListsHeader({
    required this.groupCount,
    required this.listCount,
    required this.creatingGroup,
    required this.onCreateGroup,
  });

  final int groupCount;
  final int listCount;
  final bool creatingGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shared spaces',
                style: TextStyle(
                  color: Color(0xFF26363B),
                  fontSize: 20,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your groups and active lists',
                style: TextStyle(
                  color: Color(0xFF727A83),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: creatingGroup ? null : onCreateGroup,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF19A873),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(
              0xFF19A873,
            ).withValues(alpha: 0.45),
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: creatingGroup
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add_rounded, size: 19),
          label: const Text(
            'New',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _NoGroupsCard extends StatelessWidget {
  const _NoGroupsCard({
    required this.creatingGroup,
    required this.onCreateGroup,
  });

  final bool creatingGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFF19A873).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              color: Color(0xFF19A873),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noGroupsYet,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF26363B),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.createYourFirstSharedSpace,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF727A83),
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: creatingGroup ? null : onCreateGroup,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF19A873),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: creatingGroup
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded),
              label: const Text(
                'Create group',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeGroupCard extends StatelessWidget {
  const _HomeGroupCard({
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
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              child: Row(
                children: [
                  _GroupAvatar(name: groupName),
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
                            color: Color(0xFF26363B),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF727A83),
                            fontSize: 13,
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
                  _SmallIconButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'Group settings',
                    onPressed: onOpenGroup,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    collapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: const Color(0xFF727A83),
                  ),
                ],
              ),
            ),
          ),
          if (!collapsed) ...[
            const Divider(height: 1, color: Color(0xFFF0EAE0)),
            if (lists.isEmpty)
              const _NoListsInGroupMessage()
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  children: [
                    for (var index = 0; index < lists.length; index++) ...[
                      _HomeListCard(
                        list: lists[index],
                        summaryText:
                            listSummaries[lists[index][AppListFields.id]
                                ?.toString()],
                        onTap: () => onOpenList(lists[index]),
                        unreadActivity:
                            unreadActivityByListId[lists[index][AppListFields
                                    .id]
                                ?.toString()],
                      ),
                      if (index != lists.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.name});

  final String name;

  String get initial {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'S';
    }

    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF19A873).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF0F7F67),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF7F3EA),
        foregroundColor: const Color(0xFF26363B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

class _NoListsInGroupMessage extends StatelessWidget {
  const _NoListsInGroupMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECE7DC)),
        ),
        child: const Row(
          children: [
            Icon(Icons.playlist_add_outlined, color: Color(0xFF727A83)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Open this group to create your first list.',
                style: TextStyle(
                  color: Color(0xFF727A83),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeListCard extends StatelessWidget {
  const _HomeListCard({
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

  Color get toneColor {
    if (listType == 'tasks') return const Color(0xFF3478F6);
    if (listType == 'chores') return const Color(0xFF8B5CF6);
    if (listType == 'shopping') return const Color(0xFF19A873);
    if (listType == 'meal_plan') return const Color(0xFFFF7A59);
    if (listType == 'recipes') return const Color(0xFFFF9F1C);
    if (listType == 'movies') return const Color(0xFFE94747);
    if (listType == 'books') return const Color(0xFF7C5CFF);
    if (listType == 'ideas') return const Color(0xFFF4B400);
    if (listType == 'activities') return const Color(0xFF14B8A6);

    return const Color(0xFF64748B);
  }

  String updatedLabel() {
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

      return '${config.label(context)} · ${updatedLabel()}';
    }

    return '$text · ${updatedLabel()}';
  }

  @override
  Widget build(BuildContext context) {
    final config = AppListTypes.fromValue(listType);

    return Material(
      color: const Color(0xFFFFFCF4),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFECE7DC)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(config.icon, color: toneColor, size: 23),
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
                        color: Color(0xFF26363B),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF727A83),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ListTypeChip(
                      icon: config.icon,
                      label: config.label(context),
                      color: toneColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasUnread) ...[
                _UnreadBadge(count: unreadActivity!.unreadCount),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA0A6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTypeChip extends StatelessWidget {
  const _ListTypeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 9, 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE94747),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
