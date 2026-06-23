import 'package:flutter/material.dart';
import 'package:pesalistas/repositories/list_repository.dart';

class HomeAttentionSection extends StatelessWidget {
  const HomeAttentionSection({
    super.key,
    required this.summary,
    required this.pendingInvitationCount,
    this.onOpenTasks,
    this.onOpenChores,
    this.onOpenShopping,
    this.onOpenMealPlan,
  });

  final HomeAttentionSummary summary;
  final int pendingInvitationCount;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenChores;
  final VoidCallback? onOpenShopping;
  final VoidCallback? onOpenMealPlan;

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
          icon: Icons.mail_outline_rounded,
          label: _plural(pendingInvitationCount, 'pending invitation'),
          tone: _AttentionTone.info,
        ),
      if (summary.overdueChores > 0)
        _AttentionItem(
          icon: Icons.warning_amber_rounded,
          label: _plural(summary.overdueChores, 'overdue chore'),
          tone: _AttentionTone.danger,
          onTap: onOpenChores,
        ),
      if (summary.choresDueToday > 0)
        _AttentionItem(
          icon: Icons.today_outlined,
          label: _plural(summary.choresDueToday, 'chore due today'),
          tone: _AttentionTone.primary,
          onTap: onOpenChores,
        ),
      if (summary.overdueTasks > 0)
        _AttentionItem(
          icon: Icons.assignment_late_outlined,
          label: _plural(summary.overdueTasks, 'overdue task'),
          tone: _AttentionTone.danger,
          onTap: onOpenTasks,
        ),
      if (summary.tasksDueToday > 0)
        _AttentionItem(
          icon: Icons.event_available_outlined,
          label: _plural(summary.tasksDueToday, 'task due today'),
          tone: _AttentionTone.primary,
          onTap: onOpenTasks,
        ),
      if (summary.tasksDueSoon > 0)
        _AttentionItem(
          icon: Icons.schedule_outlined,
          label: _plural(summary.tasksDueSoon, 'task due soon'),
          tone: _AttentionTone.secondary,
          onTap: onOpenTasks,
        ),
      if (summary.shoppingToBuy > 0)
        _AttentionItem(
          icon: Icons.shopping_basket_outlined,
          label: _plural(summary.shoppingToBuy, 'shopping item'),
          tone: _AttentionTone.secondary,
          onTap: onOpenShopping,
        ),
      if (summary.mealsToday > 0)
        _AttentionItem(
          icon: Icons.restaurant_menu_outlined,
          label: _plural(summary.mealsToday, 'meal planned today'),
          tone: _AttentionTone.info,
          onTap: onOpenMealPlan,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AttentionHeader(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [for (final item in items) _AttentionChip(item: item)],
          ),
        ],
      ),
    );
  }

  static String _plural(int count, String singular) {
    if (count == 1) {
      return '1 $singular';
    }

    return '$count ${singular}s';
  }
}

class _AttentionHeader extends StatelessWidget {
  const _AttentionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7A59).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.priority_high_rounded,
            color: Color(0xFFFF7A59),
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus today',
                style: TextStyle(
                  color: Color(0xFF26363B),
                  fontSize: 18,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Things that need a quick look',
                style: TextStyle(
                  color: Color(0xFF727A83),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _AttentionTone { primary, secondary, danger, info }

class _AttentionItem {
  const _AttentionItem({
    required this.icon,
    required this.label,
    required this.tone,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final _AttentionTone tone;
  final VoidCallback? onTap;
}

class _AttentionChip extends StatelessWidget {
  const _AttentionChip({required this.item});

  final _AttentionItem item;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForTone(item.tone);

    final content = Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: palette.foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (item.onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(999),
        child: content,
      ),
    );
  }
}

class _AttentionPalette {
  const _AttentionPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

_AttentionPalette _paletteForTone(_AttentionTone tone) {
  return switch (tone) {
    _AttentionTone.primary => _AttentionPalette(
      background: const Color(0xFF3478F6).withValues(alpha: 0.10),
      foreground: const Color(0xFF2563EB),
      border: const Color(0xFF3478F6).withValues(alpha: 0.12),
    ),
    _AttentionTone.secondary => _AttentionPalette(
      background: const Color(0xFF19A873).withValues(alpha: 0.11),
      foreground: const Color(0xFF0F7F67),
      border: const Color(0xFF19A873).withValues(alpha: 0.14),
    ),
    _AttentionTone.danger => _AttentionPalette(
      background: const Color(0xFFE94747).withValues(alpha: 0.10),
      foreground: const Color(0xFFC83232),
      border: const Color(0xFFE94747).withValues(alpha: 0.14),
    ),
    _AttentionTone.info => _AttentionPalette(
      background: const Color(0xFFF7F3EA),
      foreground: const Color(0xFF64748B),
      border: const Color(0xFFECE7DC),
    ),
  };
}
