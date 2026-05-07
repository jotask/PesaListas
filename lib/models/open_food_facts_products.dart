class OpenFoodFactsProduct {
  const OpenFoodFactsProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.quantity,
    this.imageUrl,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? imageUrl;

  factory OpenFoodFactsProduct.fromJson({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    final product = json['product'];

    if (product is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenFoodFacts product response.');
    }

    final name =
        product['product_name']?.toString().trim() ??
        product['product_name_es']?.toString().trim() ??
        product['product_name_en']?.toString().trim() ??
        '';

    return OpenFoodFactsProduct(
      barcode: barcode,
      name: name.isEmpty ? barcode : name,
      brand: _nullableText(product['brands']),
      quantity: _nullableText(product['quantity']),
      imageUrl: _nullableText(product['image_front_url']),
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
