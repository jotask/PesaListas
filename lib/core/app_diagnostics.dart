import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_language.dart';
import 'package:pesalistas/core/app_platform.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/repositories/account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DiagnosticStatus { success, warning, error, info }

class DiagnosticItem {
  const DiagnosticItem({
    required this.label,
    required this.status,
    required this.message,
    this.details,
  });

  final String label;
  final DiagnosticStatus status;
  final String message;
  final String? details;
}

class DiagnosticsReport {
  const DiagnosticsReport({required this.generatedAt, required this.items});

  final DateTime generatedAt;
  final List<DiagnosticItem> items;

  bool get hasErrors {
    return items.any((item) => item.status == DiagnosticStatus.error);
  }

  bool get hasWarnings {
    return items.any((item) => item.status == DiagnosticStatus.warning);
  }
}

class AppDiagnostics {
  const AppDiagnostics._();

  static Future<DiagnosticsReport> runAll() async {
    final items = <DiagnosticItem>[];

    items.add(_checkEnvLoaded());
    items.add(_checkSupabaseConfig());
    items.add(_checkOpenFoodFactsConfig());
    items.add(_checkFirebaseCore());

    items.add(await _checkFirebaseAnalytics());
    items.add(await _checkFirebaseCrashlytics());
    items.add(_checkSupabaseAuthSession());
    items.add(await _checkSupabaseDatabase());
    items.add(await _checkTmdbEdgeFunction());
    items.add(await _checkOpenFoodFactsEdgeFunction());
    items.add(await _checkAccountDeletionDryRun());

    return DiagnosticsReport(generatedAt: DateTime.now(), items: items);
  }

  static DiagnosticItem _checkEnvLoaded() {
    final hasSupabaseUrl =
        dotenv.env['SUPABASE_URL']?.trim().isNotEmpty == true;
    final hasSupabaseAnonKey =
        dotenv.env['SUPABASE_ANON_KEY']?.trim().isNotEmpty == true;

    if (hasSupabaseUrl && hasSupabaseAnonKey) {
      return const DiagnosticItem(
        label: 'Env file',
        status: DiagnosticStatus.success,
        message: 'Loaded',
        details: 'SUPABASE_URL and SUPABASE_ANON_KEY are present.',
      );
    }

    final missing = <String>[];

    if (!hasSupabaseUrl) {
      missing.add('SUPABASE_URL');
    }

    if (!hasSupabaseAnonKey) {
      missing.add('SUPABASE_ANON_KEY');
    }

    return DiagnosticItem(
      label: 'Env file',
      status: DiagnosticStatus.error,
      message: 'Missing required values',
      details: 'Missing: ${missing.join(', ')}',
    );
  }

  static DiagnosticItem _checkSupabaseConfig() {
    try {
      AppConfig.validate();

      final host = Uri.parse(AppConfig.supabaseUrl).host;

      if (host.isEmpty) {
        return const DiagnosticItem(
          label: 'Supabase config',
          status: DiagnosticStatus.error,
          message: 'Invalid URL',
          details: 'SUPABASE_URL does not contain a valid host.',
        );
      }

      return DiagnosticItem(
        label: 'Supabase config',
        status: DiagnosticStatus.success,
        message: 'Configured',
        details: 'Project host: $host',
      );
    } catch (error) {
      return DiagnosticItem(
        label: 'Supabase config',
        status: DiagnosticStatus.error,
        message: 'Invalid',
        details: error.toString(),
      );
    }
  }

  static DiagnosticItem _checkOpenFoodFactsConfig() {
    return DiagnosticItem(
      label: 'OpenFoodFacts mode',
      status: AppConfig.useOpenFoodFactsStaging
          ? DiagnosticStatus.warning
          : DiagnosticStatus.success,
      message: AppConfig.useOpenFoodFactsStaging ? 'Staging' : 'Production',
      details: AppConfig.useOpenFoodFactsStaging
          ? 'Development is using world.openfoodfacts.net through the Edge Function.'
          : 'Production mode uses world.openfoodfacts.org through the Edge Function.',
    );
  }

