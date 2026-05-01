import 'package:flutter/material.dart';
import 'package:pesalistas/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return MaterialApp(
      title: 'PesaListas',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
