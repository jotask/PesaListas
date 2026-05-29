abstract final class AppShoppingStores {
  static const mercadona = 'mercadona';
  static const consum = 'consum';
  static const lidl = 'lidl';
  static const aldi = 'aldi';
  static const carrefour = 'carrefour';
  static const dia = 'dia';
  static const familycash = 'familycash';
  static const other = 'other';

  static const defaultStore = mercadona;

  static const values = [
    mercadona,
    consum,
    lidl,
    aldi,
    carrefour,
    dia,
    familycash,
    other,
  ];

  static String label(String value) {
    switch (value) {
      case mercadona:
        return 'Mercadona';
      case consum:
        return 'Consum';
      case lidl:
        return 'Lidl';
      case aldi:
        return 'Aldi';
      case carrefour:
        return 'Carrefour';
      case dia:
        return 'DIA';
      case familycash:
        return 'Family Cash';
      case other:
        return 'Other';
      default:
        return 'Other';
    }
  }
}
