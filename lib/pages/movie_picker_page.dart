import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_message_card.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/repositories/omdb_repository.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoviePickerPage extends StatefulWidget {
  const MoviePickerPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<MoviePickerPage> createState() => _MoviePickerPageState();
}

class _MoviePickerPageState extends State<MoviePickerPage> {
  late final OmdbRepository omdbRepository;
  late final TextEditingController searchController;

  bool searching = false;
  bool selecting = false;
  String? errorMessage;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();

    omdbRepository = OmdbRepository(Supabase.instance.client);
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
      final movies = await omdbRepository.searchMovies(query);

      if (!mounted) return;

      setState(() {
        results = movies;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => searching = false);
      }
    }
  }

  Future<void> selectMovie(Map<String, dynamic> moviePreview) async {
    if (selecting) return;

    final imdbId = moviePreview[AppMovieFields.imdbId]?.toString();

    if (imdbId == null || imdbId.trim().isEmpty) {
      setState(() => errorMessage = 'This movie result has no IMDb id.');
      return;
    }

    setState(() {
      selecting = true;
      errorMessage = null;
    });

    try {
      final cachedMovie = await omdbRepository.fetchAndCacheMovieByImdbId(
        imdbId,
        forceRefresh: false,
      );

      if (!mounted) return;

      Navigator.of(context).pop(cachedMovie);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
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
    final hasApiKey = AppConfig.hasOmdbApiKey;

    return Scaffold(
      appBar: AppBar(title: const Text('Find movie')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MoviePickerHeaderCard(hasApiKey: hasApiKey),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              enabled: hasApiKey && !searching && !selecting,
              decoration: InputDecoration(
                labelText: 'Movie title',
                hintText: 'The Matrix',
                prefixIcon: const Icon(Icons.movie_filter_outlined),
                suffixIcon: IconButton(
                  onPressed: hasApiKey && !searching && !selecting
                      ? searchMovies
                      : null,
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
                message: 'Loading movie details and saving cache...',
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
            if (!hasApiKey) ...[
              const SizedBox(height: 16),
              const AppMessageCard(
                icon: Icons.error_outline,
                message:
                    'OMDb API key is missing. Run the app with --dart-define=OMDB_API_KEY=your_key.',
                tone: AppMessageCardTone.error,
              ),
            ],
            const SizedBox(height: 16),
            if (!searching && results.isEmpty && hasApiKey)
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
  const _MoviePickerHeaderCard({required this.hasApiKey});

  final bool hasApiKey;

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
                    hasApiKey
                        ? 'Search OMDb and save the movie details in your cache.'
                        : 'OMDb API key is not configured.',
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

  String get posterUrl {
    return text(movie[AppMovieFields.posterUrl], fallback: '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = text(movie[AppMovieFields.title], fallback: 'Unknown movie');
    final year = text(movie[AppMovieFields.year]);
    final type = text(movie[AppMovieFields.type]);

    return Card(
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AppNetworkImageThumbnail(
                imageUrl: posterUrl,
                width: 54,
                height: 78,
                borderRadius: 10,
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
                    Text('$year • $type', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      text(movie[AppMovieFields.imdbId]),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