  static DiagnosticItem _checkFirebaseCore() {
    if (Firebase.apps.isEmpty) {
      return const DiagnosticItem(
        label: 'Firebase Core',
        status: DiagnosticStatus.error,
        message: 'Not initialized',
        details: 'Firebase.initializeApp did not complete or was not called.',
      );
    }

    return DiagnosticItem(
      label: 'Firebase Core',
      status: DiagnosticStatus.success,
      message: 'Initialized',
      details: 'Apps: ${Firebase.apps.map((app) => app.name).join(', ')}',
    );
  }

  static Future<DiagnosticItem> _checkFirebaseAnalytics() async {
    try {
      final appInstanceId = await FirebaseAnalytics.instance.appInstanceId;

      return DiagnosticItem(
        label: 'Firebase Analytics',
        status: DiagnosticStatus.success,
        message: 'Available',
        details: appInstanceId == null || appInstanceId.isEmpty
            ? 'Analytics instance is available. App instance id is not available yet.'
            : 'App instance id: ${_mask(appInstanceId)}',
      );
    } catch (error) {
      return DiagnosticItem(
        label: 'Firebase Analytics',
        status: DiagnosticStatus.error,
        message: 'Failed',
        details: error.toString(),
      );
    }
  }

  static Future<DiagnosticItem> _checkFirebaseCrashlytics() async {
    try {
      final enabled =
          FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;

      return DiagnosticItem(
        label: 'Firebase Crashlytics',
        status: AppPlatform.isRelease
            ? DiagnosticStatus.success
            : DiagnosticStatus.warning,
        message: enabled ? 'Collection enabled' : 'Collection disabled',
        details: AppPlatform.isRelease
            ? 'Release mode should collect crash reports.'
            : 'Debug/profile mode should usually keep Crashlytics collection disabled.',
      );
    } catch (error) {
      return DiagnosticItem(
        label: 'Firebase Crashlytics',
        status: DiagnosticStatus.error,
        message: 'Failed',
        details: error.toString(),
      );
    }
  }

  static DiagnosticItem _checkSupabaseAuthSession() {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    if (session == null || user == null) {
      return const DiagnosticItem(
        label: 'Supabase Auth',
        status: DiagnosticStatus.warning,
        message: 'No active session',
        details:
            'Some authenticated Edge Functions may fail until the user logs in.',
      );
    }

    return DiagnosticItem(
      label: 'Supabase Auth',
      status: DiagnosticStatus.success,
      message: 'Session active',
      details: 'User id: ${_mask(user.id)}',
    );
  }

  static Future<DiagnosticItem> _checkSupabaseDatabase() async {
    try {
      await Supabase.instance.client
          .from(AppTables.groups)
          .select('id')
          .limit(1);

      return const DiagnosticItem(
        label: 'Supabase database',
        status: DiagnosticStatus.success,
        message: 'Query succeeded',
        details: 'Read test against groups completed.',
      );
    } catch (error) {
      return DiagnosticItem(
        label: 'Supabase database',
        status: DiagnosticStatus.error,
        message: 'Query failed',
        details: error.toString(),
      );
    }
  }

