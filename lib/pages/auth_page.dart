import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/animated_logo.dart';
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

        await profileRepository.syncCurrentProfileFromAuth(
          debugLabel: 'AuthPageProfileSync',
        );

        if (!mounted) return;

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
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

      showErrorSnackBar(context, context.l10n.googleLoginFailed, error);
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
      showErrorSnackBar(context, context.l10n.emailAndPasswordAreRequired);
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

        await profileRepository.syncCurrentProfileFromAuth(
          debugLabel: 'AuthPageProfileSync',
        );

        if (!mounted) return;

        showSuccessSnackBar(context, context.l10n.checkYourEmailToConfirmYourAccount);
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, error.message);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.unexpectedError, error);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isLogin ? context.l10n.welcomeBack : context.l10n.createAccount;
    final subtitle = isLogin
        ? context.l10n.logInToManageYourSharedListsPlansAndChores
        : context.l10n.createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101827), Color(0xFF1E3A5F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const AnimatedLogo(),
                      ),
                      SizedBox(height: 20),
                      Text(
                        context.l10n.pesaListas,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E3A5F),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 28),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.password,
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isLogin ? context.l10n.logIn : context.l10n.createAccount),
                        ),
                      ),
                      SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: loading
                              ? null
                              : signInWithGoogleNativeInternal,
                          icon: Icon(Icons.login),
                          label: Text(context.l10n.continueWithGoogle),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1E3A5F),
                            side: const BorderSide(color: Color(0xFF1E3A5F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () {
                                setState(() => isLogin = !isLogin);
                              },
                        child: Text(
                          isLogin
                              ? context.l10n.needAnAccountSignUp
                              : context.l10n.alreadyHaveAnAccountLogIn,
                          style: const TextStyle(
                            color: Color(0xFF1E3A5F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
