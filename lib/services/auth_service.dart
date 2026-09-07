import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentification par code à usage unique envoyé par e-mail (OTP), via
/// Supabase Auth. Pas de mot de passe, pas de lien magique (donc aucune
/// configuration de redirection/deep link nécessaire).
class AuthService extends ChangeNotifier {
  AuthService._() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  static final AuthService instance = AuthService._();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  String? get userEmail => currentUser?.email;

  /// Envoie un code à 6 chiffres à [email].
  Future<void> sendCode(String email) {
    return _auth.signInWithOtp(email: email);
  }

  /// Vérifie le [code] reçu par e-mail et connecte l'utilisateur.
  Future<void> verifyCode({required String email, required String code}) {
    return _auth.verifyOTP(email: email, token: code, type: OtpType.email);
  }

  Future<void> signOut() => _auth.signOut();
}
