import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../widgets/auth_form.dart';
import '../l10n/l10n.dart';

/// Mot de passe oublié, en deux étapes : l'adresse e-mail, puis le code à
/// 6 chiffres reçu et le nouveau mot de passe. La vérification du code
/// connecte l'utilisateur : `BierodexApp` referme alors cette page.
class PasswordResetScreen extends StatefulWidget {
  final String initialEmail;

  const PasswordResetScreen({super.key, this.initialEmail = ''});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen>
    with AuthFormState {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _sentTo;

  AuthService get _auth => AuthService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _codeFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _sendCode() => run(() async {
    final email = _sentTo ?? AuthService.normalizeEmail(_emailController.text);
    if (email == null) {
      throw AuthFailure(context.l10n.authInvalidEmail);
    }
    await _auth.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _sentTo = email);
    _codeController.clear();
    startCooldownTicker();
    _codeFocus.requestFocus();
  });

  Future<void> _reset() => run(() async {
    final email = _sentTo;
    if (email == null) return;
    try {
      await _auth.resetPassword(
        email: email,
        code: _codeController.text,
        newPassword: _passwordController.text,
      );
      TextInput.finishAutofillContext();
    } on AuthFailure {
      // Le code n'est plus bon après un refus du serveur ; le mot de passe,
      // lui, peut simplement être corrigé.
      if (!_auth.isSignedIn) _codeController.clear();
      rethrow;
    }
  });

  void _changeEmail() {
    setState(() {
      _sentTo = null;
      error = null;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentTo = _sentTo;
    return AuthScaffold(
      showBack: true,
      subtitle: sentTo == null
          ? context.l10n.passwordResetSubtitle
          : context.l10n.passwordResetCodeSent(sentTo, AuthService.codeLength),
      error: error,
      child: sentTo == null ? _buildEmailStep() : _buildResetStep(),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailField(
          controller: _emailController,
          enabled: !loading,
          autofocus: true,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: context.l10n.getCode,
          loading: loading,
          onPressed: _sendCode,
        ),
      ],
    );
  }

  Widget _buildResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CodeField(
          controller: _codeController,
          focusNode: _codeFocus,
          enabled: !loading && !_auth.isCodeLocked,
          onCompleted: _passwordFocus.requestFocus,
        ),
        const SizedBox(height: 12),
        PasswordField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          enabled: !loading,
          isNew: true,
          label: context.l10n.newPassword,
          helperText: context.l10n.passwordHelper(
            AuthService.minPasswordLength,
          ),
          onSubmitted: (_) => _reset(),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: context.l10n.changePassword,
          loading: loading,
          onPressed: _auth.isCodeLocked ? null : _reset,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            ResendCodeButton(loading: loading, onPressed: _sendCode),
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
