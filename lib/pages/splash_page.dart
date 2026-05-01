import 'package:flutter/material.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    setupApp();
  }

  Future<void> setupApp() async {
    // Optional: fake small delay so splash is visible
    await Future.delayed(const Duration(milliseconds: 800));

    // Supabase already restored session after Supabase.initialize()
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
