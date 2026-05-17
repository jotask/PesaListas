import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/catalog_item_fields.dart';
import 'package:pesalistas/core/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/pages/catalog_item_price_page.dart';
import 'package:pesalistas/pages/edit_catalog_item_page.dart';
import 'package:pesalistas/repositories/catalog_item_repository.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenericItemDetailPage extends StatefulWidget {
  const GenericItemDetailPage({
    super.key,
    required this.catalogItem,
    this.groupId,
  });

  final Map<String, dynamic> catalogItem;
  final String? groupId;

  @override
  State<GenericItemDetailPage> createState() => _GenericItemDetailPageState();
}

class _GenericItemDetailPageState extends State<GenericItemDetailPage> {
  late final CatalogItemRepository catalogItemRepository;
  late final ProductRepository productRepository;

  late Map<String, dynamic> catalogItem;

  bool loadingPrice = false;
  bool saving = false;
  String? errorMessage;
  Map<String, dynamic>? latestPrice;

  @override
  void initState() {
    super.initState();

    catalogItem = Map<String, dynamic>.from(widget.catalogItem);

    final client = Supabase.instance.client;

    catalogItemRepository = CatalogItemRepository(client);
    productRepository = ProductRepository(
      client,
      useStaging: AppConfig.useOpenFoodFactsStaging,
    );

    loadLatestPrice();
  }

  String get itemId {
    return catalogItem[AppCatalogItemFields.id].toString();
  }

  String get name {
    return AppValueParsing.textOrNull(catalogItem[AppCatalogItemFields.name]) ??
        'Unnamed item';
  }

  String? get category {
    return AppValueParsing.textOrNull(
      catalogItem[AppCatalogItemFields.category],
    );
  }

  String? get defaultUnit {
    return AppUnitType.valueOrNull(
      AppValueParsing.textOrNull(catalogItem[AppCatalogItemFields.defaultUnit]),
    );
  }

  bool get canManagePrice {
    return widget.groupId != null && widget.groupId!.trim().isNotEmpty;
  }

  Future<void> loadLatestPrice() async {
    if (!canManagePrice) return;

    setState(() {
      loadingPrice = true;
      errorMessage = null;
    });

    try {
      final result = await productRepository.getLatestCatalogItemPrice(
        groupId: widget.groupId!,
        catalogItemId: itemId,
      );

      if (!mounted) return;

      setState(() {
        latestPrice = result;
        loadingPrice = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        loadingPrice = false;
      });
    }
  }

  Future<void> editItem() async {
    final result = await Navigator.of(context).push<EditCatalogItemPageResult>(
      MaterialPageRoute(
        builder: (_) => EditCatalogItemPage(catalogItem: catalogItem),
      ),
    );

    if (result == null) return;

    setState(() {
      saving = true;
      errorMessage = null;
    });

    try {
      final updated = await catalogItemRepository.updateCatalogItem(
        catalogItemId: itemId,
        name: result.name,
        category: result.category,
        defaultUnit: result.defaultUnit,
      );

      if (!mounted) return;

      setState(() {
        catalogItem = updated;
        saving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generic item updated.')));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        saving = false;
      });
    }
  }

  Future<void> openPricePage() async {
    if (!canManagePrice) return;

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => CatalogItemPricePage(
          groupId: widget.groupId!,
          catalogItemId: itemId,
          catalogItemName: name,
          defaultUnit: defaultUnit,
        ),
      ),
    );

    if (result == null) return;

    await loadLatestPrice();
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
    final theme = Theme.of(context);
    final unit = defaultUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generic item'),
        actions: [
          IconButton(
            onPressed: saving ? null : editItem,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit generic item',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
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
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (category != null) ...[
                            const SizedBox(height: 4),
                            Text(category!),
                          ],
                          if (unit != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Default unit: ${AppUnitType.displayLabel(unit)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (errorMessage != null) ...[
              AppMessageCard(
                icon: Icons.error_outline,
                message: errorMessage!,
                tone: AppMessageCardTone.error,
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.euro_outlined),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Group price',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (canManagePrice)
                          IconButton(
                            onPressed: loadingPrice ? null : loadLatestPrice,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!canManagePrice)
                      const Text(
                        'Open this from a group to manage group prices.',
                      )
                    else if (loadingPrice)
                      const LinearProgressIndicator()
                    else
                      Text(latestPriceText()),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: canManagePrice && !loadingPrice
                          ? openPricePage
                          : null,
                      icon: const Icon(Icons.price_change_outlined),
                      label: Text(
                        latestPrice == null
                            ? 'Add group price'
                            : 'Update group price',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
