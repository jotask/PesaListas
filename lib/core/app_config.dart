import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesalistas/core/app_platform.dart';

class AppConfig {
  const AppConfig._();

  static const defaultCurrency = 'EUR';

  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static bool get useOpenFoodFactsStaging {
    return AppPlatform.isRelease == false;
  }

  static void validate() {
    if (supabaseUrl.trim().isEmpty) {
      throw StateError('Missing SUPABASE_URL in env file.');
    }

    if (supabaseAnonKey.trim().isEmpty) {
      throw StateError('Missing SUPABASE_ANON_KEY in env file.');
    }
  }
}
