import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/catalog_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/core/app_analytics.dart';

class CatalogItemRepository {
  CatalogItemRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getRecentCatalogItems({
    int limit = 100,
  }) async {
    final response = await _client
        .from(AppTables.catalogItems)
        .select()
        .order(AppCatalogItemFields.name, ascending: true)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> searchCatalogItems(
    String query, {
    int limit = 50,
  }) async {
    final normalizedQuery = normalizeName(query);

    if (normalizedQuery.isEmpty) {
      return getRecentCatalogItems(limit: limit);
    }

    final response = await _client
        .from(AppTables.catalogItems)
        .select()
        .or(
          '${AppCatalogItemFields.name}.ilike.%$query%,'
          '${AppCatalogItemFields.normalizedName}.ilike.%$normalizedQuery%',
        )
        .order(AppCatalogItemFields.name, ascending: true)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> updateCatalogItem({
    required String catalogItemId,
    required String name,
    String? category,
    String? defaultUnit,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Catalog item name is required.');
    }

    final response = await _client
        .from(AppTables.catalogItems)
        .update({
          AppCatalogItemFields.name: cleanName,
          AppCatalogItemFields.category: AppValueParsing.textOrNull(category),
          AppCatalogItemFields.defaultUnit: AppUnitType.valueOrNull(
            defaultUnit,
          ),
        })
        .eq(AppCatalogItemFields.id, catalogItemId)
        .select()
        .single();

    await AppAnalytics.instance.logCatalogItemUpdated(
      hasCategory: category != null && category.trim().isNotEmpty,
      hasDefaultUnit: defaultUnit != null && defaultUnit.trim().isNotEmpty,
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>?> getCatalogItemByNormalizedName(
    String name,
  ) async {
    final normalizedName = normalizeName(name);

    if (normalizedName.isEmpty) {
      return null;
    }

    final response = await _client
        .from(AppTables.catalogItems)
        .select()
        .eq(AppCatalogItemFields.normalizedName, normalizedName)
        .eq(AppCatalogItemFields.isGlobal, true)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>> createCatalogItem({
    required String name,
    String? category,
    String? defaultUnit,
    String? iconName,
  }) async {
    final cleanName = name.trim();
    final normalizedName = normalizeName(cleanName);

    if (cleanName.isEmpty || normalizedName.isEmpty) {
      throw ArgumentError('Catalog item name is required.');
    }

    final existing = await getCatalogItemByNormalizedName(cleanName);

    if (existing != null) {
      await AppAnalytics.instance.logCatalogItemCreated(
        hasCategory: category != null && category.trim().isNotEmpty,
        hasDefaultUnit: defaultUnit != null && defaultUnit.trim().isNotEmpty,
        reusedExisting: true,
      );

      return existing;
    }

    final row = {
      AppCatalogItemFields.name: cleanName,
      AppCatalogItemFields.normalizedName: normalizedName,
      AppCatalogItemFields.category: AppValueParsing.textOrNull(category),
      AppCatalogItemFields.defaultUnit: AppValueParsing.textOrNull(defaultUnit),
      AppCatalogItemFields.iconName: AppValueParsing.textOrNull(iconName),
      AppCatalogItemFields.createdBy: _client.auth.currentUser?.id,
      AppCatalogItemFields.isGlobal: true,
    };

    try {
      final response = await _client
          .from(AppTables.catalogItems)
          .insert(row)
          .select()
          .single();

      await AppAnalytics.instance.logCatalogItemCreated(
        hasCategory: category != null && category.trim().isNotEmpty,
        hasDefaultUnit: defaultUnit != null && defaultUnit.trim().isNotEmpty,
        reusedExisting: false,
      );

      return response;
    } catch (_) {
      final existingAfterInsert = await getCatalogItemByNormalizedName(
        cleanName,
      );

      if (existingAfterInsert != null) {
        await AppAnalytics.instance.logCatalogItemCreated(
          hasCategory: category != null && category.trim().isNotEmpty,
          hasDefaultUnit: defaultUnit != null && defaultUnit.trim().isNotEmpty,
          reusedExisting: true,
        );

        return existingAfterInsert;
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> findOrCreateCatalogItem({
    required String name,
    String? category,
    String? defaultUnit,
    String? iconName,
  }) async {
    final existing = await getCatalogItemByNormalizedName(name);

    if (existing != null) {
      return existing;
    }

    return createCatalogItem(
      name: name,
      category: category,
      defaultUnit: defaultUnit,
      iconName: iconName,
    );
  }

  String normalizeName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9áéíóúüñçàèìòùâêîôûäëïöü\s-]'), '')
        .replaceAll(' ', '_');
  }
}
