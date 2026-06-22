import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_only.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/list_detail/chore_item_card.dart';
import 'package:pesalistas/widgets/list_detail/empty_items_card.dart';
import 'package:pesalistas/widgets/list_detail/unread_item_highlight.dart';

class ChoreItemsView extends StatelessWidget {
  const ChoreItemsView({
    super.key,
    required this.items,
    required this.loading,
    required this.onCreate,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> items;
  final bool loading;
  final VoidCallback onCreate;
  final void Function(String itemId) onComplete;
  final void Function(String itemId) onReopen;
  final void Function(Map<String, dynamic> item) onEdit;
  final void Function(String itemId) onDelete;

  int get doneCount {
    return items.where((item) {
      return AppItemStatus.isDone(item[AppItemFields.status]);
    }).length;
  }

  int get openCount => items.length - doneCount;

  int get overdueCount {
    return items.where((item) {
      final done = AppItemStatus.isDone(item[AppItemFields.status]);
      if (done) return false;

      final nextDueDate = AppDateOnly.fromValue(item[AppItemFields.nextDueAt]);
      return AppDateOnly.isBeforeToday(nextDueDate);
    }).length;
  }

  int get dueTodayCount {
    return items.where((item) {
      final done = AppItemStatus.isDone(item[AppItemFields.status]);
      if (done) return false;

      final nextDueDate = AppDateOnly.fromValue(item[AppItemFields.nextDueAt]);
      return AppDateOnly.isToday(nextDueDate);
    }).length;
  }

  int get recurringCount {
    return items.where((item) {
      final recurrenceType = item[AppItemFields.recurrenceType]?.toString();
      return recurrenceType != null && recurrenceType.trim().isNotEmpty;
    }).length;
  }

  void toggleItem(Map<String, dynamic> item) {
    final itemId = item[AppItemFields.id].toString();
    final isDone = AppItemStatus.isDone(item[AppItemFields.status]);

    if (isDone) {
      onReopen(itemId);
    } else {
      onComplete(itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyItemsCard(
        icon: Icons.cleaning_services_rounded,
        title: 'No chores yet',
        subtitle: 'Create your first household routine and keep things moving.',
        onCreate: onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChoreRoutineHeader(
          totalCount: items.length,
          openCount: openCount,
          doneCount: doneCount,
          overdueCount: overdueCount,
          dueTodayCount: dueTodayCount,
          recurringCount: recurringCount,
        ),
        const SizedBox(height: 12),
        for (final item in items)
          UnreadItemHighlight(
            item: item,
            child: ChoreItemCard(
              item: item,
              onComplete: () => toggleItem(item),
              onEdit: () => onEdit(item),
              onDelete: () => onDelete(item[AppItemFields.id].toString()),
            ),
          ),
      ],
    );
  }
}

class _ChoreRoutineHeader extends StatelessWidget {
  const _ChoreRoutineHeader({
    required this.totalCount,
    required this.openCount,
    required this.doneCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.recurringCount,
  });

  final int totalCount;
  final int openCount;
  final int doneCount;
  final int overdueCount;
  final int dueTodayCount;
  final int recurringCount;

  double get progress {
    if (totalCount == 0) return 0;
    return doneCount / totalCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_repair_service_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Household routine',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: theme.colorScheme.surface.withValues(
                alpha: 0.75,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChoreStatPill(label: 'Open', value: openCount.toString()),
              _ChoreStatPill(label: 'Done', value: doneCount.toString()),
              _ChoreStatPill(
                label: 'Due today',
                value: dueTodayCount.toString(),
              ),
              _ChoreStatPill(label: 'Overdue', value: overdueCount.toString()),
              _ChoreStatPill(
                label: 'Recurring',
                value: recurringCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoreStatPill extends StatelessWidget {
  const _ChoreStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Text(
        '$value $label',
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
