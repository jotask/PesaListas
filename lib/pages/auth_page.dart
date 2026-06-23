import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_platform.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/pages/home_page.dart';
import 'package:pesalistas/repositories/auth_repository.dart';
import 'package:pesalistas/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final StreamSubscription<AuthState> authSubscription;

  bool loading = false;
  bool isLogin = true;
  bool navigatingHome = false;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    authRepository = AuthRepository(client);
    profileRepository = ProfileRepository(client);

    authSubscription = authRepository.authStateChanges.listen((data) async {
      final session = data.session;

      if (session != null && mounted && !navigatingHome) {
        navigatingHome = true;

        try {
          await profileRepository
              .syncCurrentProfileFromAuth(debugLabel: 'AuthPageProfileSync')
              .timeout(const Duration(seconds: 4));
        } catch (error, stackTrace) {
          debugPrint('Auth profile sync failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/home'),
            builder: (_) => const HomePage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    authSubscription.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogleNativeInternal() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      await authRepository.signInWithGoogle();
    } catch (error, stackTrace) {
      debugPrint('GOOGLE LOGIN ERROR: $error', wrapWidth: 1024);
      debugPrint('STACK TRACE: $stackTrace', wrapWidth: 1024);

      if (!mounted) return;

      showErrorSnackBar(context, 'Google login failed.', error);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> signInWithGoogleDesktopOAuth() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      await authRepository.signInWithGoogleOAuth();
    } catch (error, stackTrace) {
      debugPrint('GOOGLE OAUTH ERROR: $error', wrapWidth: 1024);
      debugPrint('STACK TRACE: $stackTrace', wrapWidth: 1024);

      if (!mounted) return;

      showErrorSnackBar(context, 'Google sign-in failed.', error);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> submit() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorSnackBar(context, 'Email and password are required.');
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        await authRepository.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await authRepository.signUpWithPassword(
          email: email,
          password: password,
        );

        try {
          await profileRepository
              .syncCurrentProfileFromAuth(debugLabel: 'AuthPageProfileSync')
              .timeout(const Duration(seconds: 4));
        } catch (error, stackTrace) {
          debugPrint('Auth signup profile sync failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }

        if (!mounted) return;

        showSuccessSnackBar(
          context,
          'Check your email to confirm your account.',
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, error.message);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Unexpected error.', error);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> continueWithGoogle() async {
    if (AppPlatform.isDesktop) {
      await signInWithGoogleDesktopOAuth();
      return;
    }

    await signInWithGoogleNativeInternal();
  }

  @override
  Widget build(BuildContext context) {
    final title = isLogin ? 'Welcome back' : 'Create your account';
    final subtitle = isLogin
        ? 'Log in to manage your shared lists, plans and home routines.'
        : 'Create a shared space for lists, meals, chores and ideas.';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _AuthBrandHeader(),
                  const SizedBox(height: 24),
                  _AuthPanel(
                    title: title,
                    subtitle: subtitle,
                    emailController: emailController,
                    passwordController: passwordController,
                    loading: loading,
                    isLogin: isLogin,
                    onSubmit: submit,
                    onGoogle: continueWithGoogle,
                    onToggleMode: () {
                      setState(() => isLogin = !isLogin);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _AuthAppIcon(),
        SizedBox(height: 14),
        _AuthWordmark(),
        SizedBox(height: 5),
        Text(
          'Organizamos juntos, vivimos mejor.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF727A83),
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _AuthAppIcon extends StatelessWidget {
  const _AuthAppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF149D6E).withValues(alpha: 0.20),
            blurRadius: 22,
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: 38,
            ),
          );
        },
      ),
    );
  }
}

class _AuthWordmark extends StatelessWidget {
  const _AuthWordmark();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 34,
          height: 0.98,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
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

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.title,
    required this.subtitle,
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.isLogin,
    required this.onSubmit,
    required this.onGoogle,
    required this.onToggleMode,
  });

  final String title;
  final String subtitle;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final bool isLogin;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF26363B),
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF727A83),
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _GoogleAuthButton(loading: loading, onPressed: onGoogle),
          const SizedBox(height: 18),
          const _DividerLabel(label: 'or continue with email'),
          const SizedBox(height: 16),
          _AuthTextField(
            controller: emailController,
            label: 'Email',
            hintText: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: passwordController,
            label: 'Password',
            hintText: 'Your password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF19A873),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(
                  0xFF19A873,
                ).withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLogin ? 'Log in' : 'Create account',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: loading ? null : onToggleMode,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F7F67),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text(
              isLogin
                  ? 'Need an account? Sign up'
                  : 'Already have an account? Log in',
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleAuthButton extends StatelessWidget {
  const _GoogleAuthButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading) ...[
                const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Color(0xFF19A873),
                  ),
                ),
              ] else ...[
                Image.asset(
                  'assets/auth/google_g_mockup.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) {
                    return const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Color(0xFF26363B),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE6E1D8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A8F98),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE6E1D8))),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: obscureText
          ? TextInputAction.done
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFFFFCF4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE6E1D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE6E1D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF19A873), width: 1.4),
        ),
      ),
    );
  }
}
