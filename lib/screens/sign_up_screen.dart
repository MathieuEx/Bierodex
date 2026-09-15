import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_form.dart';
import '../l10n/l10n.dart';

/// Création de compte en deux étapes : e-mail et mot de passe, puis code à
/// 6 chiffres reçu par e-mail pour confirmer l'adresse. Poussé par-dessus
/// [LoginScreen] ; `BierodexApp` referme cette page dès que l'utilisateur
/// est connecté.
class SignUpScreen extends StatefulWidget {
  final String initialEmail;

  /// Compte déjà créé mais jamais confirmé (arrivée depuis la connexion) :
  /// on passe directement à la saisie du code, après en avoir renvoyé un.
  final String? unconfirmedEmail;

  const SignUpScreen({
    super.key,
    this.initialEmail = '',
    this.unconfirmedEmail,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with AuthFormState {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _codeFocus = FocusNode();

  /// Adresse en attente de confirmation ; `null` pendant la première étape.
  String? _pendingEmail;

  AuthService get _auth => AuthService.instance;

  @override
  void initState() {
    super.initState();
    final unconfirmed = widget.unconfirmedEmail;
    if (unconfirmed != null) {
      _pendingEmail = unconfirmed;
      WidgetsBinding.instance.addPostFrameCallback((_) => _resendCode());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() => run(() async {
        if (_passwordController.text != _confirmController.text) {
          throw AuthFailure(context.l10n.passwordsDoNotMatch);
        }
        final needsConfirmation = await _auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
        TextInput.finishAutofillContext();
        if (!needsConfirmation || !mounted) return;
        setState(() {
          _pendingEmail = AuthService.normalizeEmail(_emailController.text);
          _passwordController.clear();
          _confirmController.clear();
        });
        startCooldownTicker();
        _codeFocus.requestFocus();
      });

  Future<void> _resendCode() => run(() async {
        final email = _pendingEmail;
        if (email == null) return;
        await _auth.resendSignUpCode(email);
        _codeController.clear();
        startCooldownTicker();
        _codeFocus.requestFocus();
      });

  // En cas de succès, l'utilisateur est connecté et `BierodexApp` referme
  // cette page.
  Future<void> _confirm() => run(() async {
        final email = _pendingEmail;
        if (email == null) return;
        try {
          await _auth.confirmSignUp(email: email, code: _codeController.text);
        } on AuthFailure {
          _codeController.clear();
          rethrow;
        }
      });

  void _changeEmail() {
    setState(() {
      _pendingEmail = null;
      error = null;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pendingEmail;
    return AuthScaffold(
      showBack: true,
      subtitle: pending == null
          ? context.l10n.signUpSubtitle
          : context.l10n.signUpCodeSent(pending, AuthService.codeLength),
      error: error,
      child: pending == null ? _buildAccountStep() : _buildCodeStep(),
    );
  }

  Widget _buildAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailField(
          controller: _emailController,
          enabled: !loading,
          autofocus: true,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 12),
        PasswordField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          enabled: !loading,
          isNew: true,
          helperText: context.l10n.passwordHelper(
            AuthService.minPasswordLength,
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _confirmFocus.requestFocus(),
        ),
        const SizedBox(height: 12),
        PasswordField(
          controller: _confirmController,
          focusNode: _confirmFocus,
          enabled: !loading,
          isNew: true,
          label: context.l10n.confirmPassword,
          onSubmitted: (_) => _signUp(),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: context.l10n.signUpSubmit,
          loading: loading,
          onPressed: _signUp,
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              context.l10n.alreadyHaveAccount,
              style: const TextStyle(color: AppColors.foamSoft),
            ),
            TextButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(),
              child: Text(context.l10n.signIn),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CodeField(
          controller: _codeController,
          focusNode: _codeFocus,
          enabled: !loading && !_auth.isCodeLocked,
          onCompleted: _confirm,
        ),
        const SizedBox(height: 8),
        AuthPrimaryButton(
          label: context.l10n.confirmEmail,
          loading: loading,
          onPressed: _auth.isCodeLocked ? null : _confirm,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            ResendCodeButton(loading: loading, onPressed: _resendCode),
            TextButton(
              onPressed: loading ? null : _changeEmail,
              child: Text(context.l10n.changeEmail),
            ),
          ],
        ),
      ],
    );
  }
}
