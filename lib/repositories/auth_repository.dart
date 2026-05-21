import 'package:flutter/foundation.dart';
import 'package:pesalistas/auth/google_auth.dart';
import 'package:pesalistas/core/app_analytics.dart';
import 'package:pesalistas/core/app_push_notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  Session? get currentSession {
    return _client.auth.currentSession;
  }

  User? get currentUser {
    return _client.auth.currentUser;
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);

    await AppAnalytics.instance.logLogin(method: 'password');
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);

    await AppAnalytics.instance.logSignUp(method: 'password');
  }

  Future<void> signInWithGoogle() async {
    await signInWithGoogleNative();

    await AppAnalytics.instance.logLogin(method: 'google_native');
  }

  Future<void> signInWithGoogleOAuth() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'pesalistas://login-callback/',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    await AppAnalytics.instance.logEvent(
      'google_oauth_started',
      parameters: const {'provider': 'google'},
    );
  }

  Future<void> signOut() async {
    await AppAnalytics.instance.logLogout();

    await AppPushNotificationService.unregisterCurrentDevice();

    await _client.auth.signOut();

    await AppAnalytics.instance.setUserId(null);
  }
}
