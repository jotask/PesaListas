import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogleNative() async {
  const webClientId =
      '826964057612-6pfgome4ijjs83hnfkvm55661uut02f2.apps.googleusercontent.com';

  final googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize(serverClientId: webClientId);

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
