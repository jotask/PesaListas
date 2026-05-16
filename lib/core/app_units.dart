enum AppUnitType {
  pieces('pcs', 'Pieces'),
  unit('unit', 'Units'),
  gram('g', 'Grams'),
  kilogram('kg', 'Kilograms'),
  milliliter('ml', 'Milliliters'),
  liter('l', 'Liters'),
  pack('pack', 'Pack'),
  bottle('bottle', 'Bottle'),
  can('can', 'Can'),
  jar('jar', 'Jar'),
  box('box', 'Box'),
  bag('bag', 'Bag'),
  teaspoon('tsp', 'Teaspoon'),
  tablespoon('tbsp', 'Tablespoon');

  const AppUnitType(this.value, this.label);

  final String value;
  final String label;

  static AppUnitType? fromValue(String? value) {
    final normalized = normalize(value);

    if (normalized == null) {
      return null;
    }

    for (final unit in AppUnitType.values) {
      if (unit.value == normalized) {
        return unit;
      }
    }

    return null;
  }

  static String? normalize(String? value) {
    final text = value?.trim().toLowerCase();

    if (text == null || text.isEmpty) {
      return null;
    }

    switch (text) {
      case 'piece':
      case 'pieces':
      case 'pc':
      case 'pcs':
        return 'pcs';

      case 'u':
      case 'unit':
      case 'units':
        return 'unit';

      case 'gram':
      case 'grams':
      case 'gr':
      case 'g':
        return 'g';

      case 'kilogram':
      case 'kilograms':
      case 'kilo':
      case 'kilos':
      case 'kg':
      case 'kgs':
        return 'kg';

      case 'milliliter':
      case 'milliliters':
      case 'millilitre':
      case 'millilitres':
      case 'ml':
        return 'ml';

      case 'liter':
      case 'liters':
      case 'litre':
      case 'litres':
      case 'lt':
      case 'l':
        return 'l';

      case 'package':
      case 'packet':
      case 'pack':
        return 'pack';

      case 'bottle':
      case 'bottles':
        return 'bottle';

      case 'can':
      case 'cans':
        return 'can';

      case 'jar':
      case 'jars':
        return 'jar';

      case 'box':
      case 'boxes':
        return 'box';

      case 'bag':
      case 'bags':
        return 'bag';

      case 'teaspoon':
      case 'teaspoons':
      case 'tsp':
        return 'tsp';

      case 'tablespoon':
      case 'tablespoons':
      case 'tbsp':
        return 'tbsp';

      default:
        return text;
    }
  }

  static String labelForValue(String? value) {
    final normalized = normalize(value);

    if (normalized == null) {
      return '';
    }

    final unit = fromValue(normalized);

    if (unit == null) {
      return normalized;
    }

    return unit.label;
  }
}
