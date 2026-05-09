import 'package:flutter/material.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class ShoppingItemFormPageResult {
  const ShoppingItemFormPageResult({
    required this.name,
    this.quantity,
    this.unit,
    this.estimatedUnitPrice,
    this.priceCurrency = 'EUR',
  });

  final String name;
  final double? quantity;
  final String? unit;
  final double? estimatedUnitPrice;
  final String priceCurrency;
}

class ShoppingItemFormPage extends StatefulWidget {
  const ShoppingItemFormPage({super.key, this.item});

  final Map<String, dynamic>? item;

  @override
  State<ShoppingItemFormPage> createState() => _ShoppingItemFormPageState();
}

class _ShoppingItemFormPageState extends State<ShoppingItemFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController unitController;
  late final TextEditingController priceController;

  String? validationMessage;

  bool get isEditing => widget.item != null;

  String? get barcode {
    return textOrNull(widget.item?[AppShoppingItemFields.barcode]);
  }

  String? get productName {
    return textOrNull(widget.item?[AppShoppingItemFields.productName]);
  }

  String? get productImageUrl {
    return textOrNull(widget.item?[AppShoppingItemFields.productImageUrl]);
  }

  String get priceCurrency {
    return textOrNull(widget.item?[AppShoppingItemFields.priceCurrency]) ??
        'EUR';
  }

  bool get hasProductData {
    return barcode != null || productName != null || productImageUrl != null;
  }

  @override
  void initState() {
    super.initState();

    final item = widget.item;

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
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
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
      setState(() => validationMessage = 'Price must be a valid number.');
      return;
    }

    if (estimatedUnitPrice != null && estimatedUnitPrice < 0) {
      setState(() => validationMessage = 'Price cannot be negative.');
      return;
    }

    Navigator.of(context).pop(
      ShoppingItemFormPageResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
        estimatedUnitPrice: estimatedUnitPrice,
        priceCurrency: priceCurrency,
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
              subtitle: hasProductData
                  ? 'This item is linked to a scanned product.'
                  : context.l10n.addAnItemQuantityAndUnit,
            ),
            if (hasProductData) ...[
              const SizedBox(height: 16),
              _LinkedProductCard(
                barcode: barcode,
                productName: productName,
                productImageUrl: productImageUrl,
              ),
            ],
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
                    labelText: 'Estimated unit price',
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

class _LinkedProductCard extends StatelessWidget {
  const _LinkedProductCard({
    required this.barcode,
    required this.productName,
    required this.productImageUrl,
  });

  final String? barcode;
  final String? productName;
  final String? productImageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = productImageUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
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
                    productName ?? 'Linked product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (barcode != null) ...[
                    const SizedBox(height: 4),
                    SelectableText(barcode!, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Product link is kept when editing this item.',
                    style: theme.textTheme.bodySmall,
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
              'Estimated total: ${total.toStringAsFixed(2)} $currency',
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

String? textOrNull(dynamic value) {
  final text = value?.toString().trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  return text;
}
