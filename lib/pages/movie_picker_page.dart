import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/repositories/tmdb_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoviePickerPage extends StatefulWidget {
  const MoviePickerPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<MoviePickerPage> createState() => _MoviePickerPageState();
}

class _MoviePickerPageState extends State<MoviePickerPage> {
  late final TmdbRepository tmdbRepository;
  late final TextEditingController searchController;

  bool searching = false;
  bool selecting = false;
  String? errorMessage;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();

    tmdbRepository = TmdbRepository(Supabase.instance.client);
    searchController = TextEditingController(text: widget.initialQuery ?? '');

    final initialQuery = widget.initialQuery?.trim();

    if (initialQuery != null && initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchMovies();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchMovies() async {
    final query = searchController.text.trim();

    if (query.isEmpty || searching) return;

    FocusScope.of(context).unfocus();

    setState(() {
      searching = true;
      errorMessage = null;
      results = [];
    });

    try {
      final movies = await tmdbRepository.searchMovies(query);

      if (!mounted) return;

      setState(() => results = movies);
    } catch (error) {
      if (!mounted) return;

      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => searching = false);
      }
    }
  }

  Future<void> selectMovie(Map<String, dynamic> moviePreview) async {
    if (selecting) return;

    final tmdbId = AppValueParsing.intOrNull(
      moviePreview[AppMovieFields.tmdbId],
    );

    if (tmdbId == null) {
      setState(() => errorMessage = 'This movie result has no TMDb id.');
      return;
    }

    setState(() {
      selecting = true;
      errorMessage = null;
    });

    try {
      final cachedMovie = await tmdbRepository.cacheMovie(moviePreview);

      if (!mounted) return;

      Navigator.of(context).pop(cachedMovie);
    } catch (error) {
      if (!mounted) return;

      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => selecting = false);
      }
    }
  }

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find movie')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _MoviePickerHeaderCard(),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              enabled: !searching && !selecting,
              decoration: InputDecoration(
                labelText: 'Movie title',
                hintText: 'The Matrix',
                prefixIcon: const Icon(Icons.movie_filter_outlined),
                suffixIcon: IconButton(
                  onPressed: !searching && !selecting ? searchMovies : null,
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchMovies(),
            ),
            if (searching) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (selecting) ...[
              const SizedBox(height: 16),
              const AppMessageCard(
                icon: Icons.download_done_outlined,
                message: 'Saving TMDb movie cache...',
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              AppMessageCard(
                icon: Icons.error_outline,
                message: errorMessage!,
                tone: AppMessageCardTone.error,
              ),
            ],
            const SizedBox(height: 16),
            if (!searching && results.isEmpty)
              const AppMessageCard(
                icon: Icons.search_outlined,
                message: 'Search for a movie to link it to this list item.',
              )
            else
              for (final movie in results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MovieSearchResultCard(
                    movie: movie,
                    disabled: selecting,
                    onTap: () => selectMovie(movie),
                  ),
                ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MoviePickerHeaderCard extends StatelessWidget {
  const _MoviePickerHeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.local_movies_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Movie database',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search TMDb using your app language and save localized movie details.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieSearchResultCard extends StatelessWidget {
  const _MovieSearchResultCard({
    required this.movie,
    required this.disabled,
    required this.onTap,
  });

  final Map<String, dynamic> movie;
  final bool disabled;
  final VoidCallback onTap;

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  Map<String, dynamic> get localization {
    final value = movie['localization'];

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final title = text(
      localization[AppMovieFields.title],
      fallback: text(movie[AppMovieFields.originalTitle], fallback: 'Unknown'),
    );

    final year = text(movie[AppMovieFields.releaseYear]);
    final overview = text(localization[AppMovieFields.overview], fallback: '');

    final posterUrl = text(
      localization[AppMovieFields.posterUrl],
      fallback: '',
    );

    final tmdbId = text(movie[AppMovieFields.tmdbId]);

    return Card(
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImageThumbnail(
                imageUrl: posterUrl,
                width: 58,
                height: 86,
                borderRadius: 12,
                fallbackIcon: Icons.movie_outlined,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(year == '—' ? 'TMDb $tmdbId' : '$year • TMDb $tmdbId'),
                    if (overview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        overview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
