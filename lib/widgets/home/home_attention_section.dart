import 'package:flutter/material.dart';
import 'package:pesalistas/repositories/list_repository.dart';

class HomeAttentionSection extends StatelessWidget {
  const HomeAttentionSection({
    super.key,
    required this.summary,
    required this.pendingInvitationCount,
  });

  final HomeAttentionSummary summary;
  final int pendingInvitationCount;

  bool get hasAttention {
    return pendingInvitationCount > 0 || summary.hasAttention;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasAttention) {
      return const SizedBox.shrink();
    }

    final items = <_AttentionItem>[
      if (pendingInvitationCount > 0)
        _AttentionItem(
          icon: Icons.mail_outline,
          label: _plural(pendingInvitationCount, 'pending invitation'),
          tone: _AttentionTone.info,
        ),
      if (summary.overdueChores > 0)
        _AttentionItem(
          icon: Icons.warning_amber_rounded,
          label: _plural(summary.overdueChores, 'overdue chore'),
          tone: _AttentionTone.danger,
        ),
      if (summary.choresDueToday > 0)
        _AttentionItem(
          icon: Icons.today_outlined,
          label: _plural(summary.choresDueToday, 'chore due today'),
          tone: _AttentionTone.primary,
        ),
      if (summary.overdueTasks > 0)
        _AttentionItem(
          icon: Icons.assignment_late_outlined,
          label: _plural(summary.overdueTasks, 'overdue task'),
          tone: _AttentionTone.danger,
        ),
      if (summary.tasksDueToday > 0)
        _AttentionItem(
          icon: Icons.event_available_outlined,
          label: _plural(summary.tasksDueToday, 'task due today'),
          tone: _AttentionTone.primary,
        ),
      if (summary.tasksDueSoon > 0)
        _AttentionItem(
          icon: Icons.schedule_outlined,
          label: _plural(summary.tasksDueSoon, 'task due soon'),
          tone: _AttentionTone.secondary,
        ),
      if (summary.shoppingToBuy > 0)
        _AttentionItem(
          icon: Icons.shopping_basket_outlined,
          label: _plural(summary.shoppingToBuy, 'shopping item'),
          tone: _AttentionTone.secondary,
        ),
      if (summary.mealsToday > 0)
        _AttentionItem(
          icon: Icons.restaurant_menu_outlined,
          label: _plural(summary.mealsToday, 'meal planned today'),
          tone: _AttentionTone.info,
        ),
    ];

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Needs attention',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final item in items) _AttentionChip(item: item)],
            ),
          ],
        ),
      ),
    );
  }

  static String _plural(int count, String singular) {
    if (count == 1) {
      return '1 $singular';
    }

    if (singular.endsWith('today') || singular.endsWith('soon')) {
      return '$count ${singular}s';
    }

    return '$count ${singular}s';
  }
}

enum _AttentionTone { primary, secondary, danger, info }

class _AttentionItem {
  const _AttentionItem({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _AttentionTone tone;
}

class _AttentionChip extends StatelessWidget {
  const _AttentionChip({required this.item});

  final _AttentionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (backgroundColor, foregroundColor) = switch (item.tone) {
      _AttentionTone.danger => (colors.errorContainer, colors.onErrorContainer),
      _AttentionTone.primary => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      _AttentionTone.secondary => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      _AttentionTone.info => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
