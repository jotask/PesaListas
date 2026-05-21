import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pesalistas/models/open_food_facts_product.dart';
import 'package:pesalistas/core/app_analytics.dart';

class OpenFoodFactsRepository {
  const OpenFoodFactsRepository({http.Client? client, this.useStaging = true})
    : _client = client;

  final http.Client? _client;
  final bool useStaging;

  Future<OpenFoodFactsProduct?> getProductByBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();

    if (cleanBarcode.isEmpty) {
      return null;
    }

    final client = _client ?? http.Client();

    try {
      final host = useStaging
          ? 'world.openfoodfacts.net'
          : 'world.openfoodfacts.org';

      final uri = Uri.https(host, '/api/v2/product/$cleanBarcode.json');

      final headers = <String, String>{
        'Accept': 'application/json',
        'User-Agent':
            'PesaListas/0.1 Flutter app - contact: acachitoro@gmail.com',
      };

      if (useStaging) {
        headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode('off:off'))}';
      }

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 404) {
        await AppAnalytics.instance.logProductLookup(
          source: 'open_food_facts_direct',
          found: false,
          forceRefresh: true,
          useStaging: useStaging,
        );

        return null;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'OpenFoodFacts request failed with status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid OpenFoodFacts response.');
      }

      final status = decoded['status'];

      if (status == 0 || status == '0') {
        await AppAnalytics.instance.logProductLookup(
          source: 'open_food_facts_direct',
          found: false,
          forceRefresh: true,
          useStaging: useStaging,
        );

        return null;
      }

      final product = OpenFoodFactsProduct.fromJson(
        barcode: cleanBarcode,
        json: decoded,
      );

      await AppAnalytics.instance.logProductLookup(
        source: 'open_food_facts_direct',
        found: true,
        forceRefresh: true,
        useStaging: useStaging,
      );

      return product;
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
