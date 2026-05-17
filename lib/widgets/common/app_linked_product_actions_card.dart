import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/app_info_message.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';

class AppLinkedProductActionsCard extends StatelessWidget {
  const AppLinkedProductActionsCard({
    super.key,
    required this.barcode,
    required this.productName,
    required this.productImageUrl,
    required this.loading,
    required this.message,
    required this.linkedHelperText,
    required this.emptyHelperText,
    required this.onSelectProduct,
    required this.onClearProduct,
  });

  final String? barcode;
  final String? productName;
  final String? productImageUrl;
  final bool loading;
  final String? message;
  final String linkedHelperText;
  final String emptyHelperText;
  final VoidCallback onSelectProduct;
  final VoidCallback? onClearProduct;

  bool get hasProductData {
    return barcode != null || productName != null || productImageUrl != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = productImageUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppNetworkImageThumbnail(
                  imageUrl: imageUrl,
                  width: 58,
                  height: 58,
                  borderRadius: 14,
                  fallbackIcon: Icons.inventory_2_outlined,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName ??
                            (hasProductData
                                ? context.l10n.linkedProduct
                                : context.l10n.noProductLinked),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (barcode != null) ...[
                        const SizedBox(height: 4),
                        SelectableText(
                          barcode!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        hasProductData ? linkedHelperText : emptyHelperText,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              AppInfoMessage(message: message!),
            ],
            if (loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading ? null : onSelectProduct,
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(
                      hasProductData
                          ? context.l10n.changeProduct
                          : context.l10n.linkProduct,
                    ),
                  ),
                ),
                if (onClearProduct != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: loading ? null : onClearProduct,
                    icon: const Icon(Icons.link_off_outlined),
                    tooltip: context.l10n.removeProductLink,
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
