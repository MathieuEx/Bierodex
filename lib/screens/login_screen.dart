import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Écran d'entrée de l'app tant que personne n'est connecté (voir
/// `BierodexApp` dans `lib/main.dart`). Deux étapes : l'adresse e-mail, puis
/// le code à 6 chiffres reçu par e-mail. Une fois connecté, la session est
/// conservée : cet écran ne revient qu'après une déconnexion.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();

  String? _sentTo;
  bool _loading = false;
  String? _error;
  Timer? _cooldownTicker;

  AuthService get _auth => AuthService.instance;

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  /// Rafraîchit chaque seconde le compte à rebours du bouton "Renvoyer".
  void _startCooldownTicker() {
    _cooldownTicker?.cancel();
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() {});
      if (_auth.resendWait == Duration.zero) timer.cancel();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
    final email = AuthService.normalizeEmail(_emailController.text);
    if (email == null) {
      throw const AuthFailure('Adresse e-mail invalide.');
    }
    await _auth.sendCode(email);
    if (!mounted) return;
    setState(() => _sentTo = email);
    _codeController.clear();
    _startCooldownTicker();
    _codeFocus.requestFocus();
  });

  // En cas de succès, `BierodexApp` remplace cet écran : rien d'autre à faire.
  Future<void> _verifyCode() => _run(() async {
    final email = _sentTo;
    if (email == null) return;
    try {
      await _auth.verifyCode(email: email, code: _codeController.text);
    } on AuthFailure {
      _codeController.clear();
      rethrow;
    }
  });

  void _changeEmail() {
    setState(() {
      _sentTo = null;
      _error = null;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.stout,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.sports_bar,
                      size: 48,
                      color: AppColors.copper,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BIERODEX',
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.foam,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sentTo == null
                          ? 'Connecte-toi pour retrouver ta collection sur '
                                'tous tes appareils. Pas de mot de passe : on '
                                't\'envoie un code par e-mail.'
                          : 'Si l\'adresse $_sentTo est valide, un code à '
                                '${AuthService.codeLength} chiffres vient d\'y '
                                'être envoyé.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.foamSoft,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_sentTo == null)
                      _buildEmailStep()
                    else
                      _buildCodeStep(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE08A6F),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          enabled: !_loading,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          enableSuggestions: false,
          maxLength: AuthService.maxEmailLength,
          // Refuse espaces et caractères de contrôle dès la saisie.
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\s\x00-\x1F\x7F]')),
          ],
          style: const TextStyle(color: AppColors.foam),
          decoration: _fieldDecoration('Adresse e-mail', Icons.mail_outline),
          onSubmitted: (_) => _sendCode(),
        ),
        const SizedBox(height: 8),
        _PrimaryButton(
          label: 'Recevoir un code',
          loading: _loading,
          onPressed: _sendCode,
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    final wait = _auth.resendWait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _codeController,
          focusNode: _codeFocus,
          enabled: !_loading && !_auth.isCodeLocked,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          autocorrect: false,
          enableSuggestions: false,
          maxLength: AuthService.codeLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.foam,
            fontSize: 26,
            letterSpacing: 10,
            fontWeight: FontWeight.w700,
          ),
          decoration: _fieldDecoration('Code reçu par e-mail', Icons.pin),
          onChanged: (value) {
            if (value.length == AuthService.codeLength) _verifyCode();
          },
          onSubmitted: (_) => _verifyCode(),
        ),
        const SizedBox(height: 8),
        _PrimaryButton(
          label: 'Se connecter',
          loading: _loading,
          onPressed: _auth.isCodeLocked ? null : _verifyCode,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: _loading || wait > Duration.zero ? null : _sendCode,
              child: Text(
                wait > Duration.zero
                    ? 'Renvoyer le code (${wait.inSeconds} s)'
                    : 'Renvoyer le code',
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _changeEmail,
              child: const Text('Changer d\'adresse'),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.outlineDark),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.foamSoft),
      prefixIcon: Icon(icon, color: AppColors.foamSoft),
      filled: true,
      fillColor: AppColors.stoutDim,
      counterText: '',
      border: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.copper, width: 1.6),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.copper,
        foregroundColor: AppColors.stout,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : Text(label),
    );
  }
}
