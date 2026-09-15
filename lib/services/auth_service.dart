import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/google_config.dart';

/// Authentification via Supabase Auth, sans mot de passe (rien à voler ni à
/// réutiliser) : code à usage unique envoyé par e-mail (OTP), ou compte
/// Google (voir [signInWithGoogle] et [oauthRedirectUrl]).
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

  /// Schéma d'URL vers lequel Supabase redirige une fois la connexion
  /// Google terminée côté navigateur, pour revenir dans l'app mobile.
  /// Doit être déclaré côté OS (voir AndroidManifest.xml / Info.plist) et
  /// dans la liste des "Redirect URLs" du dashboard Supabase.
  static const oauthRedirectUrl = 'io.supabase.bierodex://login-callback/';

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

  /// Sur iOS/Android, sélecteur de compte natif (sans navigateur) dès que
  /// les ID clients Google sont fournis (voir [GoogleConfig]) ; sinon, et
  /// sur le web/macOS, connexion OAuth dans le navigateur.
  static bool get _usesNativeGoogle {
    if (kIsWeb || GoogleConfig.webClientId.isEmpty) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => GoogleConfig.iosClientId.isNotEmpty,
      _ => false,
    };
  }

  /// Nonce en clair transmis à Supabase ; Google n'en reçoit que le
  /// SHA-256. Supabase vérifie la correspondance, ce qui empêche de
  /// rejouer un jeton Google intercepté ailleurs. `GoogleSignIn` ne pouvant
  /// être initialisé qu'une fois, le nonce vaut pour la durée de vie de
  /// l'app (les jetons Google expirent de toute façon au bout d'une heure).
  String? _googleNonce;

  /// Connexion avec un compte Google. Ne fait rien si l'utilisateur ferme
  /// le sélecteur natif. En OAuth (navigateur), Supabase redirige ensuite
  /// vers [oauthRedirectUrl] (ou l'URL du site sur le web) : le retour
  /// effectif arrive de façon asynchrone via `onAuthStateChange`.
  Future<void> signInWithGoogle() async {
    try {
      if (_usesNativeGoogle) {
        await _signInWithGoogleNative();
      } else {
        await _auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : oauthRedirectUrl,
        );
      }
    } on AuthFailure {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return;
      }
      throw const AuthFailure('Connexion Google impossible pour le moment.');
    } on AuthException catch (e) {
      throw AuthFailure.fromAuthException(e);
    } catch (_) {
      throw const AuthFailure(
        'Impossible d\'ouvrir la connexion Google. Vérifie ta connexion '
        'internet.',
      );
    }
  }

  Future<void> _signInWithGoogleNative() async {
    var nonce = _googleNonce;
    if (nonce == null) {
      nonce = _randomNonce();
      await GoogleSignIn.instance.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? GoogleConfig.iosClientId
            : null,
        serverClientId: GoogleConfig.webClientId,
        nonce: sha256.convert(utf8.encode(nonce)).toString(),
      );
      _googleNonce = nonce;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthFailure('Connexion Google impossible pour le moment.');
    }
    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      nonce: nonce,
    );
  }

  static String _randomNonce() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
  }

  /// Supprime définitivement le compte et toutes ses données côté serveur
  /// (Edge Function `delete-account`, seule à détenir la clé service_role),
  /// puis ferme la session locale. Retourne l'identifiant supprimé pour que
  /// l'appelant efface aussi les caches locaux de ce compte.
  Future<String?> deleteAccount() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    try {
      await Supabase.instance.client.functions.invoke('delete-account');
    } on FunctionException {
      throw const AuthFailure(
        'La suppression a échoué. Réessaie plus tard ; tes données sont intactes.',
      );
    } catch (_) {
      throw const AuthFailure(
        'Impossible de contacter le serveur. Vérifie ta connexion internet.',
      );
    }
    if (_usesNativeGoogle && _googleNonce != null) {
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (_) {
        // Pas connecté via Google : rien à révoquer.
      }
    }
    await signOut();
    return userId;
  }

  /// Déconnecte cet appareil. Avec [everywhere], révoque aussi les
  /// sessions ouvertes sur tous les autres appareils (utile en cas de perte
  /// ou de vol d'un téléphone).
  Future<void> signOut({bool everywhere = false}) async {
    if (_usesNativeGoogle && _googleNonce != null) {
      // Sinon le sélecteur Google reconnecterait le même compte sans
      // rien demander à la prochaine tentative.
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
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
