import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/item_text.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:pesalistas/widgets/common/app_state_pill.dart';
import 'package:pesalistas/widgets/design/app_surface.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  });

  final Map<String, dynamic> item;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  bool get isDone {
    return AppItemStatus.isDone(item[AppItemFields.status]);
  }

  String title(BuildContext context) {
    return AppItemText.title(item, fallback: context.l10n.untitledItem);
  }

  String? description() {
    return AppItemText.description(item);
  }

  String stateLabel(BuildContext context) {
    return isDone ? context.l10n.done : context.l10n.open;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descriptionText = description();

    final accent = isDone
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppSurface(
        padding: EdgeInsets.zero,
        borderColor: isDone
            ? theme.colorScheme.outlineVariant.withValues(alpha: 0.42)
            : accent.withValues(alpha: 0.18),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Opacity(
            opacity: isDone ? 0.72 : 1,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompletionButton(
                        done: isDone,
                        accent: accent,
                        onPressed: onComplete,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              descriptionText ?? 'Tap to edit',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: descriptionText == null
                                    ? theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.72)
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      PopupMenuButton<_ItemAction>(
                        tooltip: 'More options',
                        icon: Icon(
                          Icons.more_horiz,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _ItemAction.edit:
                              onEdit();
                              break;
                            case _ItemAction.delete:
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _ItemAction.edit,
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined),
                                const SizedBox(width: AppSpacing.sm),
                                Text(context.l10n.editItem),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _ItemAction.delete,
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline),
                                const SizedBox(width: AppSpacing.sm),
                                Text(context.l10n.deleteItem),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      AppStatePill(label: stateLabel(context), active: isDone),
                      const SizedBox(width: AppSpacing.xs),
                      const AppMetaPill(
                        icon: Icons.notes_outlined,
                        label: 'General',
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: onComplete,
                        icon: Icon(
                          isDone ? Icons.undo : Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(
                          isDone
                              ? context.l10n.markAsOpen
                              : context.l10n.markAsDone,
                        ),
                      ),
                    ],
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

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({
    required this.done,
    required this.accent,
    required this.onPressed,
  });

  final bool done;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: done ? context.l10n.markAsOpen : context.l10n.markAsDone,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: done
                ? accent.withValues(alpha: 0.14)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: done
                  ? accent.withValues(alpha: 0.28)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? accent : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

enum _ItemAction { edit, delete }
