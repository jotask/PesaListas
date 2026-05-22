import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/fields/product_fields.dart';
import 'package:pesalistas/core/fields/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/repositories/shopping_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductScannerPage extends StatefulWidget {
  const ProductScannerPage({super.key, this.groupId});

  final String? groupId;

  @override
  State<ProductScannerPage> createState() => _ProductScannerPageState();
}

class _ProductScannerPageState extends State<ProductScannerPage> {
  late final MobileScannerController scannerController;
  late final ProductRepository productRepository;

  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController priceNoteController = TextEditingController();
  late final ShoppingRepository shoppingRepository;

  final TextEditingController shoppingNameController = TextEditingController();
  final TextEditingController shoppingQuantityController =
      TextEditingController(text: '1');
  final TextEditingController shoppingUnitController = TextEditingController();

  bool addingToShoppingList = false;
  String? shoppingValidationMessage;

  bool lookingUpProduct = false;
  bool savingPrice = false;
  bool cameraPaused = false;

  String? scannedBarcode;
  String? errorMessage;
  String? priceValidationMessage;

  Map<String, dynamic>? product;
  Map<String, dynamic>? latestPrice;

  bool get hasGroupContext {
    final value = widget.groupId;
    return value != null && value.trim().isNotEmpty;
  }

  bool get productWasFound {
    return product?[AppProductFields.status] == AppProductStatus.found;
  }

  @override
  void initState() {
    super.initState();

    shoppingRepository = ShoppingRepository(Supabase.instance.client);

    scannerController = MobileScannerController();

    productRepository = ProductRepository(
      Supabase.instance.client,

      // Development staging.
      // Change to false later for production.
      useStaging: AppConfig.useOpenFoodFactsStaging,
    );
  }

  @override
  void dispose() {
    barcodeController.dispose();
    priceController.dispose();
    storeNameController.dispose();
    priceNoteController.dispose();
    scannerController.dispose();
    shoppingNameController.dispose();
    shoppingQuantityController.dispose();
    shoppingUnitController.dispose();
    super.dispose();
  }

  void handleDetection(BarcodeCapture capture) {
    if (lookingUpProduct || savingPrice || cameraPaused) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first.rawValue?.trim();

    if (barcode == null || barcode.isEmpty) return;
    if (barcode == scannedBarcode) return;

    lookupBarcode(barcode);
  }

  void prefillShoppingFields(Map<String, dynamic>? loadedProduct) {
    final name = AppValueParsing.textOrNull(
      loadedProduct?[AppProductFields.name],
    );
    final barcode = AppValueParsing.textOrNull(
      loadedProduct?[AppProductFields.barcode],
    );

    shoppingNameController.text = name ?? barcode ?? '';
    shoppingQuantityController.text = '1';
    shoppingUnitController.clear();
  }

  Future<void> lookupBarcode(
    String barcode, {
    bool forceRefresh = false,
  }) async {
    final cleanBarcode = barcode.trim();

    if (cleanBarcode.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      lookingUpProduct = true;
      cameraPaused = true;
      scannedBarcode = cleanBarcode;
      barcodeController.text = cleanBarcode;
      product = null;
      latestPrice = null;
      errorMessage = null;
      priceValidationMessage = null;
      priceController.clear();
      storeNameController.clear();
      priceNoteController.clear();

      shoppingValidationMessage = null;
      shoppingNameController.clear();
      shoppingQuantityController.text = '1';
      shoppingUnitController.clear();
    });

    await scannerController.stop();

