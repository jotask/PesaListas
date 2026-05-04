import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_locale_controller.dart';
import 'package:pesalistas/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '***REMOVED***',
    anonKey: '***REMOVED***',
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
        return MaterialApp(
          title: 'Pesalistas',
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: true),
          home: const SplashPage(),
        );
      },
    );
  }
}
