import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/google_config.dart';
import '../l10n/l10n.dart';

class AuthService extends ChangeNotifier {
  AuthService._() {
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
      onError: (Object _) => notifyListeners(),
    );
  }

  static final AuthService instance = AuthService._();

  static const codeLength = 6;
  static const maxEmailLength = 254;
  static const minPasswordLength = 8;
  static const maxPasswordLength = 72;
  static const maxVerifyAttempts = 5;
  static const resendCooldown = Duration(seconds: 60);
  static const oauthRedirectUrl = 'io.supabase.bierodex://login-callback/';

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  String? get userEmail => currentUser?.email;

  static final _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
  );
  static final _codePattern = RegExp('^[0-9]{$codeLength}\$');

  static String? normalizeEmail(String input) {
    final email = input.trim().toLowerCase();
    if (email.isEmpty || email.length > maxEmailLength) return null;
    return _emailPattern.hasMatch(email) ? email : null;
  }

  static bool isValidCode(String input) => _codePattern.hasMatch(input);

  static String? passwordProblem(String password) {
    if (password.length < minPasswordLength) {
      return L10n.current.authPasswordTooShort(minPasswordLength);
    }
    if (utf8.encode(password).length > maxPasswordLength) {
      return L10n.current.authPasswordTooLong;
    }
    if (!password.contains(RegExp('[A-Za-z]')) ||
        !password.contains(RegExp('[0-9]'))) {
      return L10n.current.authPasswordNeedsLettersAndDigits;
    }
    return null;
  }

  DateTime? _lastCodeSentAt;
  int _failedAttempts = 0;

  Duration get resendWait {
    final sentAt = _lastCodeSentAt;
    if (sentAt == null) return Duration.zero;
    final remaining = resendCooldown - DateTime.now().difference(sentAt);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isCodeLocked => _failedAttempts >= maxVerifyAttempts;

  static String _requireEmail(String email) {
    final normalized = normalizeEmail(email);
    if (normalized == null) {
      throw AuthFailure(L10n.current.authInvalidEmail);
    }
    return normalized;
  }

  static Future<T> _guard<T>(
    Future<T> Function() request, {
    AuthFailure Function(AuthException e)? onAuthException,
  }) async {
    try {
      return await request();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw onAuthException?.call(e) ?? AuthFailure.fromAuthException(e);
    } catch (_) {
      throw AuthFailure(L10n.current.errorServerUnreachable);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final normalized = _requireEmail(email);
    if (password.isEmpty) {
      throw AuthFailure(L10n.current.authEnterPassword);
    }
    await _guard(
      () => _auth.signInWithPassword(email: normalized, password: password),
      onAuthException: (e) => switch (e.code) {
        'email_not_confirmed' => EmailNotConfirmed(),
        'invalid_credentials' => AuthFailure(
            L10n.current.authInvalidCredentials,
          ),
        _ => AuthFailure.fromAuthException(e),
      },
    );
  }

  /// Crée un compte. Retourne `true` si l'adresse doit encore être
  /// confirmée avec le code envoyé par e-mail (voir [confirmSignUp]),
  /// `false` si l'utilisateur est déjà connecté (confirmation désactivée
  /// côté Supabase). Si l'adresse est déjà inscrite, Supabase répond comme
  /// pour une nouvelle adresse (sans envoyer de code) : là encore, rien
  /// n'est révélé.
  Future<bool> signUp({required String email, required String password}) async {
    final normalized = _requireEmail(email);
    final problem = passwordProblem(password);
    if (problem != null) throw AuthFailure(problem);
    final response = await _guard(
      () => _auth.signUp(email: normalized, password: password),
      onAuthException: (e) => switch (e) {
        AuthWeakPasswordException() => AuthFailure(
            L10n.current.authWeakPasswordChooseAnother,
          ),
        _ when e.code == 'user_already_exists' => AuthFailure(
            L10n.current.authUserAlreadyExists,
          ),
        _ => AuthFailure.fromAuthException(e),
      },
    );
    _codeSent();
    return response.session == null;
  }

  /// Renvoie le code de confirmation d'inscription à [email].
  Future<void> resendSignUpCode(String email) async {
    final normalized = _requireEmail(email);
    _checkResendWait();
    await _guard(() => _auth.resend(type: OtpType.signup, email: normalized));
    _codeSent();
  }

  /// Confirme l'adresse avec le [code] reçu et connecte l'utilisateur.
  Future<void> confirmSignUp({required String email, required String code}) =>
      _verifyCode(email: email, code: code, type: OtpType.email);

  /// Envoie un code de réinitialisation à [email]. Le message affiché
  /// ensuite est le même que le compte existe ou non.
  Future<void> sendPasswordReset(String email) async {
    final normalized = _requireEmail(email);
    _checkResendWait();
    await _guard(() => _auth.resetPasswordForEmail(normalized));
    _codeSent();
  }

  /// Vérifie le [code] de réinitialisation puis enregistre [newPassword].
  /// La vérification ouvre une session : l'utilisateur est connecté même
  /// si l'enregistrement du nouveau mot de passe échoue ensuite.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final problem = passwordProblem(newPassword);
    if (problem != null) throw AuthFailure(problem);
    await _verifyCode(email: email, code: code, type: OtpType.recovery);
    await _guard(
      () => _auth.updateUser(UserAttributes(password: newPassword)),
      onAuthException: (e) => switch (e) {
        AuthWeakPasswordException() => AuthFailure(
            L10n.current.authWeakPassword,
          ),
        _ when e.code == 'same_password' => AuthFailure(
            L10n.current.authSamePassword,
          ),
        _ => AuthFailure.fromAuthException(e),
      },
    );
  }

  void _checkResendWait() {
    if (resendWait > Duration.zero) {
      throw AuthFailure(L10n.current.authResendWait(resendWait.inSeconds));
    }
  }

  void _codeSent() {
    _lastCodeSentAt = DateTime.now();
    _failedAttempts = 0;
  }

  Future<void> _verifyCode({
    required String email,
    required String code,
    required OtpType type,
  }) async {
    final normalized = _requireEmail(email);
    if (isCodeLocked) {
      throw AuthFailure(L10n.current.authTooManyCodeAttempts);
    }
    if (!isValidCode(code)) {
      throw AuthFailure(L10n.current.authCodeLength(codeLength));
    }
    await _guard(
      () => _auth.verifyOTP(email: normalized, token: code, type: type),
      onAuthException: (e) {
        _failedAttempts++;
        if (isCodeLocked) {
          return AuthFailure(L10n.current.authTooManyCodeAttempts);
        }
        return AuthFailure.fromAuthException(e, codeRejected: true);
      },
    );
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
      throw AuthFailure(L10n.current.authGoogleUnavailable);
    } on AuthException catch (e) {
      throw AuthFailure.fromAuthException(e);
    } catch (_) {
      throw AuthFailure(L10n.current.authGoogleCannotOpen);
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
      throw AuthFailure(L10n.current.authGoogleUnavailable);
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
      throw AuthFailure(L10n.current.authDeleteFailed);
    } catch (_) {
      throw AuthFailure(L10n.current.errorServerUnreachable);
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
      return AuthFailure(L10n.current.authRateLimited);
    }
    if (codeRejected) {
      return AuthFailure(L10n.current.authInvalidCode);
    }
    return AuthFailure(L10n.current.authSignInUnavailable);
  }

  @override
  String toString() => message;
}

/// Le compte existe mais l'adresse n'a jamais été confirmée : l'écran de
/// connexion propose alors de saisir le code d'inscription.
class EmailNotConfirmed extends AuthFailure {
  EmailNotConfirmed() : super(L10n.current.authEmailNotConfirmed);
}
