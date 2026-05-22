import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/fields/product_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/generic_catalog_page.dart';
import 'package:pesalistas/pages/product_detail_page.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:pesalistas/widgets/common/app_meta_pill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({
    super.key,
    this.groupId,
    this.selectionMode = false,
  });

  final String? groupId;
  final bool selectionMode;

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  late final ProductRepository productRepository;

  final TextEditingController searchController = TextEditingController();

  bool loading = true;
  String? errorMessage;
  String searchQuery = '';

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();

    productRepository = ProductRepository(
      Supabase.instance.client,
      useStaging: AppConfig.useOpenFoodFactsStaging,
    );

    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      final barcode = text(product[AppProductFields.barcode]).toLowerCase();
      final name = text(product[AppProductFields.name]).toLowerCase();
      final brand = text(product[AppProductFields.brand]).toLowerCase();
      final status = text(product[AppProductFields.status]).toLowerCase();

      return barcode.contains(query) ||
          name.contains(query) ||
          brand.contains(query) ||
          status.contains(query);
    }).toList();
  }

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = await productRepository.getRecentProducts();

      if (!mounted) return;

      setState(() {
        products = result;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        loading = false;
      });
    }
  }

  Future<void> openProductDetail(Map<String, dynamic> product) async {
    if (widget.selectionMode) {
      Navigator.of(context).pop(product);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/product_detail'),
        builder: (_) =>
            ProductDetailPage(product: product, groupId: widget.groupId),
      ),
    );

    if (!mounted) return;

    await loadProducts();
  }

  void updateSearch(String value) {
    setState(() => searchQuery = value);
  }

  void clearSearch() {
    searchController.clear();
    setState(() => searchQuery = '');
  }

  String text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectionMode
              ? context.l10n.selectProductTitle
              : context.l10n.productDatabaseTitle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/generic_catalog'),
                  builder: (_) => GenericCatalogPage(groupId: widget.groupId),
                ),
              );
            },
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Generic items',
          ),
          IconButton(
            onPressed: loading ? null : loadProducts,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: loadProducts,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProductCatalogHeaderCard(
                totalCount: products.length,
                visibleCount: visibleProducts.length,
              ),
              const SizedBox(height: 12),
              SearchBar(
                controller: searchController,
                leading: const Icon(Icons.search),
                hintText: context.l10n.searchProductsHint,
                onChanged: updateSearch,
                trailing: [
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: clearSearch,
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.clearSearch,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (loading)
                const AppMessageCard(
                  icon: Icons.sync_outlined,
                  message: 'Loading products...',
                )
              else if (errorMessage != null)
                AppMessageCard(
                  icon: Icons.error_outline,
                  message: errorMessage!,
                  tone: AppMessageCardTone.error,
                )
              else if (visibleProducts.isEmpty)
                const AppMessageCard(
                  icon: Icons.inventory_2_outlined,
                  message:
                      'No products found yet. Scan a product to add it to your catalog.',
                )
              else
                for (final product in visibleProducts)
                  _ProductCatalogCard(
                    product: product,
                    selectionMode: widget.selectionMode,
                    onTap: () => openProductDetail(product),
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCatalogHeaderCard extends StatelessWidget {
  const _ProductCatalogHeaderCard({
    required this.totalCount,
    required this.visibleCount,
  });

  final int totalCount;
  final int visibleCount;

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
                Icons.inventory_2_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.cachedProductsTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.productCatalogLoadedSummary(
                      visibleCount,
                      totalCount,
                    ),
                    style: theme.textTheme.bodyMedium,
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

class _ProductCatalogCard extends StatelessWidget {
  const _ProductCatalogCard({
    required this.product,
    required this.selectionMode,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final bool selectionMode;
  final VoidCallback onTap;

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

    final barcode = text(product[AppProductFields.barcode]);
    final name = text(
      product[AppProductFields.name],
      fallback: context.l10n.unknownProduct,
    );
    final brand = text(product[AppProductFields.brand]);
    final quantity = text(product[AppProductFields.quantity]);
    final status = text(product[AppProductFields.status]);
    final fetchedAt = text(product[AppProductFields.fetchedAt]);
    final imageUrl = text(product[AppProductFields.imageUrl], fallback: '');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductCatalogImage(imageUrl: imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
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
                        AppMetaPill(
                          icon: Icons.qr_code_2_outlined,
                          label: barcode,
                        ),
                        AppMetaPill(icon: Icons.info_outline, label: status),
                        if (quantity != '—')
                          AppMetaPill(
                            icon: Icons.scale_outlined,
                            label: quantity,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.fetchedAtSummary(fetchedAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selectionMode
                    ? Icons.check_circle_outline
                    : Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCatalogImage extends StatelessWidget {
  const _ProductCatalogImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 32,
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
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return CircleAvatar(
            radius: 32,
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
