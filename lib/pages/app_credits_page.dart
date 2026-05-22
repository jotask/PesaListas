import 'package:flutter/material.dart';

class AppCreditsPage extends StatelessWidget {
  const AppCreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credits & data sources')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _CreditCard(
              icon: Icons.movie_filter_outlined,
              title: 'TMDb',
              subtitle:
                  'Movie search, localized movie metadata, posters, and movie identifiers.',
              notice:
                  'This product uses the TMDB API but is not endorsed or certified by TMDB.',
            ),
            SizedBox(height: 12),
            _CreditCard(
              icon: Icons.menu_book_outlined,
              title: 'Open Library',
              subtitle:
                  'Book search, book metadata, ISBN lookup, and cover data.',
              notice:
                  'Book data is provided by Open Library, an Internet Archive project.',
            ),
            SizedBox(height: 12),
            _CreditCard(
              icon: Icons.qr_code_scanner_outlined,
              title: 'Open Food Facts',
              subtitle:
                  'Product barcode lookup, product metadata, nutrition labels, categories, and images.',
              notice:
                  'Product information is provided by Open Food Facts and is made available under the Open Database License (ODbL).',
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.notice,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String notice;

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
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle),
                  const SizedBox(height: 10),
                  Text(
                    notice,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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
