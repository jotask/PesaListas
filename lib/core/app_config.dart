import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static bool get useOpenFoodFactsStaging {
    return _boolFromEnv('USE_OPEN_FOOD_FACTS_STAGING', defaultValue: false);
  }

  static String get defaultCurrency {
    return dotenv.env['DEFAULT_CURRENCY'] ?? 'EUR';
  }

  static String get omdbApiKey {
    return dotenv.env['OMDB_API_KEY'] ?? '';
  }

  static bool get hasOmdbApiKey {
    return omdbApiKey.trim().isNotEmpty;
  }

  static void validate() {
    if (supabaseUrl.trim().isEmpty) {
      throw StateError('Missing SUPABASE_URL in env file.');
    }

    if (supabaseAnonKey.trim().isEmpty) {
      throw StateError('Missing SUPABASE_ANON_KEY in env file.');
    }
  }

  static bool _boolFromEnv(String key, {required bool defaultValue}) {
    final value = dotenv.env[key]?.trim().toLowerCase();

    if (value == null || value.isEmpty) {
      return defaultValue;
    }

    return value == 'true' || value == '1' || value == 'yes';
  }
}
