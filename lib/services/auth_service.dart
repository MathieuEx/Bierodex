import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentification par code à usage unique envoyé par e-mail (OTP), via
/// Supabase Auth. Pas de mot de passe (rien à voler ni à réutiliser), pas
/// de lien magique (donc aucune configuration de redirection/deep link).
///
/// La connexion est obligatoire pour utiliser l'app (voir `BierodexApp` dans
/// `lib/main.dart`) mais n'est demandée qu'une fois : Supabase persiste la
/// session (voir `SecureSessionStorage`) et rafraîchit le token tout seul.
///
/// Les vraies protections contre le brute-force et le spam sont côté
/// serveur (limites de débit, expiration du code, captcha — à régler dans
/// le tableau de bord Supabase) ; les limites ci-dessous évitent seulement
/// de solliciter le serveur pour rien et guident l'utilisateur.
class AuthService extends ChangeNotifier {
  AuthService._() {
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
      // Un refresh token révoqué ou expiré remonte ici : la session est
      // alors vidée et l'utilisateur renvoyé vers l'écran de connexion.
      onError: (Object _) => notifyListeners(),
    );
  }

  static final AuthService instance = AuthService._();

  static const codeLength = 6;
  static const maxEmailLength = 254;
  static const maxVerifyAttempts = 5;
  static const resendCooldown = Duration(seconds: 60);

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  String? get userEmail => currentUser?.email;

  // Volontairement simple : la vraie validation est l'arrivée du code.
  static final _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
  );
  static final _codePattern = RegExp('^[0-9]{$codeLength}\$');

  /// Adresse nettoyée (espaces, casse) ou `null` si elle n'est pas valable.
  static String? normalizeEmail(String input) {
    final email = input.trim().toLowerCase();
    if (email.isEmpty || email.length > maxEmailLength) return null;
    return _emailPattern.hasMatch(email) ? email : null;
  }

  static bool isValidCode(String input) => _codePattern.hasMatch(input);

  DateTime? _lastCodeSentAt;
  int _failedAttempts = 0;

  /// Temps restant avant de pouvoir redemander un code.
  Duration get resendWait {
    final sentAt = _lastCodeSentAt;
    if (sentAt == null) return Duration.zero;
    final remaining = resendCooldown - DateTime.now().difference(sentAt);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Trop d'essais ratés sur le code en cours : il faut en redemander un.
  bool get isCodeLocked => _failedAttempts >= maxVerifyAttempts;

  /// Envoie un code à [email]. Le message affiché ensuite est le même que
  /// le compte existe ou non, pour ne pas révéler qui est inscrit.
  Future<void> sendCode(String email) async {
    final normalized = normalizeEmail(email);
    if (normalized == null) {
      throw const AuthFailure('Adresse e-mail invalide.');
    }
    if (resendWait > Duration.zero) {
      throw AuthFailure(
        'Patiente ${resendWait.inSeconds} s avant de redemander un code.',
      );
    }
    try {
      await _auth.signInWithOtp(email: normalized);
    } on AuthException catch (e) {
      throw AuthFailure.fromAuthException(e);
    } catch (_) {
      throw const AuthFailure(
        'Impossible de contacter le serveur. Vérifie ta connexion internet.',
      );
    }
    _lastCodeSentAt = DateTime.now();
    _failedAttempts = 0;
  }

  /// Vérifie le [code] reçu par e-mail et connecte l'utilisateur.
  Future<void> verifyCode({required String email, required String code}) async {
    final normalized = normalizeEmail(email);
    if (normalized == null) {
      throw const AuthFailure('Adresse e-mail invalide.');
    }
    if (isCodeLocked) {
      throw const AuthFailure('Trop de tentatives. Demande un nouveau code.');
    }
    if (!isValidCode(code)) {
      throw const AuthFailure('Le code contient $codeLength chiffres.');
    }
    try {
      await _auth.verifyOTP(
        email: normalized,
        token: code,
        type: OtpType.email,
      );
    } on AuthException catch (e) {
      _failedAttempts++;
      if (isCodeLocked) {
        throw const AuthFailure('Trop de tentatives. Demande un nouveau code.');
      }
      throw AuthFailure.fromAuthException(e, codeRejected: true);
    } catch (_) {
      throw const AuthFailure(
        'Impossible de contacter le serveur. Vérifie ta connexion internet.',
      );
    }
    _failedAttempts = 0;
    _lastCodeSentAt = null;
  }

  /// Déconnecte cet appareil. Avec [everywhere], révoque aussi les
  /// sessions ouvertes sur tous les autres appareils (utile en cas de perte
  /// ou de vol d'un téléphone).
  Future<void> signOut({bool everywhere = false}) async {
    try {
      await _auth.signOut(
        scope: everywhere ? SignOutScope.global : SignOutScope.local,
      );
    } on AuthException {
      // Hors-ligne ou session déjà invalide côté serveur : la session
      // locale est effacée quoi qu'il arrive, c'est ce qui compte ici.
      if (everywhere) rethrow;
    }
  }
}

/// Erreur d'authentification dont le [message] peut être montré tel quel :
/// jamais le détail technique renvoyé par le serveur.
class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  factory AuthFailure.fromAuthException(
    AuthException e, {
    bool codeRejected = false,
  }) {
    if (e.statusCode == '429' || (e.code?.startsWith('over_') ?? false)) {
      return const AuthFailure(
        'Trop de tentatives. Réessaie dans quelques minutes.',
      );
    }
    if (codeRejected) {
      return const AuthFailure('Code invalide ou expiré.');
    }
    return const AuthFailure(
      'Connexion impossible pour le moment. Réessaie plus tard.',
    );
  }

  @override
  String toString() => message;
}
