import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get userStream => _auth.authStateChanges();

  // Web client ID từ Firebase Console → Authentication → Google → Web SDK configuration
  static const _webClientId = '775823694514-2l11g2mts56aq16tspa00rcog6kh6kkh.apps.googleusercontent.com';

  Future<void> initialize() async {
    try {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('GoogleSignIn initialize error: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(idToken: account.authentication.idToken);
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
