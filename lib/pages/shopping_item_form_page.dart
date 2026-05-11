import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/product_fields.dart';
import 'package:pesalistas/core/product_price_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/product_catalog_page.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/catalog_item_fields.dart';
import 'package:pesalistas/pages/catalog_item_picker_page.dart';

class ShoppingItemFormPageResult {
  const ShoppingItemFormPageResult({
    required this.name,
    this.quantity,
    this.unit,
    this.estimatedUnitPrice,
    this.priceCurrency = AppConfig.defaultCurrency,
    this.barcode,
    this.catalogItemId,
    this.productName,
    this.productImageUrl,
  });

  final String name;
  final double? quantity;
  final String? unit;
  final double? estimatedUnitPrice;
  final String priceCurrency;
  final String? barcode;
  final String? catalogItemId;
  final String? productName;
  final String? productImageUrl;
}

class ShoppingItemFormPage extends StatefulWidget {
  const ShoppingItemFormPage({super.key, required this.groupId, this.item});

  final String groupId;
  final Map<String, dynamic>? item;

  @override
  State<ShoppingItemFormPage> createState() => _ShoppingItemFormPageState();
}

class _ShoppingItemFormPageState extends State<ShoppingItemFormPage> {
  late final ProductRepository productRepository;

  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController unitController;
  late final TextEditingController priceController;

  String? validationMessage;
  String? productLinkMessage;

  String? linkedBarcode;
  String? linkedProductName;
  String? linkedProductImageUrl;

  String? linkedCatalogItemId;
  String? linkedCatalogItemName;
  String? linkedCatalogItemDefaultUnit;

  bool loadingProductPrice = false;

  bool get isEditing => widget.item != null;

  String get priceCurrency {
    return textOrNull(widget.item?[AppShoppingItemFields.priceCurrency]) ??
        AppConfig.defaultCurrency;
  }

  bool get hasProductData {
    return linkedBarcode != null ||
        linkedProductName != null ||
        linkedProductImageUrl != null;
  }

  bool get hasGenericItemData {
    return linkedCatalogItemId != null;
  }

  bool get hasAnyLinkedItem {
    return hasProductData || hasGenericItemData;
  }

  @override
  void initState() {
    super.initState();

    productRepository = ProductRepository(
      Supabase.instance.client,
      useStaging: AppConfig.useOpenFoodFactsStaging,
    );

    final item = widget.item;

    linkedBarcode = textOrNull(item?[AppShoppingItemFields.barcode]);
    linkedProductName = textOrNull(item?[AppShoppingItemFields.productName]);
    linkedProductImageUrl = textOrNull(
      item?[AppShoppingItemFields.productImageUrl],
    );

    nameController = TextEditingController(
      text: item?[AppShoppingItemFields.name]?.toString() ?? '',
    );

    quantityController = TextEditingController(
      text: item?[AppShoppingItemFields.quantity]?.toString() ?? '',
    );

    unitController = TextEditingController(
      text: item?[AppShoppingItemFields.unit]?.toString() ?? '',
    );

    priceController = TextEditingController(
      text: item?[AppShoppingItemFields.estimatedUnitPrice]?.toString() ?? '',
    );

    linkedCatalogItemId = textOrNull(
      item?[AppShoppingItemFields.catalogItemId],
    );
    linkedCatalogItemName = textOrNull(item?[AppShoppingItemFields.name]);
    linkedCatalogItemDefaultUnit = textOrNull(
      item?[AppShoppingItemFields.unit],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null && productLinkMessage == null) return;

    setState(() {
      validationMessage = null;
      productLinkMessage = null;
    });
  }