  static Future<DiagnosticItem> _checkTmdbEdgeFunction() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'tmdb-search',
        body: {'query': 'Matrix', 'languageCode': AppLanguage.tmdbLanguageCode},
      );

      final data = response.data;

      if (response.status < 200 || response.status >= 300) {
        return DiagnosticItem(
          label: 'TMDb Edge Function',
          status: DiagnosticStatus.error,
          message: 'TMDb search failed with status ${response.status}.',
          details: data.toString(),
        );
      }

      if (data is! Map) {
        return DiagnosticItem(
          label: 'TMDb Edge Function',
          status: DiagnosticStatus.error,
          message: 'TMDb search returned invalid data.',
          details: data.toString(),
        );
      }

      final movies = data['movies'];
      final languageCode = data['languageCode']?.toString();

      if (movies is List && movies.isNotEmpty) {
        return DiagnosticItem(
          label: 'TMDb Edge Function',
          status: DiagnosticStatus.success,
          message: 'TMDb search is working.',
          details:
              'Returned ${movies.length} movie(s). Language: ${languageCode ?? AppLanguage.tmdbLanguageCode}.',
        );
      }

      return DiagnosticItem(
        label: 'TMDb Edge Function',
        status: DiagnosticStatus.warning,
        message: 'TMDb search responded, but returned no movies.',
        details: data.toString(),
      );
    } catch (error, stackTrace) {
      return DiagnosticItem(
        label: 'TMDb Edge Function',
        status: DiagnosticStatus.error,
        message: 'TMDb diagnostic failed.',
        details: '$error\n\n$stackTrace',
      );
    }
  }

  static Future<DiagnosticItem> _checkOpenFoodFactsEdgeFunction() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'open-food-facts-product',
        body: {
          'barcode': '3017620422003',
          'useStaging': AppConfig.useOpenFoodFactsStaging,
        },
      );

      if (response.status < 200 || response.status >= 300) {
        return DiagnosticItem(
          label: 'OpenFoodFacts Edge Function',
          status: DiagnosticStatus.error,
          message: 'HTTP ${response.status}',
          details: _safeDataPreview(response.data),
        );
      }

      final data = _asMap(response.data);

      if (data.containsKey('product') || data.containsKey('status')) {
        return DiagnosticItem(
          label: 'OpenFoodFacts Edge Function',
          status: DiagnosticStatus.success,
          message: 'Working',
          details: AppConfig.useOpenFoodFactsStaging
              ? 'Function responded in staging mode.'
              : 'Function responded in production mode.',
        );
      }

      return DiagnosticItem(
        label: 'OpenFoodFacts Edge Function',
        status: DiagnosticStatus.warning,
        message: 'Unexpected response',
        details: _safeDataPreview(data),
      );
    } catch (error) {
      return DiagnosticItem(
        label: 'OpenFoodFacts Edge Function',
        status: DiagnosticStatus.error,
        message: 'Failed',
        details: error.toString(),
      );
    }
  }

  static Future<DiagnosticItem> _checkAccountDeletionDryRun() async {
    try {
      final repository = AccountRepository(Supabase.instance.client);
      final result = await repository.dryRunDeleteCurrentAccount();

      return DiagnosticItem(
        label: 'Account deletion Edge Function',
        status: DiagnosticStatus.success,
        message: 'Dry run passed',
        details:
            'Memberships: ${result['membershipCount'] ?? 0}, owned groups: ${result['ownedGroupCount'] ?? 0}, sole-owner groups: ${result['soleOwnerGroupCount'] ?? 0}',
      );
    } on AccountDeletionBlockedException catch (error) {
      debugPrint('================ ACCOUNT DELETION BLOCKED ================');
      debugPrint('Message: ${error.message}');
      debugPrint('Sole-owner groups: ${error.soleOwnerGroupCount}');
      debugPrint('Raw data: ${error.rawData}');
      debugPrint('==========================================================');

      final groupNames = error.soleOwnerGroups
          .map((group) => group.name)
          .join(', ');

      return DiagnosticItem(
        label: 'Account deletion Edge Function',
        status: DiagnosticStatus.warning,
        message: 'Blocked by sole-owner groups',
        details: groupNames.isEmpty
            ? '${error.soleOwnerGroupCount} group(s) need another owner before account deletion.'
            : 'Blocking groups: $groupNames',
      );
    } catch (error) {
      return DiagnosticItem(
        label: 'Account deletion Edge Function',
        status: DiagnosticStatus.error,
        message: 'Dry run failed',
        details: error.toString(),
      );
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {'value': data?.toString()};
  }

  static String _safeDataPreview(dynamic data) {
    final text = data.toString();

    if (text.length <= 500) {
      return text;
    }

    return '${text.substring(0, 500)}…';
  }

  static String _mask(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return '—';
    }

    if (text.length <= 10) {
      return 'configured';
    }

    return '${text.substring(0, 4)}…${text.substring(text.length - 4)}';
  }
}
