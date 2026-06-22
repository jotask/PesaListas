import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/design/list_type_style.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/design/app_list_type_badge.dart';

class ListDetailHeader extends StatelessWidget {
  const ListDetailHeader({
    super.key,
    required this.listName,
    this.listDescription,
    required this.config,
    required this.onBack,
    required this.onEdit,
    this.actions = const [],
  });

  final String listName;
  final String? listDescription;
  final AppListTypeConfig config;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ListTypeStyle.of(config.value);

    final description = listDescription?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: style.gradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: style.accent.withValues(alpha: 0.16)),
              boxShadow: [
                BoxShadow(
                  color: style.accent.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.16 : 0.10,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.arrow_back,
                      tooltip: context.l10n.back,
                      onPressed: onBack,
                      foregroundColor: style.onSoft,
                    ),
                    const Spacer(),
                    ...actions,
                    const SizedBox(width: AppSpacing.xs),
                    _HeaderIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: context.l10n.editList,
                      onPressed: onEdit,
                      foregroundColor: style.onSoft,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: style.accent,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: style.accent.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(config.icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppListTypeBadge(listType: config.value),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            listName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: style.onSoft,
                              fontWeight: FontWeight.w900,
                              height: 1.02,
                            ),
                          ),
                          if (hasDescription) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: style.onSoft.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.foregroundColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.52),
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      icon: Icon(icon),
    );
  }
}
