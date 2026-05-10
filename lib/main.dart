import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_theme_controller.dart';
import 'package:pesalistas/core/app_locale_controller.dart';
import 'package:pesalistas/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/l10n/app_localizations.dart';
import 'package:pesalistas/core/app_notification_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    FlutterError.presentError(details);
  };

  await AppLocaleController.loadSavedLocale();
  await AppThemeController.loadSavedThemeMode();
  await AppNotificationController.initialize();
  await AppNotificationController.initialize();

  AppConfig.validate();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

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
              title: 'Pesalistas',
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: themeMode,
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
