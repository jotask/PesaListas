import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/repositories/catalog_item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _client() {
  return SupabaseClient('https://example.supabase.co', 'dummy-anon-key');
}

void main() {
  group('CatalogItemRepository.normalizeName', () {
    test('trims, lowercases, collapses spaces, and uses underscores', () {
      final repository = CatalogItemRepository(_client());

      expect(repository.normalizeName('  Pan Integral  '), 'pan_integral');
      expect(
        repository.normalizeName('Leche   Sin   Lactosa'),
        'leche_sin_lactosa',
      );
    });

    test('keeps supported accented characters and hyphens', () {
      final repository = CatalogItemRepository(_client());

      expect(
        repository.normalizeName('Café con leche - ñame ç'),
        'café_con_leche_-_ñame_ç',
      );
    });

    test('removes unsupported punctuation', () {
      final repository = CatalogItemRepository(_client());

      expect(repository.normalizeName('Milk!!! 2L @ home'), 'milk_2l__home');
    });
  });
}
