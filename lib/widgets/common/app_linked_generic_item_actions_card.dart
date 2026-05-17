import 'package:flutter/material.dart';

class AppLinkedGenericItemActionsCard extends StatelessWidget {
  const AppLinkedGenericItemActionsCard({
    super.key,
    required this.catalogItemId,
    required this.catalogItemName,
    required this.defaultUnit,
    required this.linkedTitle,
    required this.emptyTitle,
    required this.defaultUnitLabelBuilder,
    required this.linkedHelperText,
    required this.emptyHelperText,
    required this.changeLabel,
    required this.linkLabel,
    required this.savePriceLabel,
    required this.removeLabel,
    required this.onSelectGenericItem,
    required this.onClearGenericItem,
    required this.onSavePrice,
  });

  final String? catalogItemId;
  final String? catalogItemName;
  final String? defaultUnit;

  final String linkedTitle;
  final String emptyTitle;
  final String Function(String defaultUnit) defaultUnitLabelBuilder;
  final String linkedHelperText;
  final String emptyHelperText;
  final String changeLabel;
  final String linkLabel;
  final String savePriceLabel;
  final String removeLabel;

  final VoidCallback onSelectGenericItem;
  final VoidCallback? onClearGenericItem;
  final VoidCallback? onSavePrice;

  bool get hasGenericItemData {
    return catalogItemId != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.category_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catalogItemName ??
                            (hasGenericItemData ? linkedTitle : emptyTitle),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (defaultUnit != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          defaultUnitLabelBuilder(defaultUnit!),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        hasGenericItemData ? linkedHelperText : emptyHelperText,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: onSelectGenericItem,
                  icon: const Icon(Icons.category_outlined),
                  label: Text(hasGenericItemData ? changeLabel : linkLabel),
                ),
                if (onSavePrice != null) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: onSavePrice,
                    icon: const Icon(Icons.euro_outlined),
                    label: Text(savePriceLabel),
                  ),
                ],
                if (onClearGenericItem != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onClearGenericItem,
                    icon: const Icon(Icons.link_off_outlined),
                    label: Text(removeLabel),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
