import 'package:google_sign_in/google_sign_in.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogleNative() async {
  final googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize(serverClientId: AppConfig.googleWebClientId);

  final googleUser = await googleSignIn.authenticate();

  final googleAuth = googleUser.authentication;

  final idToken = googleAuth.idToken;

  if (idToken == null) {
    throw Exception('Missing Google ID token');
  }

  await Supabase.instance.client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
  );
}
