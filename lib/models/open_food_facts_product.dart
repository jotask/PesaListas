class OpenFoodFactsProduct {
  const OpenFoodFactsProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.quantity,
    this.imageUrl,
    this.categories,
    this.ingredients,
    this.allergens,
    this.nutriscoreGrade,
    this.novaGroup,
    this.energyKcal100g,
    this.fat100g,
    this.saturatedFat100g,
    this.carbohydrates100g,
    this.sugars100g,
    this.proteins100g,
    this.salt100g,
    this.fiber100g,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? imageUrl;
  final String? categories;
  final String? ingredients;
  final String? allergens;
  final String? nutriscoreGrade;
  final String? novaGroup;

  final String? energyKcal100g;
  final String? fat100g;
  final String? saturatedFat100g;
  final String? carbohydrates100g;
  final String? sugars100g;
  final String? proteins100g;
  final String? salt100g;
  final String? fiber100g;

  factory OpenFoodFactsProduct.fromJson({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    final product = json['product'];

    if (product is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenFoodFacts product response.');
    }

    final nutriments = product['nutriments'];

    final nutrimentsMap = nutriments is Map<String, dynamic>
        ? nutriments
        : <String, dynamic>{};

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
      categories: _nullableText(product['categories']),
      ingredients:
          _nullableText(product['ingredients_text_es']) ??
          _nullableText(product['ingredients_text_en']) ??
          _nullableText(product['ingredients_text']),
      allergens:
          _cleanTagsText(product['allergens_tags']) ??
          _nullableText(product['allergens']),
      nutriscoreGrade:
          _nullableText(product['nutriscore_grade']) ??
          _nullableText(product['nutrition_grades']),
      novaGroup: _nullableText(product['nova_group']),
      energyKcal100g: _nutrimentText(
        nutrimentsMap,
        key: 'energy-kcal_100g',
        suffix: 'kcal / 100g',
      ),
      fat100g: _nutrimentText(
        nutrimentsMap,
        key: 'fat_100g',
        suffix: 'g / 100g',
      ),
      saturatedFat100g: _nutrimentText(
        nutrimentsMap,
        key: 'saturated-fat_100g',
        suffix: 'g / 100g',
      ),
      carbohydrates100g: _nutrimentText(
        nutrimentsMap,
        key: 'carbohydrates_100g',
        suffix: 'g / 100g',
      ),
      sugars100g: _nutrimentText(
        nutrimentsMap,
        key: 'sugars_100g',
        suffix: 'g / 100g',
      ),
      proteins100g: _nutrimentText(
        nutrimentsMap,
        key: 'proteins_100g',
        suffix: 'g / 100g',
      ),
      salt100g: _nutrimentText(
        nutrimentsMap,
        key: 'salt_100g',
        suffix: 'g / 100g',
      ),
      fiber100g: _nutrimentText(
        nutrimentsMap,
        key: 'fiber_100g',
        suffix: 'g / 100g',
      ),
    );
  }

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static String? _nutrimentText(
    Map<String, dynamic> nutriments, {
    required String key,
    required String suffix,
  }) {
    final value = nutriments[key];

    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return '$text $suffix';
  }

  static String? _cleanTagsText(dynamic value) {
    if (value is List) {
      final cleaned = value
          .map((item) => item.toString().replaceFirst('en:', '').trim())
          .where((item) => item.isNotEmpty)
          .join(', ');

      return cleaned.isEmpty ? null : cleaned;
    }

    return _nullableText(value);
  }
}