  Future<void> selectGenericItem() async {
    final item = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const CatalogItemPickerPage()),
    );

    if (item == null) return;

    final catalogItemId = textOrNull(item[AppCatalogItemFields.id]);
    final catalogItemName = textOrNull(item[AppCatalogItemFields.name]);
    final defaultUnit = textOrNull(item[AppCatalogItemFields.defaultUnit]);

    if (catalogItemId == null || catalogItemName == null) return;

    setState(() {
      linkedCatalogItemId = catalogItemId;
      linkedCatalogItemName = catalogItemName;
      linkedCatalogItemDefaultUnit = defaultUnit;

      // Generic item and barcode product are alternatives for now.
      linkedBarcode = null;
      linkedProductName = null;
      linkedProductImageUrl = null;

      nameController.text = catalogItemName;

      if (defaultUnit != null && unitController.text.trim().isEmpty) {
        unitController.text = defaultUnit;
      }

      productLinkMessage = 'Generic item linked.';
      validationMessage = null;
    });
  }

  void clearGenericItemLink() {
    setState(() {
      linkedCatalogItemId = null;
      linkedCatalogItemName = null;
      linkedCatalogItemDefaultUnit = null;
      productLinkMessage = 'Generic item link removed.';
    });
  }

  double? parseOptionalDouble(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text.replaceAll(',', '.'));
  }

  double? currentQuantity() {
    return parseOptionalDouble(quantityController.text);
  }

  double? currentPrice() {
    return parseOptionalDouble(priceController.text);
  }

  double? currentEstimatedTotal() {
    final price = currentPrice();

    if (price == null) {
      return null;
    }

    final quantity = currentQuantity();

    if (quantity == null) {
      return price;
    }

    return quantity * price;
  }

  Future<void> selectProduct() async {
    final product = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) =>
            ProductCatalogPage(groupId: widget.groupId, selectionMode: true),
      ),
    );

    if (product == null) return;

    final barcode = textOrNull(product[AppProductFields.barcode]);
    final productName = textOrNull(product[AppProductFields.name]);
    final productImageUrl = textOrNull(product[AppProductFields.imageUrl]);

    setState(() {
      linkedBarcode = barcode;
      linkedProductName = productName;
      linkedProductImageUrl = productImageUrl;
      productLinkMessage = null;
      validationMessage = null;
      linkedCatalogItemId = null;
      linkedCatalogItemName = null;
      linkedCatalogItemDefaultUnit = null;

      if (productName != null) {
        nameController.text = productName;
      } else if (barcode != null && nameController.text.trim().isEmpty) {
        nameController.text = barcode;
      }
    });

    await loadLatestProductPrice();
  }

  Future<void> loadLatestProductPrice() async {
    final barcode = linkedBarcode;

    if (barcode == null || barcode.isEmpty) return;

    setState(() {
      loadingProductPrice = true;
      productLinkMessage = null;
    });

    try {
      final latestPrice = await productRepository.getLatestPrice(
        groupId: widget.groupId,
        barcode: barcode,
      );

      if (!mounted) return;

      setState(() {
        if (latestPrice != null) {
          final price = latestPrice[AppProductPriceFields.price];

          if (price != null) {
            priceController.text = price.toString();
          }

          productLinkMessage = context.l10n.productLinkedLatestGroupPriceLoaded;
        } else {
          productLinkMessage = context.l10n.productLinkedNoGroupPriceSavedYet;
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        productLinkMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => loadingProductPrice = false);
      }
    }
  }

  void clearProductLink() {
    setState(() {
      linkedBarcode = null;
      linkedProductName = null;
      linkedProductImageUrl = null;
      productLinkMessage = context.l10n.productLinkRemoved;
    });
  }

  void submit() {
    final name = nameController.text.trim();
    final quantityText = quantityController.text.trim();
    final unit = unitController.text.trim();
    final priceText = priceController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.itemNameIsRequired);
      return;
    }

    final quantity = parseOptionalDouble(quantityText);

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => validationMessage = context.l10n.quantityMustBeANumber);
      return;
    }

    final estimatedUnitPrice = parseOptionalDouble(priceText);

    if (priceText.isNotEmpty && estimatedUnitPrice == null) {
      setState(() => validationMessage = context.l10n.priceMustBeValidNumber);
      return;
    }

    if (estimatedUnitPrice != null && estimatedUnitPrice < 0) {
      setState(() => validationMessage = context.l10n.priceCannotBeNegative);
      return;
    }

    Navigator.of(context).pop(
      ShoppingItemFormPageResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
        estimatedUnitPrice: estimatedUnitPrice,
        priceCurrency: priceCurrency,
        barcode: linkedBarcode,
        catalogItemId: linkedCatalogItemId,
        productName: linkedProductName,
        productImageUrl: linkedProductImageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estimatedTotal = currentEstimatedTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.editShoppingItem
              : context.l10n.addShoppingItem,
        ),
      ),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: isEditing ? context.l10n.save : context.l10n.add,
        primaryIcon: isEditing ? Icons.save_outlined : Icons.add,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.shopping_cart_outlined,
              title: context.l10n.shoppingItem,
              subtitle: hasAnyLinkedItem
                  ? 'This item is linked to a saved item.'
                  : context.l10n.addAnItemQuantityAndUnit,
            ),
            _LinkedProductActionsCard(
              barcode: linkedBarcode,
              productName: linkedProductName,
              productImageUrl: linkedProductImageUrl,
              loading: loadingProductPrice,
              message: productLinkMessage,
              onSelectProduct: selectProduct,
              onClearProduct: hasProductData ? clearProductLink : null,
            ),
            const SizedBox(height: 12),
            _LinkedGenericItemActionsCard(
              catalogItemId: linkedCatalogItemId,
              catalogItemName: linkedCatalogItemName,
              defaultUnit: linkedCatalogItemDefaultUnit,
              onSelectGenericItem: selectGenericItem,
              onClearGenericItem: hasGenericItemData
                  ? clearGenericItemLink
                  : null,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.name,
                    hintText: context.l10n.tomatoes,
                    prefixIcon: const Icon(Icons.shopping_basket_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.quantity,
                          hintText: '2',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          clearValidation();
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: context.l10n.unit,
                          hintText: context.l10n.pcsGMl,
                          prefixIcon: const Icon(Icons.scale_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.estimatedUnitPrice,
                    hintText: '2.49',
                    prefixIcon: const Icon(Icons.euro_outlined),
                    suffixText: priceCurrency,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => submit(),
                  onChanged: (_) {
                    clearValidation();
                    setState(() {});
                  },
                ),
                if (estimatedTotal != null) ...[
                  const SizedBox(height: 12),
                  _EstimatedTotalCard(
                    total: estimatedTotal,
                    currency: priceCurrency,
                  ),
                ],
                if (validationMessage != null) ...[
                  const SizedBox(height: 16),
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _LinkedProductActionsCard extends StatelessWidget {
  const _LinkedProductActionsCard({
    required this.barcode,
    required this.productName,
    required this.productImageUrl,
    required this.loading,
    required this.message,
    required this.onSelectProduct,
    required this.onClearProduct,
  });

  final String? barcode;
  final String? productName;
  final String? productImageUrl;
  final bool loading;
  final String? message;
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
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return _ProductFallbackAvatar(theme: theme);
                      },
                    ),
                  )
                else
                  _ProductFallbackAvatar(theme: theme),
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
                        hasProductData
                            ? context.l10n.itemProductLinkSaved
                            : context.l10n.linkCachedProductFromDatabase,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              _InfoMessage(message: message!),
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

class _ProductFallbackAvatar extends StatelessWidget {
  const _ProductFallbackAvatar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 29,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.inventory_2_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _EstimatedTotalCard extends StatelessWidget {
  const _EstimatedTotalCard({required this.total, required this.currency});

  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.estimatedTotal(total.toStringAsFixed(2), currency),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedGenericItemActionsCard extends StatelessWidget {
  const _LinkedGenericItemActionsCard({
    required this.catalogItemId,
    required this.catalogItemName,
    required this.defaultUnit,
    required this.onSelectGenericItem,
    required this.onClearGenericItem,
  });

  final String? catalogItemId;
  final String? catalogItemName;
  final String? defaultUnit;
  final VoidCallback onSelectGenericItem;
  final VoidCallback? onClearGenericItem;

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
                            (hasGenericItemData
                                ? 'Linked generic item'
                                : 'No generic item linked'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (defaultUnit != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Default unit: $defaultUnit',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        hasGenericItemData
                            ? 'This shopping item is linked to a reusable generic item.'
                            : 'Link a generic item like Tomatoes, Onion or Eggs.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSelectGenericItem,
                    icon: const Icon(Icons.category_outlined),
                    label: Text(
                      hasGenericItemData
                          ? 'Change generic item'
                          : 'Link generic item',
                    ),
                  ),
                ),
                if (onClearGenericItem != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onClearGenericItem,
                    icon: const Icon(Icons.link_off_outlined),
                    tooltip: 'Remove generic item link',
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

String? textOrNull(dynamic value) {
  final text = value?.toString().trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  return text;
}
