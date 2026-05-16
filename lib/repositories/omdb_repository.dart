import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OmdbRepository {
  OmdbRepository(this._client, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final SupabaseClient _client;
  final http.Client _httpClient;

  Uri _omdbUri(Map<String, String> queryParameters) {
    final apiKey = AppConfig.omdbApiKey.trim();

    if (apiKey.isEmpty) {
      throw StateError(
        'OMDb API key is missing. Run the app with --dart-define=OMDB_API_KEY=your_key',
      );
    }

    return Uri.parse(
      AppConfig.omdbBaseUrl,
    ).replace(queryParameters: {'apikey': apiKey, ...queryParameters});
  }

  String? _omdbText(dynamic value) {
    final text = AppValueParsing.textOrNull(value);

    if (text == null) return null;

    if (text.toUpperCase() == 'N/A') return null;

    return text;
  }

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final searchText = query.trim();

    if (searchText.isEmpty) {
      return [];
    }

    final uri = _omdbUri({'s': searchText, 'type': 'movie'});

    final response = await _httpClient.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OMDb search failed with status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('OMDb returned invalid JSON.');
    }

    final responseValue = decoded['Response']?.toString();

    if (responseValue == 'False') {
      return [];
    }

    final search = decoded['Search'];

    if (search is! List) {
      return [];
    }

    return search
        .whereType<Map>()
        .map((movie) => movie.cast<String, dynamic>())
        .map(searchJsonToMoviePreview)
        .where((movie) {
          final imdbId = movie[AppMovieFields.imdbId]?.toString();
          final title = movie[AppMovieFields.title]?.toString();

          return imdbId != null &&
              imdbId.isNotEmpty &&
              title != null &&
              title.isNotEmpty;
        })
        .toList();
  }

  Map<String, dynamic> searchJsonToMoviePreview(Map<String, dynamic> json) {
    return {
      AppMovieFields.imdbId: _omdbText(json['imdbID']),
      AppMovieFields.title: _omdbText(json['Title']) ?? 'Unknown movie',
      AppMovieFields.year: _omdbText(json['Year']),
      AppMovieFields.type: _omdbText(json['Type']),
      AppMovieFields.posterUrl: _omdbText(json['Poster']),
      AppMovieFields.source: 'omdb',
      AppMovieFields.rawJson: json,
      AppMovieFields.fetchedAt: DateTime.now().toUtc().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> fetchMovieDetailsFromOmdb(String imdbId) async {
    final cleanImdbId = imdbId.trim();

    if (cleanImdbId.isEmpty) {
      throw ArgumentError('IMDb id is required.');
    }

    final uri = _omdbUri({'i': cleanImdbId, 'plot': 'full'});

    final response = await _httpClient.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OMDb details request failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('OMDb returned invalid JSON.');
    }

    final responseValue = decoded['Response']?.toString();

    if (responseValue == 'False') {
      final error = decoded['Error']?.toString() ?? 'Unknown OMDb error.';
      throw Exception(error);
    }

    return detailsJsonToMovieRow(decoded);
  }

  Map<String, dynamic> detailsJsonToMovieRow(Map<String, dynamic> json) {
    final imdbId = _omdbText(json['imdbID']);

    if (imdbId == null || imdbId.isEmpty) {
      throw Exception('OMDb movie details did not include imdbID.');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    return {
      AppMovieFields.imdbId: imdbId,
      AppMovieFields.title: _omdbText(json['Title']) ?? 'Unknown movie',
      AppMovieFields.year: _omdbText(json['Year']),
      AppMovieFields.rated: _omdbText(json['Rated']),
      AppMovieFields.released: _omdbText(json['Released']),
      AppMovieFields.runtime: _omdbText(json['Runtime']),
      AppMovieFields.genre: _omdbText(json['Genre']),
      AppMovieFields.director: _omdbText(json['Director']),
      AppMovieFields.writer: _omdbText(json['Writer']),
      AppMovieFields.actors: _omdbText(json['Actors']),
      AppMovieFields.plot: _omdbText(json['Plot']),
      AppMovieFields.language: _omdbText(json['Language']),
      AppMovieFields.country: _omdbText(json['Country']),
      AppMovieFields.awards: _omdbText(json['Awards']),
      AppMovieFields.posterUrl: _omdbText(json['Poster']),
      AppMovieFields.imdbRating: _omdbText(json['imdbRating']),
      AppMovieFields.imdbVotes: _omdbText(json['imdbVotes']),
      AppMovieFields.type: _omdbText(json['Type']),
      AppMovieFields.rawJson: json,
      AppMovieFields.source: 'omdb',
      AppMovieFields.fetchedAt: now,
      AppMovieFields.updatedAt: now,
    };
  }

  Future<Map<String, dynamic>?> getCachedMovie(String imdbId) async {
    final cleanImdbId = imdbId.trim();

    if (cleanImdbId.isEmpty) {
      return null;
    }

    final result = await _client
        .from(AppTables.movieCatalog)
        .select()
        .eq(AppMovieFields.imdbId, cleanImdbId)
        .maybeSingle();

    return result;
  }

  Future<Map<String, dynamic>> cacheMovie(Map<String, dynamic> movieRow) async {
    final result = await _client
        .from(AppTables.movieCatalog)
        .upsert(movieRow, onConflict: AppMovieFields.imdbId)
        .select()
        .single();

    return result;
  }

  Future<Map<String, dynamic>> fetchAndCacheMovieByImdbId(
    String imdbId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await getCachedMovie(imdbId);

      if (cached != null) {
        return cached;
      }
    }

    final movieRow = await fetchMovieDetailsFromOmdb(imdbId);
    return cacheMovie(movieRow);
  }

  Future<void> linkMovieToItem({
    required String itemId,
    required String imdbId,
  }) async {
    final cleanItemId = itemId.trim();
    final cleanImdbId = imdbId.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    if (cleanImdbId.isEmpty) {
      throw ArgumentError('IMDb id is required.');
    }

    await fetchAndCacheMovieByImdbId(cleanImdbId);

    await _client
        .from(AppTables.items)
        .update({AppItemFields.movieImdbId: cleanImdbId})
        .eq(AppItemFields.id, cleanItemId);
  }

  Future<void> unlinkMovieFromItem(String itemId) async {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) {
      throw ArgumentError('Item id is required.');
    }

    await _client
        .from(AppTables.items)
        .update({AppItemFields.movieImdbId: null})
        .eq(AppItemFields.id, cleanItemId);
  }

  Future<List<Map<String, dynamic>>> getCachedMoviesForItems(
    List<Map<String, dynamic>> items,
  ) async {
    final imdbIds = items
        .map((item) => item[AppItemFields.movieImdbId]?.toString())
        .whereType<String>()
        .where((imdbId) => imdbId.isNotEmpty)
        .toSet()
        .toList();

    if (imdbIds.isEmpty) {
      return [];
    }

    final response = await _client
        .from(AppTables.movieCatalog)
        .select()
        .inFilter(AppMovieFields.imdbId, imdbIds);

    return List<Map<String, dynamic>>.from(response);
  }
}
