import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:pesalistas/widgets/common/app_unit_dropdown_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatalogItemPricePage extends StatefulWidget {
  const CatalogItemPricePage({
    super.key,
    required this.groupId,
    required this.catalogItemId,
    required this.catalogItemName,
    this.defaultUnit,
  });

  final String groupId;
  final String catalogItemId;
  final String catalogItemName;
  final String? defaultUnit;

  @override
  State<CatalogItemPricePage> createState() => _CatalogItemPricePageState();
}

class _CatalogItemPricePageState extends State<CatalogItemPricePage> {
  late final ProductRepository productRepository;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController priceQuantityController = TextEditingController(
    text: '1',
  );
  late final TextEditingController priceUnitController;
  final TextEditingController storeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool saving = false;
  bool loadingLatestPrice = true;
  String? errorMessage;
  Map<String, dynamic>? latestPrice;

  @override
  void initState() {
    super.initState();

    productRepository = ProductRepository(
      Supabase.instance.client,
      useStaging: AppConfig.useOpenFoodFactsStaging,
    );

    priceUnitController = TextEditingController(text: widget.defaultUnit ?? '');

    loadLatestPrice();
  }

  @override
  void dispose() {
    priceController.dispose();
    priceQuantityController.dispose();
    priceUnitController.dispose();
    storeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  double? parseDouble(String value) {
    return AppValueParsing.doubleOrNull(value);
  }

  void fillFormFromLatestPrice(Map<String, dynamic>? price) {
    if (price == null) {
      return;
    }

    priceController.text =
        AppValueParsing.textOrNull(price[AppProductPriceFields.price]) ?? '';

    priceQuantityController.text =
        AppValueParsing.textOrNull(
          price[AppProductPriceFields.priceQuantity],
        ) ??
        '1';

    priceUnitController.text =
        AppUnitType.valueOrNull(
          AppValueParsing.textOrNull(price[AppProductPriceFields.priceUnit]),
        ) ??
        widget.defaultUnit ??
        '';

    storeController.text =
        AppValueParsing.textOrNull(price[AppProductPriceFields.storeName]) ??
        '';

    noteController.text =
        AppValueParsing.textOrNull(price[AppProductPriceFields.note]) ?? '';
  }

  Future<void> loadLatestPrice() async {
    setState(() {
      loadingLatestPrice = true;
      errorMessage = null;
    });

    try {
      final result = await productRepository.getLatestCatalogItemPrice(
        groupId: widget.groupId,
        catalogItemId: widget.catalogItemId,
      );

      if (!mounted) return;

      setState(() {
        latestPrice = result;
        loadingLatestPrice = false;
      });
      fillFormFromLatestPrice(result);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        loadingLatestPrice = false;
      });
    }
  }

  Future<void> savePrice() async {
    if (saving) return;

    setState(() => errorMessage = null);

    final price = parseDouble(priceController.text);

    if (price == null) {
      setState(() => errorMessage = 'Price must be a valid number.');
      return;
    }

    if (price < 0) {
      setState(() => errorMessage = 'Price cannot be negative.');
      return;
    }

    final priceQuantity = parseDouble(priceQuantityController.text) ?? 1;

    if (priceQuantity <= 0) {
      setState(() {
        errorMessage = 'Price quantity must be greater than 0.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => saving = true);

    try {
      final saved = await productRepository.saveCatalogItemPrice(
        groupId: widget.groupId,
        catalogItemId: widget.catalogItemId,
        price: price,
        currency: AppConfig.defaultCurrency,
        priceQuantity: priceQuantity,
        priceUnit: AppUnitType.valueOrNull(priceUnitController.text),
        storeName: AppValueParsing.textOrNull(storeController.text),
        note: AppValueParsing.textOrNull(noteController.text),
      );

      if (!mounted) return;

      Navigator.of(context).pop(saved);
    } catch (error) {
      if (!mounted) return;

      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  String latestPriceText() {
    final price = latestPrice;

    if (price == null) {
      return 'No saved group price yet.';
    }

    final amount =
        AppValueParsing.textOrNull(price[AppProductPriceFields.price]) ?? '—';

    final currency =
        AppValueParsing.textOrNull(price[AppProductPriceFields.currency]) ??
        AppConfig.defaultCurrency;

    final quantity =
        AppValueParsing.textOrNull(
          price[AppProductPriceFields.priceQuantity],
        ) ??
        '1';

    final unit = AppUnitType.valueOrNull(
      AppValueParsing.textOrNull(price[AppProductPriceFields.priceUnit]),
    );

    if (unit == null) {
      return '$amount $currency per $quantity';
    }

    return '$amount $currency per $quantity ${AppUnitType.shortLabel(unit)}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultUnit = widget.defaultUnit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          latestPrice == null
              ? 'Add generic item price'
              : 'Update generic item price',
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: saving ? null : savePrice,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              saving
                  ? 'Saving...'
                  : latestPrice == null
                  ? 'Save price'
                  : 'Update price',
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CatalogItemPriceHeaderCard(
              catalogItemName: widget.catalogItemName,
              defaultUnit: defaultUnit,
              loadingLatestPrice: loadingLatestPrice,
              latestPriceText: latestPriceText(),
              onRefresh: loadLatestPrice,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: '2.30',
                        prefixIcon: const Icon(Icons.euro_outlined),
                        suffixText: AppConfig.defaultCurrency,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceQuantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'For quantity',
                              hintText: '1',
                              prefixIcon: Icon(Icons.numbers_outlined),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppUnitDropdownField(
                            controller: priceUnitController,
                            labelText: 'Unit',
                            hintText: 'kg, g, pcs, ml',
                            prefixIcon: Icons.scale_outlined,
                            onChanged: () {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: storeController,
                      decoration: const InputDecoration(
                        labelText: 'Store',
                        hintText: 'Mercadona',
                        prefixIcon: Icon(Icons.store_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        hintText: 'Optional',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      AppMessageCard(
                        icon: Icons.error_outline,
                        message: errorMessage!,
                        tone: AppMessageCardTone.error,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _CatalogItemPriceHeaderCard extends StatelessWidget {
  const _CatalogItemPriceHeaderCard({
    required this.catalogItemName,
    required this.defaultUnit,
    required this.loadingLatestPrice,
    required this.latestPriceText,
    required this.onRefresh,
  });

  final String catalogItemName;
  final String? defaultUnit;
  final bool loadingLatestPrice;
  final String latestPriceText;
  final VoidCallback onRefresh;

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
              radius: 29,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.category_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catalogItemName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (defaultUnit != null && defaultUnit!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Default unit: $defaultUnit'),
                  ],
                  const SizedBox(height: 8),
                  if (loadingLatestPrice)
                    const LinearProgressIndicator()
                  else
                    Text(latestPriceText, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(
              onPressed: loadingLatestPrice ? null : onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }
}
