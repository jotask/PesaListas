import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_only.dart';
import 'package:pesalistas/core/item_text.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/priority_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/list_detail/assignment_meta_pill.dart';

class TaskItemCard extends StatelessWidget {
  const TaskItemCard({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String title(BuildContext context) {
    return AppItemText.title(item, fallback: context.l10n.untitledTask);
  }

  String? get description {
    return AppItemText.description(item);
  }

  bool get isDone {
    return AppItemStatus.isDone(item[AppItemFields.status]);
  }

  int get priority {
    return AppValueParsing.intOrNull(item[AppItemFields.priority]) ?? 0;
  }

  bool get hasPriority {
    return priority > 0;
  }

  String priorityText(BuildContext context) {
    return AppPriorityTypes.displayText(context, priority);
  }

  DateTime? get deadlineDate {
    return AppDateOnly.fromValue(item[AppItemFields.deadlineAt]);
  }

  DateTime get today {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  String deadlineText(BuildContext context) {
    final formatted = AppDateFormatting.yyyyMmDdFromValue(
      item[AppItemFields.deadlineAt],
    );

    if (formatted.isEmpty) {
      return context.l10n.noDeadline;
    }

    return formatted;
  }

  bool get hasDeadline {
    return deadlineDate != null;
  }

  bool get isOverdue {
    if (isDone) return false;

    return AppDateOnly.isBeforeToday(deadlineDate);
  }

  bool get isDueToday {
    if (isDone) return false;

    return AppDateOnly.isToday(deadlineDate);
  }

  bool get isUpcoming {
    if (isDone) return false;

    return AppDateOnly.isAfterToday(deadlineDate);
  }

  TaskDeadlineState get deadlineState {
    if (isDone) return TaskDeadlineState.done;
    if (isOverdue) return TaskDeadlineState.overdue;
    if (isDueToday) return TaskDeadlineState.today;
    if (isUpcoming) return TaskDeadlineState.upcoming;

    return TaskDeadlineState.none;
  }

  TaskPriorityState get priorityState {
    if (priority >= 3) return TaskPriorityState.high;
    if (priority == 2) return TaskPriorityState.medium;
    if (priority == 1) return TaskPriorityState.low;

    return TaskPriorityState.none;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deadlineStyle = TaskDeadlineStyle.fromState(context, deadlineState);
    final priorityStyle = TaskPriorityStyle.fromState(context, priorityState);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Opacity(
            opacity: isDone ? 0.68 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: deadlineStyle.avatarBackground,
                      child: Icon(
                        isDone ? Icons.check_circle : deadlineStyle.icon,
                        color: deadlineStyle.avatarForeground,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (deadlineStyle.label.isNotEmpty)
                                _TaskPill(
                                  label: deadlineStyle.label,
                                  backgroundColor: deadlineStyle.pillBackground,
                                  foregroundColor: deadlineStyle.pillForeground,
                                ),
                            ],
                          ),
                          if (description != null) ...[
                            SizedBox(height: 4),
                            Text(
                              description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline),
                      tooltip: context.l10n.deleteTask,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AssignmentMetaPill(item: item),
                    AppMetaPill(
                      icon: priorityStyle.icon,
                      label: hasPriority
                          ? priorityText(context)
                          : context.l10n.noPriority,
                      filled: hasPriority,
                      backgroundColor: hasPriority
                          ? priorityStyle.chipBackground
                          : null,
                      foregroundColor: hasPriority
                          ? priorityStyle.chipForeground
                          : null,
                    ),
                    AppMetaPill(
                      icon: deadlineStyle.dateIcon,
                      label: hasDeadline
                          ? context.l10n.deadlineDate(deadlineText(context))
                          : deadlineText(context),
                      filled: hasDeadline,
                      backgroundColor: hasDeadline
                          ? deadlineStyle.chipBackground
                          : null,
                      foregroundColor: hasDeadline
                          ? deadlineStyle.chipForeground
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onComplete,
                        icon: Icon(
                          isDone ? Icons.undo : Icons.check_circle_outline,
                        ),
                        label: Text(
                          isDone
                              ? context.l10n.markAsOpen
                              : isOverdue || isDueToday
                              ? context.l10n.completeNow
                              : context.l10n.completeTask,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined),
                      tooltip: context.l10n.editTask,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum TaskDeadlineState { none, overdue, today, upcoming, done }

class TaskDeadlineStyle {
  const TaskDeadlineStyle({
    required this.icon,
    required this.dateIcon,
    required this.label,
    required this.avatarBackground,
    required this.avatarForeground,
    required this.pillBackground,
    required this.pillForeground,
    required this.chipBackground,
    required this.chipForeground,
  });

  final IconData icon;
  final IconData dateIcon;
  final String label;
  final Color avatarBackground;
  final Color avatarForeground;
  final Color pillBackground;
  final Color pillForeground;
  final Color chipBackground;
  final Color chipForeground;

  factory TaskDeadlineStyle.fromState(
    BuildContext context,
    TaskDeadlineState state,
  ) {
    final colors = Theme.of(context).colorScheme;

    switch (state) {
      case TaskDeadlineState.overdue:
        return TaskDeadlineStyle(
          icon: Icons.warning_amber_rounded,
          dateIcon: Icons.event_busy_outlined,
          label: context.l10n.overdue,
          avatarBackground: colors.errorContainer,
          avatarForeground: colors.onErrorContainer,
          pillBackground: colors.errorContainer,
          pillForeground: colors.onErrorContainer,
          chipBackground: colors.errorContainer,
          chipForeground: colors.onErrorContainer,
        );

      case TaskDeadlineState.today:
        return TaskDeadlineStyle(
          icon: Icons.today_outlined,
          dateIcon: Icons.today_outlined,
          label: context.l10n.today,
          avatarBackground: colors.primaryContainer,
          avatarForeground: colors.onPrimaryContainer,
          pillBackground: colors.primaryContainer,
          pillForeground: colors.onPrimaryContainer,
          chipBackground: colors.primaryContainer,
          chipForeground: colors.onPrimaryContainer,
        );

      case TaskDeadlineState.upcoming:
        return TaskDeadlineStyle(
          icon: Icons.checklist,
          dateIcon: Icons.event_outlined,
          label: context.l10n.upcoming,
          avatarBackground: colors.secondaryContainer,
          avatarForeground: colors.onSecondaryContainer,
          pillBackground: colors.secondaryContainer,
          pillForeground: colors.onSecondaryContainer,
          chipBackground: colors.secondaryContainer,
          chipForeground: colors.onSecondaryContainer,
        );

      case TaskDeadlineState.done:
        return TaskDeadlineStyle(
          icon: Icons.check_circle,
          dateIcon: Icons.event_available_outlined,
          label: context.l10n.done,
          avatarBackground: colors.surfaceContainerHighest,
          avatarForeground: colors.onSurfaceVariant,
          pillBackground: colors.surfaceContainerHighest,
          pillForeground: colors.onSurfaceVariant,
          chipBackground: colors.surfaceContainerHighest,
          chipForeground: colors.onSurfaceVariant,
        );

      case TaskDeadlineState.none:
        return TaskDeadlineStyle(
          icon: Icons.checklist,
          dateIcon: Icons.event_outlined,
          label: '',
          avatarBackground: colors.surfaceContainerHighest,
          avatarForeground: colors.onSurfaceVariant,
          pillBackground: colors.surfaceContainerHighest,
          pillForeground: colors.onSurfaceVariant,
          chipBackground: colors.surfaceContainerHighest,
          chipForeground: colors.onSurfaceVariant,
        );
    }
  }
}

enum TaskPriorityState { none, low, medium, high }

class TaskPriorityStyle {
  const TaskPriorityStyle({
    required this.icon,
    required this.chipBackground,
    required this.chipForeground,
  });

  final IconData icon;
  final Color chipBackground;
  final Color chipForeground;

  factory TaskPriorityStyle.fromState(
    BuildContext context,
    TaskPriorityState state,
  ) {
    final colors = Theme.of(context).colorScheme;

    switch (state) {
      case TaskPriorityState.high:
        return TaskPriorityStyle(
          icon: Icons.priority_high,
          chipBackground: colors.errorContainer,
          chipForeground: colors.onErrorContainer,
        );

      case TaskPriorityState.medium:
        return TaskPriorityStyle(
          icon: Icons.keyboard_double_arrow_up,
          chipBackground: colors.primaryContainer,
          chipForeground: colors.onPrimaryContainer,
        );

      case TaskPriorityState.low:
        return TaskPriorityStyle(
          icon: Icons.keyboard_arrow_up,
          chipBackground: colors.secondaryContainer,
          chipForeground: colors.onSecondaryContainer,
        );

      case TaskPriorityState.none:
        return TaskPriorityStyle(
          icon: Icons.flag_outlined,
          chipBackground: colors.surfaceContainerHighest,
          chipForeground: colors.onSurfaceVariant,
        );
    }
  }
}

class _TaskPill extends StatelessWidget {
  const _TaskPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
