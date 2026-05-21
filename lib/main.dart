import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesalistas/core/app_analytics.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_push_notification_service.dart';
import 'package:pesalistas/core/controllers/app_locale_controller.dart';
import 'package:pesalistas/core/controllers/app_notification_controller.dart';
import 'package:pesalistas/core/controllers/app_theme_controller.dart';
import 'package:pesalistas/firebase_options.dart';
import 'package:pesalistas/l10n/app_localizations.dart';
import 'package:pesalistas/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final envFile = kReleaseMode
      ? 'assets/env/.env.production'
      : 'assets/env/.env.development';

  await dotenv.load(fileName: envFile);

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();

    final isOverflow =
        message.contains('A RenderFlex overflowed') ||
        message.contains('A RenderViewport overflowed') ||
        message.contains('overflowed by');

    if (isOverflow) {
      debugPrint('================ UI OVERFLOW DETECTED ================');
      debugPrint(message);
      debugPrintStack(stackTrace: details.stack);
      debugPrint('=======================================================');
    }

    if (kReleaseMode) {
      if (isOverflow) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      } else {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    }

    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      return true;
    }

    return false;
  };

  await AppLocaleController.loadSavedLocale();
  await AppThemeController.loadSavedThemeMode();
  await AppNotificationController.initialize();

  AppConfig.validate();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  await AppPushNotificationService.initialize();

  await AppAnalytics.instance.setUserId(supabase.auth.currentUser?.id);

  await AppAnalytics.instance.logAppOpened();

  await AppPushNotificationService.syncCurrentDevice();

  supabase.auth.onAuthStateChange.listen((data) async {
    final userId = data.session?.user.id;

    await AppAnalytics.instance.setUserId(userId);

    if (userId != null) {
      await AppAnalytics.instance.logAuthSessionRestored();
      await AppPushNotificationService.syncCurrentDevice();
    }
  });

  runApp(const PesaListas());
}

class PesaListas extends StatelessWidget {
  const PesaListas({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocaleController.locale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppThemeController.themeMode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'PesaListas',
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: themeMode,
              navigatorObservers: [
                FirebaseAnalyticsObserver(
                  analytics: FirebaseAnalytics.instance,
                ),
              ],
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ),
              ),
              home: const SplashPage(),
            );
          },
        );
      },
    );
  }
}
