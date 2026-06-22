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

class ChoreItemCard extends StatelessWidget {
  const ChoreItemCard({
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
    return AppItemText.title(item, fallback: 'Untitled chore');
  }

  String? get description {
    return AppItemText.description(item);
  }

  bool get isDone {
    return AppItemStatus.isDone(item[AppItemFields.status]);
  }

  String? get recurrenceType {
    final value = item[AppItemFields.recurrenceType]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  int? get recurrenceInterval {
    return AppValueParsing.intOrNull(item[AppItemFields.recurrenceInterval]);
  }

  DateTime? get nextDueDate {
    return AppDateOnly.fromValue(item[AppItemFields.nextDueAt]);
  }

  String get recurrenceText {
    final type = recurrenceType;

    if (type == null) return 'Does not repeat';

    if (type == 'daily') return 'Daily';
    if (type == 'weekly') return 'Weekly';
    if (type == 'monthly') return 'Monthly';

    if (type == 'every_n_days') {
      return 'Every ${recurrenceInterval ?? 1} days';
    }

    return 'Repeats';
  }

  String get formattedNextDue {
    final formatted = AppDateFormatting.yyyyMmDdFromValue(
      item[AppItemFields.nextDueAt],
    );

    if (formatted.isEmpty) {
      return 'No due date';
    }

    return formatted;
  }

  bool get hasRecurrence {
    return recurrenceType != null;
  }

  bool get hasNextDueDate {
    return nextDueDate != null;
  }

  bool get isOverdue {
    if (isDone) return false;

    return AppDateOnly.isBeforeToday(nextDueDate);
  }

  bool get isDueToday {
    if (isDone) return false;

    return AppDateOnly.isToday(nextDueDate);
  }

  bool get isUpcoming {
    if (isDone) return false;

    return AppDateOnly.isAfterToday(nextDueDate);
  }

  ChoreDueState get dueState {
    if (isDone) return ChoreDueState.done;
    if (isOverdue) return ChoreDueState.overdue;
    if (isDueToday) return ChoreDueState.today;
    if (isUpcoming) return ChoreDueState.upcoming;

    return ChoreDueState.none;
  }

  String get primaryActionLabel {
    if (isDone) return 'Mark open';
    if (isOverdue || isDueToday) return 'Complete now';

    return 'Complete chore';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listStyle = ListTypeStyle.of(AppListTypes.chores.value);
    final dueStyle = ChoreDueStyle.fromState(context, dueState);
    final descriptionText = description;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppSurface(
        padding: EdgeInsets.zero,
        borderColor: dueStyle.borderColor,
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
                      color: dueStyle.accentColor,
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
                              _ChoreCheckButton(
                                done: isDone,
                                style: dueStyle,
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
                                        if (dueStyle.label.isNotEmpty)
                                          _StatusBadge(
                                            label: dueStyle.label,
                                            icon: dueStyle.icon,
                                            backgroundColor:
                                                dueStyle.pillBackground,
                                            foregroundColor:
                                                dueStyle.pillForeground,
                                          ),
                                        if (hasRecurrence)
                                          _StatusBadge(
                                            label: recurrenceText,
                                            icon: Icons.repeat_rounded,
                                            backgroundColor: theme
                                                .colorScheme
                                                .tertiaryContainer,
                                            foregroundColor: theme
                                                .colorScheme
                                                .onTertiaryContainer,
                                          ),
                                      ],
                                    ),
                                    if (dueStyle.label.isNotEmpty ||
                                        hasRecurrence)
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
                              PopupMenuButton<_ChoreAction>(
                                tooltip: 'More options',
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onSelected: (action) {
                                  switch (action) {
                                    case _ChoreAction.edit:
                                      onEdit();
                                      break;
                                    case _ChoreAction.delete:
                                      onDelete();
                                      break;
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: _ChoreAction.edit,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Edit chore'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _ChoreAction.delete,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline),
                                        SizedBox(width: AppSpacing.sm),
                                        Text('Delete chore'),
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
                                icon: Icons.repeat_rounded,
                                label: recurrenceText,
                                filled: hasRecurrence,
                                backgroundColor: hasRecurrence
                                    ? theme.colorScheme.tertiaryContainer
                                    : null,
                                foregroundColor: hasRecurrence
                                    ? theme.colorScheme.onTertiaryContainer
                                    : null,
                              ),
                              AppMetaPill(
                                icon: dueStyle.dateIcon,
                                label: hasNextDueDate
                                    ? 'Next due $formattedNextDue'
                                    : formattedNextDue,
                                filled: hasNextDueDate,
                                backgroundColor: hasNextDueDate
                                    ? dueStyle.chipBackground
                                    : null,
                                foregroundColor: hasNextDueDate
                                    ? dueStyle.chipForeground
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
                                tooltip: 'Edit chore',
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

enum ChoreDueState { none, overdue, today, upcoming, done }

class ChoreDueStyle {
  const ChoreDueStyle({
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

  factory ChoreDueStyle.fromState(BuildContext context, ChoreDueState state) {
    final colors = Theme.of(context).colorScheme;

    switch (state) {
      case ChoreDueState.overdue:
        return ChoreDueStyle(
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

      case ChoreDueState.today:
        return ChoreDueStyle(
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

      case ChoreDueState.upcoming:
        return ChoreDueStyle(
          icon: Icons.home_repair_service_rounded,
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

      case ChoreDueState.done:
        return ChoreDueStyle(
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

      case ChoreDueState.none:
        return ChoreDueStyle(
          icon: Icons.cleaning_services_rounded,
          dateIcon: Icons.event_outlined,
          label: '',
          accentColor: colors.secondary.withValues(alpha: 0.55),
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

class _ChoreCheckButton extends StatelessWidget {
  const _ChoreCheckButton({
    required this.done,
    required this.style,
    required this.onPressed,
  });

  final bool done;
  final ChoreDueStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: done ? 'Mark open' : 'Complete chore',
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

enum _ChoreAction { edit, delete }
