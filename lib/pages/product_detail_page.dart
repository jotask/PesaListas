import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/fields/product_fields.dart';
import 'package:pesalistas/core/fields/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/repositories/shopping_repository.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product, this.groupId});

  final Map<String, dynamic> product;
  final String? groupId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductRepository productRepository;

  late Map<String, dynamic> product;

  late final ShoppingRepository shoppingRepository;

  final TextEditingController shoppingNameController = TextEditingController();
  final TextEditingController shoppingQuantityController =
      TextEditingController(text: '1');
  final TextEditingController shoppingUnitController = TextEditingController();
  final TextEditingController shoppingPriceController = TextEditingController();

  bool addingToShoppingList = false;
  String? shoppingValidationMessage;

  bool loadingPrices = true;
  String? priceErrorMessage;
  List<Map<String, dynamic>> prices = [];

  bool refreshing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    product = Map<String, dynamic>.from(widget.product);

    productRepository = ProductRepository(
      Supabase.instance.client,
      useStaging: AppConfig.useOpenFoodFactsStaging,
    );

    shoppingRepository = ShoppingRepository(Supabase.instance.client);
    prefillShoppingFields();

    loadPrices();
  }

  @override
  void dispose() {
    shoppingNameController.dispose();
    shoppingQuantityController.dispose();
    shoppingUnitController.dispose();
    shoppingPriceController.dispose();
    super.dispose();
  }

  bool get hasGroupContext {
    final value = widget.groupId;
    return value != null && value.trim().isNotEmpty;
  }

  bool get productWasFound {
    return product[AppProductFields.status] == AppProductStatus.found;
  }

  Map<String, dynamic>? get latestPrice {
    if (prices.isEmpty) return null;

    return prices.first;
  }

  void prefillShoppingFields() {
    shoppingNameController.text =
        AppValueParsing.textOrNull(product[AppProductFields.name]) ??
        AppValueParsing.textOrNull(product[AppProductFields.barcode]) ??
        '';

    if (shoppingQuantityController.text.trim().isEmpty) {
      shoppingQuantityController.text = '1';
    }

    final price = latestPrice?[AppProductPriceFields.price];

    if (price != null && shoppingPriceController.text.trim().isEmpty) {
      shoppingPriceController.text = price.toString();
    }
  }

  Future<void> loadPrices() async {
    if (barcode.isEmpty) {
      setState(() {
        prices = [];
        loadingPrices = false;
      });
      return;
    }

    setState(() {
      loadingPrices = true;
      priceErrorMessage = null;
    });

    try {
      final result = await productRepository.getPricesForProduct(
        barcode: barcode,
      );

      if (!mounted) return;

      setState(() {
        prices = result;
        loadingPrices = false;
        prefillShoppingFields();
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        priceErrorMessage = error.toString();
        loadingPrices = false;
      });
    }
  }

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  String get barcode {
    return text(product[AppProductFields.barcode], fallback: '');
  }

  String get name {
    return text(
      product[AppProductFields.name],
      fallback: context.l10n.unknownProduct,
    );
  }

  String get imageUrl {
    return text(product[AppProductFields.imageUrl], fallback: '');
  }

  String prettyRawJson() {
    final rawJson = product[AppProductFields.rawJson];

    if (rawJson == null) {
      return context.l10n.noRawJsonStored;
    }

    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(rawJson);
    } catch (_) {
      return rawJson.toString();
    }
  }

  Future<void> refreshProduct() async {
    if (refreshing || barcode.isEmpty) return;

    setState(() {
      refreshing = true;
      errorMessage = null;
    });

    try {
      final refreshed = await productRepository.getProductByBarcode(
        barcode,
        forceRefresh: true,
      );

      if (!mounted) return;

      if (refreshed != null) {
        setState(() => product = refreshed);
        prefillShoppingFields();
      }
      await loadPrices();
    } catch (error) {
      if (!mounted) return;

      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => refreshing = false);
      }
    }
  }

  Future<void> addToShoppingList() async {
    final groupId = widget.groupId;

    setState(() => shoppingValidationMessage = null);

    if (groupId == null || groupId.trim().isEmpty) {
      setState(() {
        shoppingValidationMessage =
            context.l10n.openProductFromShoppingListToAddIt;
      });
      return;
    }

    if (!productWasFound) {
      setState(() {
        shoppingValidationMessage = context.l10n.cannotAddUnknownProduct;
      });
      return;
    }

    final itemName = shoppingNameController.text.trim();

    if (itemName.isEmpty) {
      setState(() {
        shoppingValidationMessage = context.l10n.shoppingItemNameRequired;
      });
      return;
    }

    final quantityText = shoppingQuantityController.text.trim();
    final quantity = quantityText.isEmpty
        ? null
        : double.tryParse(quantityText.replaceAll(',', '.'));

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() {
        shoppingValidationMessage = context.l10n.quantityMustBeANumber;
      });
      return;
    }

    final priceText = shoppingPriceController.text.trim();
    final estimatedUnitPrice = priceText.isEmpty
        ? null
        : double.tryParse(priceText.replaceAll(',', '.'));

    if (priceText.isNotEmpty && estimatedUnitPrice == null) {
      setState(() {
        shoppingValidationMessage = context.l10n.priceMustBeValidNumber;
      });
      return;
    }

    if (estimatedUnitPrice != null && estimatedUnitPrice < 0) {
      setState(() {
        shoppingValidationMessage = context.l10n.priceCannotBeNegative;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => addingToShoppingList = true);

    try {
      await shoppingRepository.createShoppingItemFromProduct(
        groupId: groupId,
        name: itemName,
        quantity: quantity,
        unit: AppValueParsing.textOrNull(shoppingUnitController.text),
        barcode: AppValueParsing.textOrNull(product[AppProductFields.barcode]),
        productName: AppValueParsing.textOrNull(product[AppProductFields.name]),
        productImageUrl: AppValueParsing.textOrNull(
          product[AppProductFields.imageUrl],
        ),
        estimatedUnitPrice: estimatedUnitPrice,
        priceCurrency: AppConfig.defaultCurrency,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.addedToShoppingList)));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        shoppingValidationMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => addingToShoppingList = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawJson = prettyRawJson();

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            onPressed: refreshing ? null : refreshProduct,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.requestAgain,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: refreshProduct,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProductDetailHeaderCard(
                name: name,
                brand: text(product[AppProductFields.brand]),
                quantity: text(product[AppProductFields.quantity]),
                status: text(product[AppProductFields.status]),
                imageUrl: imageUrl,
                refreshing: refreshing,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                _ProductDetailErrorCard(message: errorMessage!),
              ],
              const SizedBox(height: 12),
              _ProductPriceHistoryCard(
                loading: loadingPrices,
                errorMessage: priceErrorMessage,
                prices: prices,
                onRefresh: loadPrices,
              ),
              if (hasGroupContext) ...[
                const SizedBox(height: 12),
                _AddProductToShoppingCard(
                  productWasFound: productWasFound,
                  loading: addingToShoppingList,
                  nameController: shoppingNameController,
                  quantityController: shoppingQuantityController,
                  unitController: shoppingUnitController,
                  priceController: shoppingPriceController,
                  validationMessage: shoppingValidationMessage,
                  onAdd: addToShoppingList,
                ),
              ],
              const SizedBox(height: 12),
              _ProductInfoCard(
                rows: [
                  _ProductInfoRowData(
                    label: context.l10n.barcode,
                    value: text(product[AppProductFields.barcode]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.productBrand,
                    value: text(product[AppProductFields.brand]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.quantity,
                    value: text(product[AppProductFields.quantity]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.productCategories,
                    value: text(product[AppProductFields.categories]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.nutriscore,
                    value: text(product[AppProductFields.nutriscore]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.novaGroup,
                    value: text(product[AppProductFields.novaGroup]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.ecoscore,
                    value: text(product[AppProductFields.ecoscore]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.productSource,
                    value: text(product[AppProductFields.source]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.productStatus,
                    value: text(product[AppProductFields.status]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.fetchedAt,
                    value: text(product[AppProductFields.fetchedAt]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.createdAt,
                    value: text(product[AppProductFields.createdAt]),
                  ),
                  _ProductInfoRowData(
                    label: context.l10n.updatedAt,
                    value: text(product[AppProductFields.updatedAt]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RawJsonCard(rawJson: rawJson),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetailHeaderCard extends StatelessWidget {
  const _ProductDetailHeaderCard({
    required this.name,
    required this.brand,
    required this.quantity,
    required this.status,
    required this.imageUrl,
    required this.refreshing,
  });

  final String name;
  final String brand;
  final String quantity;
  final String status;
  final String imageUrl;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductDetailImage(imageUrl: imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(brand, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppMetaPill(icon: Icons.info_outline, label: status),
                      if (quantity != '—')
                        AppMetaPill(
                          icon: Icons.scale_outlined,
                          label: quantity,
                        ),
                    ],
                  ),
                  if (refreshing) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailImage extends StatelessWidget {
  const _ProductDetailImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 42,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return CircleAvatar(
            radius: 42,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.rows});

  final List<_ProductInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [for (final row in rows) _ProductInfoRow(row: row)],
        ),
      ),
    );
  }
}

class _ProductInfoRowData {
  const _ProductInfoRowData({required this.label, required this.value});

  final String label;
  final String value;
}

class _ProductInfoRow extends StatelessWidget {
  const _ProductInfoRow({required this.row});

  final _ProductInfoRowData row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              row.label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(child: SelectableText(row.value)),
        ],
      ),
    );
  }
}

class _RawJsonCard extends StatefulWidget {
  const _RawJsonCard({required this.rawJson});

  final String rawJson;

  @override
  State<_RawJsonCard> createState() => _RawJsonCardState();
}

class _RawJsonCardState extends State<_RawJsonCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawJson = widget.rawJson;

    final preview = rawJson.length > 1200 && !expanded
        ? '${rawJson.substring(0, 1200)}\n...'
        : rawJson;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.data_object_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.rawJson,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (rawJson.length > 1200)
                  TextButton(
                    onPressed: () {
                      setState(() => expanded = !expanded);
                    },
                    child: Text(
                      expanded ? context.l10n.collapse : context.l10n.expand,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                preview,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailErrorCard extends StatelessWidget {
  const _ProductDetailErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.errorContainer,
              child: Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ProductPriceHistoryCard extends StatelessWidget {
  const _ProductPriceHistoryCard({
    required this.loading,
    required this.errorMessage,
    required this.prices,
    required this.onRefresh,
  });

  final bool loading;
  final String? errorMessage;
  final List<Map<String, dynamic>> prices;
  final VoidCallback onRefresh;

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
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
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.euro_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.priceHistory,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: loading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: context.l10n.refreshPrices,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading)
              Row(
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.loadingPrices)),
                ],
              )
            else if (errorMessage != null)
              _ProductDetailInlineError(message: errorMessage!)
            else if (prices.isEmpty)
              Text(
                context.l10n.noPricesSavedForProduct,
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: [
                  for (final price in prices)
                    _ProductPriceHistoryTile(price: price),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductPriceHistoryTile extends StatelessWidget {
  const _ProductPriceHistoryTile({required this.price});

  final Map<String, dynamic> price;

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amount = text(price[AppProductPriceFields.price]);
    final currency = text(
      price[AppProductPriceFields.currency],
      fallback: AppConfig.defaultCurrency,
    );
    final store = text(price[AppProductPriceFields.storeName]);
    final note = text(price[AppProductPriceFields.note], fallback: '');
    final observedAt = text(price[AppProductPriceFields.observedAt]);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.receipt_long_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$amount $currency',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  store == '—' ? context.l10n.unknownStore : store,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 3),
                Text(observedAt, style: theme.textTheme.bodySmall),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(note, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailInlineError extends StatelessWidget {
  const _ProductDetailInlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProductToShoppingCard extends StatelessWidget {
  const _AddProductToShoppingCard({
    required this.productWasFound,
    required this.loading,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.priceController,
    required this.validationMessage,
    required this.onAdd,
  });

  final bool productWasFound;
  final bool loading;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController priceController;
  final String? validationMessage;
  final VoidCallback onAdd;

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
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.add_shopping_cart_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.addToShoppingList,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(context.l10n.createShoppingItemFromCachedProduct),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              enabled: productWasFound && !loading,
              decoration: InputDecoration(
                labelText: context.l10n.name,
                prefixIcon: Icon(Icons.shopping_basket_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    enabled: productWasFound && !loading,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.quantity,
                      hintText: '1',
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    enabled: productWasFound && !loading,
                    decoration: InputDecoration(
                      labelText: context.l10n.unit,
                      hintText: context.l10n.unitPcsHint,
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              enabled: productWasFound && !loading,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.estimatedUnitPrice,
                hintText: '2.49',
                prefixIcon: const Icon(Icons.euro_outlined),
                suffixText: AppConfig.defaultCurrency,
              ),
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              _ProductDetailInlineError(message: validationMessage!),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: productWasFound && !loading ? onAdd : null,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_shopping_cart_outlined),
              label: Text(
                loading ? context.l10n.adding : context.l10n.addToShoppingList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
