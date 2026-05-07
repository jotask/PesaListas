import 'dart:convert';

class OpenFoodFactsProduct {
  const OpenFoodFactsProduct({
    required this.barcode,
    required this.name,
    required this.rawResponse,
    required this.rawProduct,
    this.brand,
    this.quantity,
    this.imageUrl,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? imageUrl;

  final Map<String, dynamic> rawResponse;
  final Map<String, dynamic> rawProduct;

  String get prettyRawProductJson {
    return const JsonEncoder.withIndent('  ').convert(rawProduct);
  }

  String get prettyRawResponseJson {
    return const JsonEncoder.withIndent('  ').convert(rawResponse);
  }

  factory OpenFoodFactsProduct.fromJson({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    final product = json['product'];

    if (product is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenFoodFacts product response.');
    }

    final name =
        _nullableText(product['product_name_es']) ??
        _nullableText(product['product_name_en']) ??
        _nullableText(product['product_name']) ??
        barcode;

    return OpenFoodFactsProduct(
      barcode: barcode,
      name: name,
      brand: _nullableText(product['brands']),
      quantity: _nullableText(product['quantity']),
      imageUrl: _nullableText(product['image_front_url']),
      rawResponse: json,
      rawProduct: product,
    );
  }

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }
}
