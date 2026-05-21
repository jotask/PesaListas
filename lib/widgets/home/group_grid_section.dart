import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/member_fields.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:pesalistas/pages/group_detail_page.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class GroupGridSection extends StatelessWidget {
  const GroupGridSection({
    super.key,
    required this.groups,
    required this.loading,
    required this.creatingGroup,
    required this.onCreateGroup,
  });

  final List<Map<String, dynamic>> groups;
  final bool loading;
  final bool creatingGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groups.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.groups_2_outlined,
        title: context.l10n.noGroupsYet,
        subtitle: context.l10n.createYourFirstSharedSpace,
        trailing: Icon(Icons.add_circle_outline),
        onTap: creatingGroup ? null : onCreateGroup,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = constraints.maxWidth;

        final crossAxisCount = width >= 1200
            ? 4
            : width >= 760
            ? 3
            : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: width < 380 ? 0.9 : 1.0,
          ),
          itemBuilder: (context, index) {
            final group = groups[index];

            return _GroupGridCard(
              group: group,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupDetailPage(group: group),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GroupGridCard extends StatelessWidget {
  const _GroupGridCard({required this.group, required this.onTap});

  final Map<String, dynamic> group;
  final VoidCallback onTap;

  List<Map<String, dynamic>> get members {
    final value = group[AppMemberFields.groupMembers];

    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  bool get isShared {
    return members.length > 1;
  }

  String name(BuildContext context) {
    final value = group[AppGroupFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.sharedSpace;
    }

    return value.trim();
  }

  String description(BuildContext context) {
    final value = group[AppGroupFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return isShared
          ? context.l10n.aSharedSpaceForListsRecipesChoresAndPlanning
          : context.l10n.yourPersonalSpaceForListsRecipesChoresAndPlanning;
    }

    return value.trim();
  }

  String typeLabel(BuildContext context) {
    return isShared ? context.l10n.sharedGroup : context.l10n.individual;
  }

  IconData get typeIcon {
    return isShared ? Icons.groups_2_outlined : Icons.person_outline;
  }

  String memberCountLabel(BuildContext context) {
    final count = members.length;

    if (count == 0) return context.l10n.noMembersLoaded;
    if (count == 1) return context.l10n.memberCountOne;

    return context.l10n.memberCountMany(count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isShared
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      typeIcon,
                      color: isShared
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                name(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  description(context),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _GroupTypePill(
                icon: typeIcon,
                label: typeLabel(context),
                highlighted: isShared,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _MemberPreview(members: members)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      memberCountLabel(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberPreview extends StatelessWidget {
  const _MemberPreview({required this.members});

  final List<Map<String, dynamic>> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const avatarSize = 30.0;
        const overlap = 18.0;
        const extraAvatarWidth = 34.0;

        final availableWidth = constraints.maxWidth;

        final maxAvatars = ((availableWidth - extraAvatarWidth) / overlap)
            .floor()
            .clamp(1, 4);

        final visibleMembers = members.take(maxAvatars).toList();
        final extraCount = members.length - visibleMembers.length;

        return SizedBox(
          height: avatarSize,
          width: availableWidth,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              for (var index = 0; index < visibleMembers.length; index++)
                Positioned(
                  left: index * overlap,
                  child: Tooltip(
                    message: _MemberDisplay.nameFor(
                      context,
                      visibleMembers[index],
                    ),
                    child: _TinyMemberAvatar(
                      name: _MemberDisplay.nameFor(
                        context,
                        visibleMembers[index],
                      ),
                      avatarUrl: _MemberDisplay.avatarUrlFor(
                        visibleMembers[index],
                      ),
                    ),
                  ),
                ),
              if (extraCount > 0)
                Positioned(
                  left: visibleMembers.length * overlap,
                  child: _ExtraMembersAvatar(count: extraCount),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberDisplay {
  const _MemberDisplay._();

  static Map<String, dynamic>? profileFor(Map<String, dynamic> member) {
    final raw = member[AppMemberFields.profiles];

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    final fallback = member['profiles'];

    if (fallback is Map<String, dynamic>) {
      return fallback;
    }

    return null;
  }

  static String nameFor(BuildContext context, Map<String, dynamic> member) {
    final profile = profileFor(member);

    final displayName = profile?[AppProfileFields.displayName]?.toString();
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    final username = profile?[AppProfileFields.username]?.toString();
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }

    return context.l10n.member;
  }

  static String? avatarUrlFor(Map<String, dynamic> member) {
    final profile = profileFor(member);
    final avatarUrl = profile?[AppProfileFields.avatarUrl]?.toString();

    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      return null;
    }

    return avatarUrl.trim();
  }
}

class _TinyMemberAvatar extends StatelessWidget {
  const _TinyMemberAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  String get initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;

    return CircleAvatar(
      radius: 15,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null
          ? Text(
              initials,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            )
          : null,
    );
  }
}

class _ExtraMembersAvatar extends StatelessWidget {
  const _ExtraMembersAvatar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 15,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _GroupTypePill extends StatelessWidget {
  const _GroupTypePill({
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = highlighted
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    final foregroundColor = highlighted
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 96),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: foregroundColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
