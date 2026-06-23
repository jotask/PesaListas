import 'package:flutter/material.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/home_page.dart';
import 'package:pesalistas/repositories/auth_repository.dart';
import 'package:pesalistas/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    authRepository = AuthRepository(client);
    profileRepository = ProfileRepository(client);

    setupApp();
  }

  Future<void> setupApp() async {
    await Future.delayed(const Duration(milliseconds: 1100));

    if (!mounted) return;

    final hasSession = authRepository.currentSession != null;

    if (!hasSession) {
      goToAuth();
      return;
    }

    try {
      await profileRepository
          .syncCurrentProfileFromAuth(debugLabel: 'SplashProfileSync')
          .timeout(const Duration(seconds: 3));
    } catch (error, stackTrace) {
      debugPrint('Splash profile sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) return;

    goToHome();
  }

  void goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/home'),
        builder: (_) => const HomePage(),
      ),
    );
  }

  void goToAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/auth'),
        builder: (_) => const AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFCF4),
      body: SafeArea(child: _SplashContent()),
    );
  }
}

class _SplashAppIcon extends StatelessWidget {
  const _SplashAppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF149D6E).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/icons/app_icon.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF25C889), Color(0xFF149D6E)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: 46,
            ),
          );
        },
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _SplashAppIcon(),
                SizedBox(height: 22),
                _SplashWordmark(),
                SizedBox(height: 4),
                Text(
                  'Organizamos juntos, vivimos mejor.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: Color(0xFF727A83),
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: 30),
                _HouseIllustration(),
                SizedBox(height: 28),
                _SplashLoading(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashWordmark extends StatelessWidget {
  const _SplashWordmark();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 43,
          height: 0.95,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.9,
        ),
        children: [
          TextSpan(
            text: 'Pesa',
            style: TextStyle(color: Color(0xFF26363B)),
          ),
          TextSpan(
            text: 'Listas',
            style: TextStyle(color: Color(0xFF19A873)),
          ),
        ],
      ),
    );
  }
}

class _HouseIllustration extends StatelessWidget {
  const _HouseIllustration();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/illustrations/splash_house.png',
      width: 320,
      height: 230,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) {
        return const SizedBox(
          width: 300,
          height: 210,
          child: Center(
            child: Icon(Icons.home_rounded, color: Color(0xFF19A873), size: 84),
          ),
        );
      },
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3.2,
            color: Color(0xFF19A873),
            backgroundColor: Color(0xFFEAF5EF),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Cargando...',
          style: TextStyle(
            color: Color(0xFF727A83),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
