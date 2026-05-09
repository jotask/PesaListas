import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/value_parsing.dart';

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

  String title(BuildContext context) {
    final value = item[AppItemFields.title]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.untitledChore;
    }

    return value.trim();
  }

  String? get description {
    final value = item[AppItemFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
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
    final parsed = AppValueParsing.dateTimeOrNull(
      item[AppItemFields.nextDueAt],
    );

    if (parsed == null) return null;

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime get today {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  String recurrenceText(BuildContext context) {
    return AppRecurrenceTypes.displayText(
      context,
      recurrenceType,
      recurrenceInterval,
    );
  }

  String nextDueText(BuildContext context) {
    final formatted = AppDateFormatting.yyyyMmDdFromValue(
      item[AppItemFields.nextDueAt],
    );

    if (formatted.isEmpty) {
      return context.l10n.noDueDate;
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
    final due = nextDueDate;

    if (due == null) return false;

    return due.isBefore(today);
  }

  bool get isDueToday {
    final due = nextDueDate;

    if (due == null) return false;

    return due == today;
  }

  bool get isUpcoming {
    final due = nextDueDate;

    if (due == null) return false;

    return due.isAfter(today);
  }

  ChoreDueState get dueState {
    if (isOverdue) return ChoreDueState.overdue;
    if (isDueToday) return ChoreDueState.today;
    if (isUpcoming) return ChoreDueState.upcoming;

    return ChoreDueState.none;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueStyle = ChoreDueStyle.fromState(context, dueState);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: dueStyle.avatarBackground,
                    child: Icon(
                      dueStyle.icon,
                      color: dueStyle.avatarForeground,
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (dueState != ChoreDueState.none)
                              _DuePill(
                                label: dueStyle.label,
                                backgroundColor: dueStyle.pillBackground,
                                foregroundColor: dueStyle.pillForeground,
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
                    tooltip: context.l10n.deleteChore,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoreInfoChip(
                    icon: Icons.repeat,
                    label: hasRecurrence
                        ? recurrenceText(context)
                        : context.l10n.doesNotRepeat,
                    filled: hasRecurrence,
                  ),
                  _ChoreInfoChip(
                    icon: dueStyle.dateIcon,
                    label: hasNextDueDate
                        ? context.l10n.nextDueDate(nextDueText(context))
                        : nextDueText(context),
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
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onComplete,
                      icon: Icon(Icons.check_circle_outline),
                      label: Text(
                        isOverdue || isDueToday
                            ? context.l10n.completeNow
                            : context.l10n.completeChore,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined),
                    tooltip: context.l10n.editChore,
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

enum ChoreDueState { none, overdue, today, upcoming }

class ChoreDueStyle {
  const ChoreDueStyle({
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

  factory ChoreDueStyle.fromState(BuildContext context, ChoreDueState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    switch (state) {
      case ChoreDueState.overdue:
        return ChoreDueStyle(
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

      case ChoreDueState.today:
        return ChoreDueStyle(
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

      case ChoreDueState.upcoming:
        return ChoreDueStyle(
          icon: Icons.cleaning_services,
          dateIcon: Icons.event_outlined,
          label: context.l10n.upcoming,
          avatarBackground: colors.secondaryContainer,
          avatarForeground: colors.onSecondaryContainer,
          pillBackground: colors.secondaryContainer,
          pillForeground: colors.onSecondaryContainer,
          chipBackground: colors.secondaryContainer,
          chipForeground: colors.onSecondaryContainer,
        );

      case ChoreDueState.none:
        return ChoreDueStyle(
          icon: Icons.cleaning_services,
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

class _DuePill extends StatelessWidget {
  const _DuePill({
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

class _ChoreInfoChip extends StatelessWidget {
  const _ChoreInfoChip({
    required this.icon,
    required this.label,
    this.filled = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedBackgroundColor =
        backgroundColor ??
        (filled
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest);

    final resolvedForegroundColor =
        foregroundColor ??
        (filled
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: resolvedForegroundColor),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
              color: resolvedForegroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