    try {
      final loadedProduct = await productRepository.getProductByBarcode(
        cleanBarcode,
        forceRefresh: forceRefresh,
      );

      Map<String, dynamic>? loadedPrice;

      if (hasGroupContext && loadedProduct != null) {
        loadedPrice = await productRepository.getLatestPrice(
          groupId: widget.groupId!,
          barcode: cleanBarcode,
        );
      }

      if (!mounted) return;

      setState(() {
        product = loadedProduct;
        latestPrice = loadedPrice;

        prefillShoppingFields(loadedProduct);

        if (loadedPrice != null) {
          priceController.text =
              loadedPrice[AppProductPriceFields.price]?.toString() ?? '';

          storeNameController.text =
              loadedPrice[AppProductPriceFields.storeName]?.toString() ?? '';

          priceNoteController.text =
              loadedPrice[AppProductPriceFields.note]?.toString() ?? '';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          lookingUpProduct = false;
        });
      }
    }
  }

  Future<void> addToShoppingList() async {
    final groupId = widget.groupId;
    final currentProduct = product;

    setState(() => shoppingValidationMessage = null);

    if (groupId == null || groupId.isEmpty) {
      setState(() {
        shoppingValidationMessage =
            context.l10n.openScannerFromShoppingListToAddProducts;
      });
      return;
    }

    if (currentProduct == null || !productWasFound) {
      setState(() {
        shoppingValidationMessage = context.l10n.scanOrLoadKnownProductFirst;
      });
      return;
    }

    final name = shoppingNameController.text.trim();

    if (name.isEmpty) {
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

    final unit = shoppingUnitController.text.trim();
    final price = AppValueParsing.doubleOrNull(priceController.text);
    final barcode = currentProduct[AppProductFields.barcode]?.toString();
    final productName = currentProduct[AppProductFields.name]?.toString();
    final productImageUrl = currentProduct[AppProductFields.imageUrl]
        ?.toString();

    FocusScope.of(context).unfocus();

    setState(() => addingToShoppingList = true);

    try {
      await shoppingRepository.createShoppingItemFromProduct(
        groupId: groupId,
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
        barcode: barcode,
        productName: productName,
        productImageUrl: productImageUrl,
        estimatedUnitPrice: price,
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

  Future<void> resumeScanner() async {
    setState(() {
      cameraPaused = false;
      errorMessage = null;
      priceValidationMessage = null;
    });

    await scannerController.start();
  }

  Future<void> refreshCurrentBarcode() async {
    final barcode = scannedBarcode ?? barcodeController.text.trim();

    if (barcode.isEmpty) return;

    await lookupBarcode(barcode, forceRefresh: true);
  }

  Future<void> savePrice() async {
    final groupId = widget.groupId;
    final barcode = scannedBarcode ?? barcodeController.text.trim();
    final priceText = priceController.text.trim().replaceAll(',', '.');

    setState(() => priceValidationMessage = null);

    if (groupId == null || groupId.isEmpty) {
      setState(() {
        priceValidationMessage = context.l10n.openScannerFromGroupToSavePrices;
      });
      return;
    }

    if (product == null || barcode.isEmpty) {
      setState(() {
        priceValidationMessage = context.l10n.scanOrLoadProductFirst;
      });
      return;
    }

    if (!productWasFound) {
      setState(() {
        priceValidationMessage = context.l10n.cannotSavePriceForUnknownProduct;
      });
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null) {
      setState(() {
        priceValidationMessage = context.l10n.priceMustBeValidNumber;
      });
      return;
    }

    if (price < 0) {
      setState(() {
        priceValidationMessage = context.l10n.priceCannotBeNegative;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => savingPrice = true);

    try {
      await productRepository.savePrice(
        groupId: groupId,
        barcode: barcode,
        price: price,
        storeName: storeNameController.text,
        note: priceNoteController.text,
      );

      final refreshedPrice = await productRepository.getLatestPrice(
        groupId: groupId,
        barcode: barcode,
      );

      if (!mounted) return;

      setState(() {
        latestPrice = refreshedPrice;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.priceSaved)));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        priceValidationMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => savingPrice = false);
      }
    }
  }

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = product;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.productScannerTitle),
        actions: [
          IconButton(
            onPressed: lookingUpProduct || savingPrice
                ? null
                : refreshCurrentBarcode,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.requestAgain,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: scannerController,
                  onDetect: handleDetection,
                ),
                _ScannerOverlay(
                  lookingUpProduct: lookingUpProduct,
                  cameraPaused: cameraPaused,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ManualLookupCard(
                    controller: barcodeController,
                    loading: lookingUpProduct || savingPrice,
                    onLookup: () => lookupBarcode(barcodeController.text),
                    onRefresh: refreshCurrentBarcode,
                    onResumeScanner: resumeScanner,
                  ),
                  const SizedBox(height: 12),
                  if (lookingUpProduct)
                    const _LoadingProductCard()
                  else if (errorMessage != null)
                    _ErrorCard(message: errorMessage!)
                  else if (currentProduct != null) ...[
                    _ProductCard(
                      product: currentProduct,
                      latestPrice: latestPrice,
                      productWasFound: productWasFound,
                    ),
                    const SizedBox(height: 12),
                    _ProductPriceCard(
                      hasGroupContext: hasGroupContext,
                      productWasFound: productWasFound,
                      latestPrice: latestPrice,
                      priceController: priceController,
                      storeNameController: storeNameController,
                      noteController: priceNoteController,
                      savingPrice: savingPrice,
                      validationMessage: priceValidationMessage,
                      onSave: savePrice,
                    ),
                    const SizedBox(height: 12),
                    _AddToShoppingListCard(
                      hasGroupContext: hasGroupContext,
                      productWasFound: productWasFound,
                      loading: addingToShoppingList,
                      nameController: shoppingNameController,
                      quantityController: shoppingQuantityController,
                      unitController: shoppingUnitController,
                      validationMessage: shoppingValidationMessage,
                      onAdd: addToShoppingList,
                    ),
                  ] else
                    const _EmptyProductCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({
    required this.lookingUpProduct,
    required this.cameraPaused,
  });

  final bool lookingUpProduct;
  final bool cameraPaused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.75),
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                lookingUpProduct
                    ? context.l10n.lookingUpProduct
                    : cameraPaused
                    ? context.l10n.scannerPaused
                    : context.l10n.pointCameraAtBarcode,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualLookupCard extends StatelessWidget {
  const _ManualLookupCard({
    required this.controller,
    required this.loading,
    required this.onLookup,
    required this.onRefresh,
    required this.onResumeScanner,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onLookup;
  final VoidCallback onRefresh;
  final VoidCallback onResumeScanner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.barcode,
                hintText: '3274080005003',
                prefixIcon: Icon(Icons.qr_code_2_outlined),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onLookup(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : onResumeScanner,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(context.l10n.scanAgain),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: loading ? null : onLookup,
                    icon: const Icon(Icons.search),
                    label: Text(context.l10n.lookup),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: loading ? null : onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.requestThisBarcodeAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingProductCard extends StatelessWidget {
  const _LoadingProductCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(context.l10n.loadingProductInfo)),
          ],
        ),
      ),
    );
  }
}

class _EmptyProductCard extends StatelessWidget {
  const _EmptyProductCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l10n.scanOrEnterBarcodeToLoadProductData),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.latestPrice,
    required this.productWasFound,
  });

  final Map<String, dynamic> product;
  final Map<String, dynamic>? latestPrice;
  final bool productWasFound;

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

    final imageUrl = text(product[AppProductFields.imageUrl], fallback: '');
    final name = text(
      product[AppProductFields.name],
      fallback: context.l10n.unknownProduct,
    );
    final brand = text(product[AppProductFields.brand]);
    final quantity = text(product[AppProductFields.quantity]);
    final status = text(product[AppProductFields.status]);
    final barcode = text(product[AppProductFields.barcode]);
    final categories = text(product[AppProductFields.categories]);
    final nutriscore = text(product[AppProductFields.nutriscore]);
    final novaGroup = text(product[AppProductFields.novaGroup]);
    final ecoscore = text(product[AppProductFields.ecoscore]);
    final fetchedAt = text(product[AppProductFields.fetchedAt]);

    final latestPriceText = latestPrice == null
        ? context.l10n.noPriceSavedYet
        : '${latestPrice?[AppProductPriceFields.price]} '
              '${latestPrice?[AppProductPriceFields.currency] ?? AppConfig.defaultCurrency}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(imageUrl: imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(brand, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _ProductChip(label: status),
                          if (productWasFound) _ProductChip(label: quantity),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProductInfoRow(label: context.l10n.barcode, value: barcode),
            _ProductInfoRow(
              label: context.l10n.latestPrice,
              value: latestPriceText,
            ),
            _ProductInfoRow(
              label: context.l10n.productCategories,
              value: categories,
            ),
            _ProductInfoRow(label: context.l10n.nutriscore, value: nutriscore),
            _ProductInfoRow(label: context.l10n.novaGroup, value: novaGroup),
            _ProductInfoRow(label: context.l10n.ecoscore, value: ecoscore),
            _ProductInfoRow(label: context.l10n.fetchedAt, value: fetchedAt),
          ],
        ),
      ),
    );
  }
}

