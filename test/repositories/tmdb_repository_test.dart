import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/fields/movie_localization_fields.dart';
import 'package:pesalistas/repositories/tmdb_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient _client() {
  return SupabaseClient('https://example.supabase.co', 'dummy-anon-key');
}

void main() {
  group('TmdbRepository.normalizeMovieRow', () {
    test('normalizes valid TMDb rows', () {
      final repository = TmdbRepository(_client());

      final row = repository.normalizeMovieRow({
        AppMovieFields.tmdbId: '603',
        AppMovieFields.imdbId: ' tt0133093 ',
        AppMovieFields.originalTitle: ' The Matrix ',
        AppMovieFields.originalLanguage: ' en ',
        AppMovieFields.releaseDate: '1999-03-31',
        AppMovieFields.releaseYear: '1999',
        AppMovieFields.posterPath: ' /poster.jpg ',
        AppMovieFields.backdropPath: ' /backdrop.jpg ',
        AppMovieFields.popularity: '80.5',
        AppMovieFields.voteAverage: '8.2',
        AppMovieFields.voteCount: '25000',
      });

      expect(row[AppMovieFields.tmdbId], 603);
      expect(row[AppMovieFields.imdbId], 'tt0133093');
      expect(row[AppMovieFields.originalTitle], 'The Matrix');
      expect(row[AppMovieFields.originalLanguage], 'en');
      expect(row[AppMovieFields.releaseDate], '1999-03-31');
      expect(row[AppMovieFields.releaseYear], 1999);
      expect(row[AppMovieFields.posterPath], '/poster.jpg');
      expect(row[AppMovieFields.backdropPath], '/backdrop.jpg');
      expect(row[AppMovieFields.popularity], 80.5);
      expect(row[AppMovieFields.voteAverage], 8.2);
      expect(row[AppMovieFields.voteCount], 25000);
      expect(row[AppMovieFields.source], 'tmdb');
      expect(
        DateTime.tryParse(row[AppMovieFields.fetchedAt].toString()),
        isNotNull,
      );
      expect(
        DateTime.tryParse(row[AppMovieFields.updatedAt].toString()),
        isNotNull,
      );
    });

    test('throws when tmdb id is missing', () {
      final repository = TmdbRepository(_client());

      expect(
        () => repository.normalizeMovieRow({AppMovieFields.title: 'No id'}),
        throwsException,
      );
    });
  });

  group('TmdbRepository.normalizeMovieLocalizationRow', () {
    test('uses nested localization data when present', () {
      final repository = TmdbRepository(_client());

      final row = repository.normalizeMovieLocalizationRow(
        movieRow: {
          'localization': {
            AppMovieLocalizationFields.title: 'Matrix',
            AppMovieLocalizationFields.overview: 'Descripción localizada',
            AppMovieLocalizationFields.tagline: 'Bienvenido al mundo real',
            AppMovieLocalizationFields.posterUrl: 'poster-es.jpg',
            AppMovieLocalizationFields.backdropUrl: 'backdrop-es.jpg',
            AppMovieLocalizationFields.fetchedAt: '2026-01-02T03:04:05.000Z',
          },
        },
        tmdbId: 603,
        languageCode: 'es-ES',
      );

      expect(row[AppMovieLocalizationFields.tmdbId], 603);
      expect(row[AppMovieLocalizationFields.languageCode], 'es-ES');
      expect(row[AppMovieLocalizationFields.title], 'Matrix');
      expect(
        row[AppMovieLocalizationFields.overview],
        'Descripción localizada',
      );
      expect(
        row[AppMovieLocalizationFields.tagline],
        'Bienvenido al mundo real',
      );
      expect(row[AppMovieLocalizationFields.posterUrl], 'poster-es.jpg');
      expect(row[AppMovieLocalizationFields.backdropUrl], 'backdrop-es.jpg');
      expect(
        row[AppMovieLocalizationFields.fetchedAt],
        '2026-01-02T03:04:05.000Z',
      );
      expect(
        row[AppMovieLocalizationFields.rawJson],
        isA<Map<String, dynamic>>(),
      );
    });
  });

  group('TmdbRepository.mergeMovieWithLocalization', () {
    test(
      'localized fields override base display fields and add compatibility fields',
      () {
        final repository = TmdbRepository(_client());

        final merged = repository.mergeMovieWithLocalization(
          {
            AppMovieFields.tmdbId: 603,
            AppMovieFields.originalTitle: 'The Matrix',
            AppMovieFields.releaseYear: 1999,
            AppMovieFields.voteAverage: 8.234,
          },
          {
            AppMovieLocalizationFields.languageCode: 'es-ES',
            AppMovieLocalizationFields.title: 'Matrix',
            AppMovieLocalizationFields.overview: 'Descripción',
            AppMovieLocalizationFields.posterUrl: 'poster.jpg',
            AppMovieLocalizationFields.backdropUrl: 'backdrop.jpg',
            AppMovieLocalizationFields.rawJson: {'localized': true},
          },
        );

        expect(merged[AppMovieFields.title], 'Matrix');
        expect(merged[AppMovieFields.overview], 'Descripción');
        expect(merged[AppMovieFields.plot], 'Descripción');
        expect(merged[AppMovieFields.posterUrl], 'poster.jpg');
        expect(merged[AppMovieFields.backdropUrl], 'backdrop.jpg');
        expect(merged[AppMovieFields.year], '1999');
        expect(merged[AppMovieFields.imdbRating], '8.2');
        expect(merged['localized_language_code'], 'es-ES');
        expect(merged['localized_raw_json'], {'localized': true});
      },
    );

    test('falls back to original title when localization has no title', () {
      final repository = TmdbRepository(_client());

      final merged = repository.mergeMovieWithLocalization(
        {AppMovieFields.originalTitle: 'Original'},
        {AppMovieLocalizationFields.title: '   '},
      );

      expect(merged[AppMovieFields.title], 'Original');
    });
  });
}
