import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/fields/product_fields.dart';
import 'package:pesalistas/core/fields/product_localization_fields.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _client() {
  return SupabaseClient('https://example.supabase.co', 'dummy-anon-key');
}

void main() {
  group('ProductRepository.openFoodFactsJsonToProductRow', () {
    test('normalizes found Open Food Facts product', () {
      final repository = ProductRepository(_client());

      final row = repository.openFoodFactsJsonToProductRow(
        barcode: '8410000000000',
        json: {
          'status': 1,
          'product': {
            'product_name': ' Tomate frito ',
            'product_name_en': 'Fried tomato',
            'brands': ' Brand A ',
            'quantity': ' 350 g ',
            'image_front_url': ' https://images.example/front.jpg ',
            'categories': ' Groceries, Sauces ',
            'nutriscore_grade': 'b',
            'nova_group': '3',
            'ecoscore_grade': 'a',
          },
        },
      );

      expect(row[AppProductFields.barcode], '8410000000000');
      expect(row[AppProductFields.name], 'Tomate frito');
      expect(row[AppProductFields.brand], 'Brand A');
      expect(row[AppProductFields.quantity], '350 g');
      expect(
        row[AppProductFields.imageUrl],
        'https://images.example/front.jpg',
      );
      expect(row[AppProductFields.categories], 'Groceries, Sauces');
      expect(row[AppProductFields.nutriscore], 'b');
      expect(row[AppProductFields.novaGroup], 3);
      expect(row[AppProductFields.ecoscore], 'a');
      expect(row[AppProductFields.source], 'openfoodfacts');
      expect(row[AppProductFields.status], AppProductStatus.found);
      expect(
        DateTime.tryParse(row[AppProductFields.fetchedAt].toString()),
        isNotNull,
      );
      expect(
        DateTime.tryParse(row[AppProductFields.updatedAt].toString()),
        isNotNull,
      );
    });

    test('returns not found row when status is not found', () {
      final repository = ProductRepository(_client());

      final row = repository.openFoodFactsJsonToProductRow(
        barcode: 'missing-barcode',
        json: {'status': 0},
      );

      expect(row[AppProductFields.barcode], 'missing-barcode');
      expect(row[AppProductFields.name], isNull);
      expect(row[AppProductFields.status], AppProductStatus.notFound);
      expect(row[AppProductFields.source], 'openfoodfacts');
    });
  });

  group('ProductRepository.openFoodFactsJsonToLocalizationRow', () {
    test('prefers requested language fields before generic fallback', () {
      final repository = ProductRepository(_client());

      final row = repository.openFoodFactsJsonToLocalizationRow(
        barcode: '8410000000000',
        languageCode: 'es',
        countryCode: 'es',
        json: {
          'status': 1,
          'product': {
            'product_name_es': 'Tomate frito',
            'product_name': 'Generic name',
            'product_name_en': 'Fried tomato',
            'generic_name_es': 'Salsa de tomate',
            'brands': 'Brand A',
            'quantity': '350 g',
            'categories_es': 'Comestibles, Salsas',
            'categories': 'Groceries, Sauces',
            'labels_es': 'Sin gluten',
            'labels': 'Gluten free',
            'image_front_url': 'https://images.example/es.jpg',
          },
        },
      );

      expect(row[AppProductLocalizationFields.barcode], '8410000000000');
      expect(row[AppProductLocalizationFields.languageCode], 'es');
      expect(row[AppProductLocalizationFields.countryCode], 'es');
      expect(row[AppProductLocalizationFields.name], 'Tomate frito');
      expect(row[AppProductLocalizationFields.brand], 'Brand A');
      expect(row[AppProductLocalizationFields.quantity], '350 g');
      expect(
        row[AppProductLocalizationFields.categories],
        'Comestibles, Salsas',
      );
      expect(row[AppProductLocalizationFields.labels], 'Sin gluten');
      expect(
        row[AppProductLocalizationFields.imageUrl],
        'https://images.example/es.jpg',
      );
    });
  });

  group('ProductRepository.mergeProductWithLocalization', () {
    test('localized fields override base display fields', () {
      final repository = ProductRepository(_client());

      final merged = repository.mergeProductWithLocalization(
        {
          AppProductFields.barcode: '123',
          AppProductFields.name: 'English name',
          AppProductFields.brand: 'Base brand',
          AppProductFields.quantity: '1 kg',
          AppProductFields.categories: 'Base category',
          AppProductFields.imageUrl: 'base.jpg',
        },
        {
          AppProductLocalizationFields.languageCode: 'es',
          AppProductLocalizationFields.countryCode: 'es',
          AppProductLocalizationFields.name: 'Nombre español',
          AppProductLocalizationFields.brand: 'Marca local',
          AppProductLocalizationFields.quantity: '500 g',
          AppProductLocalizationFields.categories: 'Categoría local',
          AppProductLocalizationFields.labels: 'Etiqueta local',
          AppProductLocalizationFields.imageUrl: 'local.jpg',
          AppProductLocalizationFields.rawJson: {'localized': true},
        },
      );

      expect(merged[AppProductFields.name], 'Nombre español');
      expect(merged[AppProductFields.brand], 'Marca local');
      expect(merged[AppProductFields.quantity], '500 g');
      expect(merged[AppProductFields.categories], 'Categoría local');
      expect(merged[AppProductFields.imageUrl], 'local.jpg');
      expect(merged['localized_language_code'], 'es');
      expect(merged['localized_country_code'], 'es');
      expect(merged['localized_labels'], 'Etiqueta local');
      expect(merged['localized_raw_json'], {'localized': true});
    });

    test('falls back to base fields when localization fields are blank', () {
      final repository = ProductRepository(_client());

      final merged = repository.mergeProductWithLocalization(
        {AppProductFields.name: 'Base name'},
        {AppProductLocalizationFields.name: '   '},
      );

      expect(merged[AppProductFields.name], 'Base name');
    });
  });

  group('ProductRepository helpers', () {
    test('isFresh returns true only inside max cache age', () {
      final repository = ProductRepository(_client());
      final now = DateTime.now().toUtc();

      expect(
        repository.isFresh({
          AppProductFields.fetchedAt: now
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        }, const Duration(days: 2)),
        isTrue,
      );
      expect(
        repository.isFresh({
          AppProductFields.fetchedAt: now
              .subtract(const Duration(days: 5))
              .toIso8601String(),
        }, const Duration(days: 2)),
        isFalse,
      );
      expect(
        repository.isFresh({
          AppProductFields.fetchedAt: 'not-a-date',
        }, const Duration(days: 2)),
        isFalse,
      );
    });

    test('firstText returns first non-empty trimmed text', () {
      final repository = ProductRepository(_client());

      expect(repository.firstText([null, '', '  first  ', 'second']), 'first');
      expect(repository.firstText([null, '   ']), isNull);
    });
  });
}