class _ProductPriceCard extends StatelessWidget {
  const _ProductPriceCard({
    required this.hasGroupContext,
    required this.productWasFound,
    required this.latestPrice,
    required this.priceController,
    required this.storeNameController,
    required this.noteController,
    required this.savingPrice,
    required this.validationMessage,
    required this.onSave,
  });

  final bool hasGroupContext;
  final bool productWasFound;
  final Map<String, dynamic>? latestPrice;
  final TextEditingController priceController;
  final TextEditingController storeNameController;
  final TextEditingController noteController;
  final bool savingPrice;
  final String? validationMessage;
  final VoidCallback onSave;

  String latestPriceText(BuildContext context) {
    final price = latestPrice?[AppProductPriceFields.price];
    final currency =
        latestPrice?[AppProductPriceFields.currency] ??
        AppConfig.defaultCurrency;
    final store = latestPrice?[AppProductPriceFields.storeName]?.toString();

    if (price == null) {
      return context.l10n.noSavedPriceForGroupYet;
    }

    if (store == null || store.trim().isEmpty) {
      return '$price $currency';
    }

    return '$price $currency · $store';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasGroupContext) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.productLookupOnlyOpenFromGroupToSavePrices,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.groupPrice,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        latestPriceText(context),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              enabled: productWasFound && !savingPrice,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.price,
                hintText: '2.49',
                prefixIcon: Icon(Icons.euro_outlined),
                suffixText: AppConfig.defaultCurrency,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: storeNameController,
              enabled: productWasFound && !savingPrice,
              decoration: InputDecoration(
                labelText: context.l10n.store,
                hintText: 'Mercadona',
                prefixIcon: Icon(Icons.store_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              enabled: productWasFound && !savingPrice,
              decoration: InputDecoration(
                labelText: context.l10n.note,
                hintText: context.l10n.optional,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              _InlineErrorMessage(message: validationMessage!),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: productWasFound && !savingPrice ? onSave : null,
              icon: savingPrice
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                savingPrice ? context.l10n.saving : context.l10n.savePrice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

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

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 34,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return CircleAvatar(
            radius: 34,
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

class _ProductChip extends StatelessWidget {
  const _ProductChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProductInfoRow extends StatelessWidget {
  const _ProductInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _AddToShoppingListCard extends StatelessWidget {
  const _AddToShoppingListCard({
    required this.hasGroupContext,
    required this.productWasFound,
    required this.loading,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.validationMessage,
    required this.onAdd,
  });

  final bool hasGroupContext;
  final bool productWasFound;
  final bool loading;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final String? validationMessage;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasGroupContext) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.openScannerFromShoppingListToAddDirectly,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(context.l10n.createShoppingItemFromProduct),
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
                prefixIcon: const Icon(Icons.shopping_basket_outlined),
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
                      prefixIcon: const Icon(Icons.numbers_outlined),
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
                      prefixIcon: const Icon(Icons.scale_outlined),
                    ),
                  ),
                ),
              ],
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              _InlineErrorMessage(message: validationMessage!),
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
