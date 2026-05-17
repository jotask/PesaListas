import 'package:flutter/material.dart';

class AppNetworkImageThumbnail extends StatelessWidget {
  const AppNetworkImageThumbnail({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.fallbackIcon = Icons.image_outlined,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final IconData fallbackIcon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return _AppImageFallback(
        width: width,
        height: height,
        borderRadius: borderRadius,
        icon: fallbackIcon,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) {
          return _AppImageFallback(
            width: width,
            height: height,
            borderRadius: borderRadius,
            icon: fallbackIcon,
          );
        },
      ),
    );
  }
}

class _AppImageFallback extends StatelessWidget {
  const _AppImageFallback({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.icon,
  });

  final double width;
  final double height;
  final double borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
