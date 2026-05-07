import 'package:flutter/material.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/models/open_food_facts_product.dart';
import 'package:pesalistas/pages/barcode_scanner_page.dart';
import 'package:pesalistas/repositories/open_food_facts_repository.dart';

class ProductScannerPage extends StatefulWidget {
  const ProductScannerPage({super.key});

  @override
  State<ProductScannerPage> createState() => _ProductScannerPageState();
}

class _ProductScannerPageState extends State<ProductScannerPage> {
  static const repository = OpenFoodFactsRepository(useStaging: false);

  String? scannedBarcode;
  OpenFoodFactsProduct? product;
  bool loadingProduct = false;
  bool productNotFound = false;
  Object? lookupError;

  Future<void> scanBarcode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (code == null || code.trim().isEmpty) return;

    await lookupBarcode(code.trim());
  }

  Future<void> lookupBarcode(String barcode) async {
    setState(() {
      scannedBarcode = barcode;
      product = null;
      productNotFound = false;
      lookupError = null;
      loadingProduct = true;
    });

    try {
      final result = await repository.getProductByBarcode(barcode);

      if (!mounted) return;

      setState(() {
        product = result;
        productNotFound = result == null;
        loadingProduct = false;
      });
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToLoadProductInfo, error);

      setState(() {
        lookupError = error;
        loadingProduct = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final barcode = scannedBarcode;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.productScannerTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loadingProduct ? null : scanBarcode,
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(context.l10n.scanBarcode),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (barcode == null)
              _ScannerEmptyCard(onScan: scanBarcode)
            else ...[
              _ScannedBarcodeCard(
                barcode: barcode,
                onScanAgain: loadingProduct ? null : scanBarcode,
                onLookupAgain: loadingProduct
                    ? null
                    : () => lookupBarcode(barcode),
              ),
              const SizedBox(height: 12),
              if (loadingProduct)
                const _ProductLoadingCard()
              else if (lookupError != null)
                _ProductErrorCard(
                  error: lookupError!,
                  onRetry: () => lookupBarcode(barcode),
                )
              else if (productNotFound)
                _ProductNotFoundCard(
                  barcode: barcode,
                  onRetry: () => lookupBarcode(barcode),
                )
              else if (product != null)
                _ProductCard(product: product!),
            ],
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _ScannerEmptyCard extends StatelessWidget {
  const _ScannerEmptyCard({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.qr_code_scanner,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.noBarcodeScannedYet,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.scanBarcodeToReadProductCode,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(context.l10n.scanBarcode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannedBarcodeCard extends StatelessWidget {
  const _ScannedBarcodeCard({
    required this.barcode,
    required this.onScanAgain,
    required this.onLookupAgain,
  });

  final String barcode;
  final VoidCallback? onScanAgain;
  final VoidCallback? onLookupAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.barcodeScanned,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    barcode,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onLookupAgain,
                        icon: const Icon(Icons.cloud_download_outlined),
                        label: Text(context.l10n.requestAgain),
                      ),
                      OutlinedButton.icon(
                        onPressed: onScanAgain,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(context.l10n.scanAgain),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductLoadingCard extends StatelessWidget {
  const _ProductLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(context.l10n.loadingProductInfo)),
          ],
        ),
      ),
    );
  }
}

class _ProductNotFoundCard extends StatelessWidget {
  const _ProductNotFoundCard({required this.barcode, required this.onRetry});

  final String barcode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.search_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.productNotFound,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.productNotFoundSubtitle(barcode),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductErrorCard extends StatelessWidget {
  const _ProductErrorCard({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.errorContainer,
              child: Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.failedToLoadProductInfo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(error.toString(), style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final OpenFoodFactsProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = product.imageUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl == null)
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return CircleAvatar(
                          radius: 34,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(product.barcode),
                      if (product.brand != null) ...[
                        const SizedBox(height: 8),
                        _ProductInfoLine(
                          icon: Icons.business_outlined,
                          label: context.l10n.productBrand,
                          value: product.brand!,
                        ),
                      ],
                      if (product.quantity != null)
                        _ProductInfoLine(
                          icon: Icons.scale_outlined,
                          label: context.l10n.productQuantity,
                          value: product.quantity!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (product.categories != null)
              _ProductInfoBlock(
                icon: Icons.category_outlined,
                label: context.l10n.productCategories,
                value: product.categories!,
              ),
            if (product.ingredients != null)
              _ProductInfoBlock(
                icon: Icons.receipt_long_outlined,
                label: context.l10n.productIngredients,
                value: product.ingredients!,
              ),
            if (product.allergens != null)
              _ProductInfoBlock(
                icon: Icons.warning_amber_outlined,
                label: context.l10n.productAllergens,
                value: product.allergens!,
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (product.nutriscoreGrade != null)
                  _ProductPill(
                    icon: Icons.health_and_safety_outlined,
                    label: context.l10n.nutriscoreLabel(
                      product.nutriscoreGrade!.toUpperCase(),
                    ),
                  ),
                if (product.novaGroup != null)
                  _ProductPill(
                    icon: Icons.science_outlined,
                    label: context.l10n.novaGroupLabel(product.novaGroup!),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _NutritionSection(product: product),
          ],
        ),
      ),
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.product});

  final OpenFoodFactsProduct product;

  @override
  Widget build(BuildContext context) {
    final items = <_NutritionItem>[
      _NutritionItem(context.l10n.energy, product.energyKcal100g),
      _NutritionItem(context.l10n.fat, product.fat100g),
      _NutritionItem(context.l10n.saturatedFat, product.saturatedFat100g),
      _NutritionItem(context.l10n.carbohydrates, product.carbohydrates100g),
      _NutritionItem(context.l10n.sugars, product.sugars100g),
      _NutritionItem(context.l10n.proteins, product.proteins100g),
      _NutritionItem(context.l10n.salt, product.salt100g),
      _NutritionItem(context.l10n.fiber, product.fiber100g),
    ].where((item) => item.value != null).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      leading: const Icon(Icons.monitor_heart_outlined),
      title: Text(context.l10n.basicNutrition),
      children: [
        const SizedBox(height: 8),
        for (final item in items)
          _NutritionRow(label: item.label, value: item.value!),
      ],
    );
  }
}

class _NutritionItem {
  const _NutritionItem(this.label, this.value);

  final String label;
  final String? value;
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }
}

class _ProductInfoLine extends StatelessWidget {
  const _ProductInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text('$label: $value', style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ProductInfoBlock extends StatelessWidget {
  const _ProductInfoBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                SelectableText(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPill extends StatelessWidget {
  const _ProductPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductFieldNode extends StatelessWidget {
  const _ProductFieldNode({
    required this.name,
    required this.value,
    required this.depth,
  });

  final String name;
  final dynamic value;
  final int depth;

  bool get isObject => value is Map<String, dynamic>;

  bool get isList => value is List;

  bool get isEmptyValue {
    final currentValue = value;

    if (currentValue == null) return true;

    if (currentValue is String) {
      return currentValue.trim().isEmpty;
    }

    if (currentValue is List) {
      return currentValue.isEmpty;
    }

    if (currentValue is Map) {
      return currentValue.isEmpty;
    }

    return false;
  }

  String get displayValue {
    final currentValue = value;

    if (currentValue == null) return 'null';

    if (currentValue is String) {
      return currentValue;
    }

    if (currentValue is num || currentValue is bool) {
      return currentValue.toString();
    }

    if (currentValue is List) {
      return '${currentValue.length} items';
    }

    if (currentValue is Map) {
      return '${currentValue.length} fields';
    }

    return currentValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmptyValue) {
      return const SizedBox.shrink();
    }

    if (isObject) {
      final map = value as Map<String, dynamic>;
      final entries = map.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      return _NestedFieldTile(
        name: name,
        subtitle: '${entries.length} fields',
        depth: depth,
        children: [
          for (final entry in entries)
            _ProductFieldNode(
              name: entry.key,
              value: entry.value,
              depth: depth + 1,
            ),
        ],
      );
    }

    if (isList) {
      final list = value as List;

      return _NestedFieldTile(
        name: name,
        subtitle: '${list.length} items',
        depth: depth,
        children: [
          for (var index = 0; index < list.length; index++)
            _ProductFieldNode(
              name: '[$index]',
              value: list[index],
              depth: depth + 1,
            ),
        ],
      );
    }

    return _LeafFieldTile(name: name, value: displayValue, depth: depth);
  }
}

class _NestedFieldTile extends StatelessWidget {
  const _NestedFieldTile({
    required this.name,
    required this.subtitle,
    required this.depth,
    required this.children,
  });

  final String name;
  final String subtitle;
  final int depth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: depth * 12.0),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          leading: Icon(
            Icons.folder_outlined,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          children: children,
        ),
      ),
    );
  }
}

class _LeafFieldTile extends StatelessWidget {
  const _LeafFieldTile({
    required this.name,
    required this.value,
    required this.depth,
  });

  final String name;
  final String value;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: depth * 12.0, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              name,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
