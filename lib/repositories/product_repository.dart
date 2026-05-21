import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/fields/product_fields.dart';
import 'package:pesalistas/core/product_price_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class ProductRepository {
  ProductRepository(
    this.client, {
    this.useStaging = false,
    this.userAgent = 'PesaListas/0.1.0 (contact: acachitoro@gmail.com)',
  });

  final SupabaseClient client;
  final bool useStaging;
  final String userAgent;

  static const productsTable = 'products';
  static const productPricesTable = 'product_prices';

  Uri productUri(String barcode) {
    final host = useStaging
        ? 'world.openfoodfacts.net'
        : 'world.openfoodfacts.org';

    return Uri.https(host, '/api/v2/product/$barcode.json');
  }

  Map<String, String> get openFoodFactsHeaders {
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': userAgent,
    };

    if (useStaging) {
      headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('off:off'))}';
    }

    return headers;
  }

  Future<Map<String, dynamic>?> getCachedProduct(String barcode) async {
    final result = await client
        .from(productsTable)
        .select()
        .eq(AppProductFields.barcode, barcode)
        .maybeSingle();

    return result;
  }

  Future<Map<String, dynamic>?> getProductByBarcode(
    String barcode, {
    Duration maxCacheAge = const Duration(days: 60),
    bool forceRefresh = false,
  }) async {
    final cleanBarcode = barcode.trim();

    if (cleanBarcode.isEmpty) {
      return null;
    }

    if (!forceRefresh) {
      final cached = await getCachedProduct(cleanBarcode);

      if (cached != null && isFresh(cached, maxCacheAge)) {
        await AppAnalytics.instance.logProductLookup(
          source: 'cache',
          found: cached[AppProductFields.status] == AppProductStatus.found,
          forceRefresh: forceRefresh,
          useStaging: useStaging,
        );

        return cached;
      }
    }

    return fetchAndCacheProduct(cleanBarcode, forceRefresh: forceRefresh);
  }

  Future<void> deleteProductPrice(String priceId) async {
    await client
        .from(productPricesTable)
        .delete()
        .eq(AppProductPriceFields.id, priceId);

    await AppAnalytics.instance.logProductPriceDeleted();
  }

  Future<List<Map<String, dynamic>>> getRecentProducts({
    int limit = 500,
  }) async {
    final response = await client
        .from(productsTable)
        .select()
        .order(AppProductFields.fetchedAt, ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPricesForProduct({
    required String barcode,
    int limit = 50,
  }) async {
    final response = await client
        .from(productPricesTable)
        .select()
        .eq(AppProductPriceFields.barcode, barcode)
        .order(AppProductPriceFields.observedAt, ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  bool isFresh(Map<String, dynamic> product, Duration maxCacheAge) {
    final fetchedAtValue = product[AppProductFields.fetchedAt]?.toString();

    if (fetchedAtValue == null || fetchedAtValue.isEmpty) {
      return false;
    }

    final fetchedAt = DateTime.tryParse(fetchedAtValue);

    if (fetchedAt == null) {
      return false;
    }

    return DateTime.now().toUtc().difference(fetchedAt.toUtc()) <= maxCacheAge;
  }

  Future<Map<String, dynamic>> fetchAndCacheProduct(
    String barcode, {
    bool forceRefresh = true,
  }) async {
    final response = await http.get(
      productUri(barcode),
      headers: openFoodFactsHeaders,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OpenFoodFacts request failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('OpenFoodFacts returned an invalid JSON response.');
    }

    final row = openFoodFactsJsonToProductRow(barcode: barcode, json: decoded);

    final saved = await client
        .from(productsTable)
        .upsert(row, onConflict: AppProductFields.barcode)
        .select()
        .single();

    await AppAnalytics.instance.logProductLookup(
      source: 'open_food_facts',
      found: saved[AppProductFields.status] == AppProductStatus.found,
      forceRefresh: forceRefresh,
      useStaging: useStaging,
    );

    return saved;
  }

  Map<String, dynamic> openFoodFactsJsonToProductRow({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    final status = json['status'];
    final productRaw = json['product'];

    if (status != 1 || productRaw is! Map<String, dynamic>) {
      return {
        AppProductFields.barcode: barcode,
        AppProductFields.name: null,
        AppProductFields.brand: null,
        AppProductFields.quantity: null,
        AppProductFields.imageUrl: null,
        AppProductFields.categories: null,
        AppProductFields.nutriscore: null,
        AppProductFields.novaGroup: null,
        AppProductFields.ecoscore: null,
        AppProductFields.rawJson: json,
        AppProductFields.source: 'openfoodfacts',
        AppProductFields.status: AppProductStatus.notFound,
        AppProductFields.fetchedAt: DateTime.now().toUtc().toIso8601String(),
        AppProductFields.updatedAt: DateTime.now().toUtc().toIso8601String(),
      };
    }

    final product = productRaw;

    return {
      AppProductFields.barcode: barcode,
      AppProductFields.name: firstText([
        product['product_name'],
        product['product_name_en'],
        product['generic_name'],
        product['generic_name_en'],
      ]),
      AppProductFields.brand: firstText([
        product['brands'],
        product['brand_owner'],
      ]),
      AppProductFields.quantity: firstText([
        product['quantity'],
        product['product_quantity'],
        product['serving_size'],
      ]),
      AppProductFields.imageUrl: firstText([
        product['image_front_url'],
        product['image_url'],
        product['selected_images']?['front']?['display']?['en'],
      ]),
      AppProductFields.categories: firstText([
        product['categories'],
        product['categories_en'],
      ]),
      AppProductFields.nutriscore: firstText([
        product['nutriscore_grade'],
        product['nutrition_grades'],
      ]),
      AppProductFields.novaGroup: AppValueParsing.intOrNull(
        product['nova_group'],
      ),
      AppProductFields.ecoscore: firstText([
        product['ecoscore_grade'],
        product['ecoscore_score'],
      ]),
      AppProductFields.rawJson: json,
      AppProductFields.source: 'openfoodfacts',
      AppProductFields.status: AppProductStatus.found,
      AppProductFields.fetchedAt: DateTime.now().toUtc().toIso8601String(),
      AppProductFields.updatedAt: DateTime.now().toUtc().toIso8601String(),
    };
  }

  String? firstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();

      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getPricesForCatalogItem({
    required String catalogItemId,
    required String groupId,
    int limit = 50,
  }) async {
    final response = await client
        .from(productPricesTable)
        .select()
        .eq(AppProductPriceFields.groupId, groupId)
        .eq(AppProductPriceFields.catalogItemId, catalogItemId)
        .order(AppProductPriceFields.observedAt, ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getLatestCatalogItemPrice({
    required String groupId,
    required String catalogItemId,
  }) async {
    final result = await client
        .from(productPricesTable)
        .select()
        .eq(AppProductPriceFields.groupId, groupId)
        .eq(AppProductPriceFields.catalogItemId, catalogItemId)
        .order(AppProductPriceFields.observedAt, ascending: false)
        .limit(1)
        .maybeSingle();

    return result;
  }

  Future<Map<String, dynamic>> saveCatalogItemPrice({
    required String groupId,
    required String catalogItemId,
    required double price,
    String currency = AppConfig.defaultCurrency,
    double priceQuantity = 1,
    String? priceUnit,
    String? storeName,
    String? note,
  }) async {
    if (catalogItemId.trim().isEmpty) {
      throw ArgumentError('Catalog item id is required.');
    }

    if (priceQuantity <= 0) {
      throw ArgumentError('Price quantity must be greater than 0.');
    }

    final row = {
      AppProductPriceFields.groupId: groupId,
      AppProductPriceFields.barcode: null,
      AppProductPriceFields.catalogItemId: catalogItemId,
      AppProductPriceFields.price: price,
      AppProductPriceFields.currency: currency,
      AppProductPriceFields.priceQuantity: priceQuantity,
      AppProductPriceFields.priceUnit: AppValueParsing.textOrNull(priceUnit),
      AppProductPriceFields.storeName: AppValueParsing.textOrNull(storeName),
      AppProductPriceFields.note: AppValueParsing.textOrNull(note),
      AppProductPriceFields.observedAt: DateTime.now()
          .toUtc()
          .toIso8601String(),
    };

    final result = await client
        .from(productPricesTable)
        .insert(row)
        .select()
        .single();

    await AppAnalytics.instance.logProductPriceSaved(
      source: 'catalog_item',
      hasStoreName: storeName != null && storeName.trim().isNotEmpty,
      hasNote: note != null && note.trim().isNotEmpty,
      hasPriceUnit: priceUnit != null && priceUnit.trim().isNotEmpty,
    );

    return result;
  }

  Future<Map<String, dynamic>?> getLatestPrice({
    required String groupId,
    required String barcode,
  }) async {
    final result = await client
        .from(productPricesTable)
        .select()
        .eq(AppProductPriceFields.groupId, groupId)
        .eq(AppProductPriceFields.barcode, barcode)
        .order(AppProductPriceFields.observedAt, ascending: false)
        .limit(1)
        .maybeSingle();

    return result;
  }

  Future<Map<String, dynamic>> savePrice({
    required String groupId,
    required String barcode,
    required double price,
    String currency = AppConfig.defaultCurrency,
    double priceQuantity = 1,
    String? priceUnit,
    String? storeName,
    String? note,
  }) async {
    final row = {
      AppProductPriceFields.groupId: groupId,
      AppProductPriceFields.barcode: barcode,
      AppProductPriceFields.price: price,
      AppProductPriceFields.currency: currency,
      AppProductPriceFields.catalogItemId: null,
      AppProductPriceFields.priceQuantity: priceQuantity,
      AppProductPriceFields.priceUnit: AppValueParsing.textOrNull(priceUnit),
      AppProductPriceFields.storeName: AppValueParsing.textOrNull(storeName),
      AppProductPriceFields.note: AppValueParsing.textOrNull(note),
      AppProductPriceFields.observedAt: DateTime.now()
          .toUtc()
          .toIso8601String(),
    };

    final result = await client
        .from(productPricesTable)
        .insert(row)
        .select()
        .single();

    await AppAnalytics.instance.logProductPriceSaved(
      source: 'barcode',
      hasStoreName: storeName != null && storeName.trim().isNotEmpty,
      hasNote: note != null && note.trim().isNotEmpty,
      hasPriceUnit: priceUnit != null && priceUnit.trim().isNotEmpty,
    );

    return result;
  }
}
