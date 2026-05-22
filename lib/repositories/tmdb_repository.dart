import 'dart:convert';

import 'package:pesalistas/core/app_language.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/fields/movie_localization_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TmdbRepository {
  TmdbRepository(this._client);

  final SupabaseClient _client;

  String get languageCode => AppLanguage.tmdbLanguageCode;

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final searchText = query.trim();

    if (searchText.isEmpty) {
      return [];
    }

    final response = await _client.functions.invoke(
      'tmdb-search',
      body: {'query': searchText, 'languageCode': languageCode},
    );

    final data = _asMap(response.data);

    if (response.status < 200 || response.status >= 300) {
      throw Exception(
        data['error']?.toString() ??
            'TMDb search failed with status ${response.status}.',
      );
    }

    final movies = data['movies'];

    if (movies is! List) {
      return [];
    }

    return movies
        .whereType<Map>()
        .map((movie) => Map<String, dynamic>.from(movie))
        .where((movie) {
          return AppValueParsing.intOrNull(movie[AppMovieFields.tmdbId]) !=
              null;
        })
        .toList();
  }

  Future<Map<String, dynamic>> cacheMovie(Map<String, dynamic> movieRow) async {
    final baseRow = normalizeMovieRow(movieRow);
    final tmdbId = baseRow[AppMovieFields.tmdbId] as int;

    final cachedBase = await _client
        .from(AppTables.movieCatalog)
        .upsert(baseRow, onConflict: AppMovieFields.tmdbId)
        .select()
        .single();

    final localizationRow = normalizeMovieLocalizationRow(
      movieRow: movieRow,
      tmdbId: tmdbId,
      languageCode: languageCode,
    );

    final cachedLocalization = await _client
        .from(AppTables.movieCatalogLocalizations)
        .upsert(localizationRow, onConflict: 'tmdb_id,language_code')
        .select()
        .single();

    return mergeMovieWithLocalization(
      Map<String, dynamic>.from(cachedBase),
      Map<String, dynamic>.from(cachedLocalization),
    );
  }

  Future<Map<String, dynamic>?> getCachedMovie(int tmdbId) async {
    final base = await _client
        .from(AppTables.movieCatalog)
        .select()
        .eq(AppMovieFields.tmdbId, tmdbId)
        .maybeSingle();

    if (base == null) {
      return null;
    }

    final localization = await _getMovieLocalization(
      tmdbId: tmdbId,
      languageCode: languageCode,
    );

    return mergeMovieWithLocalization(
      Map<String, dynamic>.from(base),
      localization,
    );
  }

  Future<List<Map<String, dynamic>>> getCachedMoviesForItems(
    List<Map<String, dynamic>> items,
  ) async {
    final tmdbIds = items
        .map(
          (item) => AppValueParsing.intOrNull(item[AppItemFields.movieTmdbId]),
        )
        .whereType<int>()
        .toSet()
        .toList();

    if (tmdbIds.isEmpty) {
      return [];
    }

    final baseResponse = await _client
        .from(AppTables.movieCatalog)
        .select()
        .inFilter(AppMovieFields.tmdbId, tmdbIds);

    final baseMovies = List<Map<String, dynamic>>.from(baseResponse);

    if (baseMovies.isEmpty) {
      return [];
    }

    final localizationResponse = await _client
        .from(AppTables.movieCatalogLocalizations)
        .select()
        .eq(AppMovieLocalizationFields.languageCode, languageCode)
        .inFilter(AppMovieLocalizationFields.tmdbId, tmdbIds);

    final localizations = List<Map<String, dynamic>>.from(localizationResponse);

    final localizationsByTmdbId = {
      for (final localization in localizations)
        AppValueParsing.intOrNull(
          localization[AppMovieLocalizationFields.tmdbId],
        ): localization,
    };

    return baseMovies.map((movie) {
      final tmdbId = AppValueParsing.intOrNull(movie[AppMovieFields.tmdbId]);
      final localization = tmdbId == null
          ? null
          : localizationsByTmdbId[tmdbId];

      return mergeMovieWithLocalization(movie, localization);
    }).toList();
  }

  Future<void> linkMovieToItem({
    required String itemId,
    required Map<String, dynamic> movie,
  }) async {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    final cached = await cacheMovie(movie);
    final tmdbId = AppValueParsing.intOrNull(cached[AppMovieFields.tmdbId]);

    if (tmdbId == null) {
      throw Exception('Movie did not include a TMDb id.');
    }

    await _client
        .from(AppTables.items)
        .update({AppItemFields.movieTmdbId: tmdbId})
        .eq(AppItemFields.id, cleanItemId);
  }

  Future<void> unlinkMovieFromItem(String itemId) async {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    await _client
        .from(AppTables.items)
        .update({AppItemFields.movieTmdbId: null})
        .eq(AppItemFields.id, cleanItemId);
  }

  Map<String, dynamic> normalizeMovieRow(Map<String, dynamic> row) {
    final now = DateTime.now().toUtc().toIso8601String();

    final tmdbId = AppValueParsing.intOrNull(row[AppMovieFields.tmdbId]);

    if (tmdbId == null) {
      throw Exception('Movie row is missing tmdb_id.');
    }

    return {
      AppMovieFields.tmdbId: tmdbId,
      AppMovieFields.imdbId: AppValueParsing.textOrNull(
        row[AppMovieFields.imdbId],
      ),
      AppMovieFields.originalTitle: AppValueParsing.textOrNull(
        row[AppMovieFields.originalTitle],
      ),
      AppMovieFields.originalLanguage: AppValueParsing.textOrNull(
        row[AppMovieFields.originalLanguage],
      ),
      AppMovieFields.releaseDate: AppValueParsing.textOrNull(
        row[AppMovieFields.releaseDate],
      ),
      AppMovieFields.releaseYear: AppValueParsing.intOrNull(
        row[AppMovieFields.releaseYear],
      ),
      AppMovieFields.posterPath: AppValueParsing.textOrNull(
        row[AppMovieFields.posterPath],
      ),
      AppMovieFields.backdropPath: AppValueParsing.textOrNull(
        row[AppMovieFields.backdropPath],
      ),
      AppMovieFields.popularity: _doubleOrNull(row[AppMovieFields.popularity]),
      AppMovieFields.voteAverage: _doubleOrNull(
        row[AppMovieFields.voteAverage],
      ),
      AppMovieFields.voteCount: AppValueParsing.intOrNull(
        row[AppMovieFields.voteCount],
      ),
      AppMovieFields.source: 'tmdb',
      AppMovieFields.rawJson: _rawJson(row),
      AppMovieFields.fetchedAt:
          AppValueParsing.textOrNull(row[AppMovieFields.fetchedAt]) ?? now,
      AppMovieFields.updatedAt: now,
    };
  }

  Map<String, dynamic> normalizeMovieLocalizationRow({
    required Map<String, dynamic> movieRow,
    required int tmdbId,
    required String languageCode,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();

    final localization = movieRow['localization'];

    final source = localization is Map
        ? Map<String, dynamic>.from(localization)
        : movieRow;

    return {
      AppMovieLocalizationFields.tmdbId: tmdbId,
      AppMovieLocalizationFields.languageCode: languageCode,
      AppMovieLocalizationFields.title: AppValueParsing.textOrNull(
        source[AppMovieLocalizationFields.title],
      ),
      AppMovieLocalizationFields.overview: AppValueParsing.textOrNull(
        source[AppMovieLocalizationFields.overview],
      ),
      AppMovieLocalizationFields.tagline: AppValueParsing.textOrNull(
        source[AppMovieLocalizationFields.tagline],
      ),
      AppMovieLocalizationFields.posterUrl: AppValueParsing.textOrNull(
        source[AppMovieLocalizationFields.posterUrl],
      ),
      AppMovieLocalizationFields.backdropUrl: AppValueParsing.textOrNull(
        source[AppMovieLocalizationFields.backdropUrl],
      ),
      AppMovieLocalizationFields.rawJson: source,
      AppMovieLocalizationFields.fetchedAt:
          AppValueParsing.textOrNull(
            source[AppMovieLocalizationFields.fetchedAt],
          ) ??
          now,
      AppMovieLocalizationFields.updatedAt: now,
    };
  }

  Future<Map<String, dynamic>?> _getMovieLocalization({
    required int tmdbId,
    required String languageCode,
  }) async {
    final result = await _client
        .from(AppTables.movieCatalogLocalizations)
        .select()
        .eq(AppMovieLocalizationFields.tmdbId, tmdbId)
        .eq(AppMovieLocalizationFields.languageCode, languageCode)
        .maybeSingle();

    if (result == null) {
      return null;
    }

    return Map<String, dynamic>.from(result);
  }

  Map<String, dynamic> mergeMovieWithLocalization(
    Map<String, dynamic> base,
    Map<String, dynamic>? localization,
  ) {
    final releaseYear = AppValueParsing.intOrNull(
      base[AppMovieFields.releaseYear],
    );

    final voteAverage = _doubleOrNull(base[AppMovieFields.voteAverage]);

    final localizedTitle = AppValueParsing.textOrNull(
      localization?[AppMovieLocalizationFields.title],
    );

    final localizedOverview = AppValueParsing.textOrNull(
      localization?[AppMovieLocalizationFields.overview],
    );

    final posterUrl = AppValueParsing.textOrNull(
      localization?[AppMovieLocalizationFields.posterUrl],
    );

    final backdropUrl = AppValueParsing.textOrNull(
      localization?[AppMovieLocalizationFields.backdropUrl],
    );

    return {
      ...base,

      AppMovieFields.title:
          localizedTitle ??
          AppValueParsing.textOrNull(base[AppMovieFields.originalTitle]) ??
          'Unknown movie',

      AppMovieFields.overview: localizedOverview,
      AppMovieFields.plot: localizedOverview,

      AppMovieFields.posterUrl: posterUrl,
      AppMovieFields.backdropUrl: backdropUrl,

      // Compatibility for existing widgets.
      AppMovieFields.year: releaseYear?.toString(),
      AppMovieFields.imdbRating: voteAverage?.toStringAsFixed(1),

      'localized_language_code':
          localization?[AppMovieLocalizationFields.languageCode],
      'localized_raw_json': localization?[AppMovieLocalizationFields.rawJson],
    };
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String) {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    return {'value': value?.toString()};
  }

  Map<String, dynamic> _rawJson(Map<String, dynamic> row) {
    final raw = row[AppMovieFields.rawJson];

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return row;
  }

  double? _doubleOrNull(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}
