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

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw StateError('Missing SUPABASE_URL');
    }

    if (supabaseAnonKey.isEmpty) {
      throw StateError('Missing SUPABASE_ANON_KEY');
    }
  }
}
