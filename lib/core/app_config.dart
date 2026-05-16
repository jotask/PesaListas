import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '***REMOVED***',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '***REMOVED***',
  );

  static const useOpenFoodFactsStaging = bool.fromEnvironment(
    'USE_OPEN_FOOD_FACTS_STAGING',
    defaultValue: true,
  );

  static const defaultCurrency = String.fromEnvironment(
    'DEFAULT_CURRENCY',
    defaultValue: 'EUR',
  );

  static const omdbApiKey = String.fromEnvironment(
    'OMDB_API_KEY',
    defaultValue: '9fefeb6c',
  );

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw StateError('Missing SUPABASE_URL');
    }

    if (supabaseAnonKey.isEmpty) {
      throw StateError('Missing SUPABASE_ANON_KEY');
    }
  }

  static bool get isDesktop {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  static bool get isMobile {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get hasOmdbApiKey {
    return omdbApiKey.trim().isNotEmpty;
  }

  static const omdbBaseUrl = 'https://www.omdbapi.com/';
}
