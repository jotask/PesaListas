import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/date_only.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/design/list_type_style.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/item_text.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/design/app_surface.dart';
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

  String get title {
    return AppItemText.title(item, fallback: 'Untitled task');
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

  String get priorityText {
    if (priority >= 3) return 'High priority';
    if (priority == 2) return 'Medium priority';
    if (priority == 1) return 'Low priority';

    return 'No priority';
  }

  DateTime? get deadlineDate {
    return AppDateOnly.fromValue(item[AppItemFields.deadlineAt]);
  }

  String get formattedDeadline {
    final formatted = AppDateFormatting.yyyyMmDdFromValue(
      item[AppItemFields.deadlineAt],
    );

    if (formatted.isEmpty) {
      return 'No deadline';
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

  String get primaryActionLabel {
    if (isDone) return 'Mark open';
    if (isOverdue || isDueToday) return 'Complete now';

    return 'Complete';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listStyle = ListTypeStyle.of(AppListTypes.tasks.value);
    final deadlineStyle = TaskDeadlineStyle.fromState(context, deadlineState);
    final priorityStyle = TaskPriorityStyle.fromState(context, priorityState);
    final descriptionText = description;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppSurface(
        padding: EdgeInsets.zero,
        borderColor: deadlineStyle.borderColor,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Opacity(
            opacity: isDone ? 0.68 : 1,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 6,
                    decoration: BoxDecoration(
                      color: deadlineStyle.accentColor,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TaskCheckButton(
                                done: isDone,
                                style: deadlineStyle,
                                onPressed: onComplete,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xs,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        if (deadlineStyle.label.isNotEmpty)
                                          _StatusBadge(
                                            label: deadlineStyle.label,
                                            icon: deadlineStyle.icon,
                                            backgroundColor:
                                                deadlineStyle.pillBackground,
                                            foregroundColor:
                                                deadlineStyle.pillForeground,
                                          ),
                                        if (hasPriority)
                                          _StatusBadge(
                                            label: priorityText,
                                            icon: priorityStyle.icon,
                                            backgroundColor:
                                                priorityStyle.chipBackground,
                                            foregroundColor:
                                                priorityStyle.chipForeground,
                                          ),
                                      ],
                                    ),
                                    if (deadlineStyle.label.isNotEmpty ||
                                        hasPriority)
                                      const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            height: 1.1,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      descriptionText ?? 'No description',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: descriptionText == null
                                                ? theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.70)
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              PopupMenuButton<_TaskAction>(
                                tooltip: 'More options',
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onSelected: (action) {
                                  switch (action) {
                                    case _TaskAction.edit:
                                      onEdit();
                                      break;
                                    case _TaskAction.delete:
                                      onDelete();
                                      break;
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: _TaskAction.edit,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Edit task'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _TaskAction.delete,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Delete task'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              AssignmentMetaPill(item: item),
                              AppMetaPill(
                                icon: priorityStyle.icon,
                                label: priorityText,
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
                                    ? 'Deadline $formattedDeadline'
                                    : formattedDeadline,
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
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: onComplete,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isDone
                                        ? theme.colorScheme.secondaryContainer
                                        : listStyle.accent,
                                    foregroundColor: isDone
                                        ? theme.colorScheme.onSecondaryContainer
                                        : Colors.white,
                                  ),
                                  icon: Icon(
                                    isDone
                                        ? Icons.undo
                                        : Icons.check_circle_outline,
                                  ),
                                  label: Text(primaryActionLabel),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton.filledTonal(
                                onPressed: onEdit,
                                tooltip: 'Edit task',
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    required this.accentColor,
    required this.borderColor,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.pillBackground,
    required this.pillForeground,
    required this.chipBackground,
    required this.chipForeground,
  });

  final IconData icon;
  final IconData dateIcon;
  final String label;
  final Color accentColor;
  final Color borderColor;
  final Color buttonBackground;
  final Color buttonForeground;
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
          label: 'Overdue',
          accentColor: colors.error,
          borderColor: colors.error.withValues(alpha: 0.28),
          buttonBackground: colors.errorContainer,
          buttonForeground: colors.onErrorContainer,
          pillBackground: colors.errorContainer,
          pillForeground: colors.onErrorContainer,
          chipBackground: colors.errorContainer,
          chipForeground: colors.onErrorContainer,
        );

      case TaskDeadlineState.today:
        return TaskDeadlineStyle(
          icon: Icons.today_outlined,
          dateIcon: Icons.today_outlined,
          label: 'Today',
          accentColor: colors.primary,
          borderColor: colors.primary.withValues(alpha: 0.28),
          buttonBackground: colors.primaryContainer,
          buttonForeground: colors.onPrimaryContainer,
          pillBackground: colors.primaryContainer,
          pillForeground: colors.onPrimaryContainer,
          chipBackground: colors.primaryContainer,
          chipForeground: colors.onPrimaryContainer,
        );

      case TaskDeadlineState.upcoming:
        return TaskDeadlineStyle(
          icon: Icons.event_available_outlined,
          dateIcon: Icons.event_outlined,
          label: 'Upcoming',
          accentColor: colors.secondary,
          borderColor: colors.secondary.withValues(alpha: 0.24),
          buttonBackground: colors.secondaryContainer,
          buttonForeground: colors.onSecondaryContainer,
          pillBackground: colors.secondaryContainer,
          pillForeground: colors.onSecondaryContainer,
          chipBackground: colors.secondaryContainer,
          chipForeground: colors.onSecondaryContainer,
        );

      case TaskDeadlineState.done:
        return TaskDeadlineStyle(
          icon: Icons.check_circle,
          dateIcon: Icons.event_available_outlined,
          label: 'Done',
          accentColor: colors.secondary,
          borderColor: colors.outlineVariant.withValues(alpha: 0.44),
          buttonBackground: colors.surfaceContainerHighest,
          buttonForeground: colors.onSurfaceVariant,
          pillBackground: colors.surfaceContainerHighest,
          pillForeground: colors.onSurfaceVariant,
          chipBackground: colors.surfaceContainerHighest,
          chipForeground: colors.onSurfaceVariant,
        );

      case TaskDeadlineState.none:
        return TaskDeadlineStyle(
          icon: Icons.checklist_rounded,
          dateIcon: Icons.event_outlined,
          label: '',
          accentColor: colors.primary.withValues(alpha: 0.55),
          borderColor: colors.outlineVariant.withValues(alpha: 0.55),
          buttonBackground: colors.surfaceContainerHighest,
          buttonForeground: colors.onSurfaceVariant,
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
          icon: Icons.priority_high_rounded,
          chipBackground: colors.errorContainer,
          chipForeground: colors.onErrorContainer,
        );

      case TaskPriorityState.medium:
        return TaskPriorityStyle(
          icon: Icons.keyboard_double_arrow_up_rounded,
          chipBackground: colors.primaryContainer,
          chipForeground: colors.onPrimaryContainer,
        );

      case TaskPriorityState.low:
        return TaskPriorityStyle(
          icon: Icons.keyboard_arrow_up_rounded,
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

class _TaskCheckButton extends StatelessWidget {
  const _TaskCheckButton({
    required this.done,
    required this.style,
    required this.onPressed,
  });

  final bool done;
  final TaskDeadlineStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: done ? 'Mark open' : 'Complete task',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: style.buttonBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: style.accentColor.withValues(alpha: 0.20),
            ),
          ),
          child: Icon(
            done ? Icons.check_circle : style.icon,
            color: style.buttonForeground,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

enum _TaskAction { edit, delete }
