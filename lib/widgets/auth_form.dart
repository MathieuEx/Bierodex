import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/privacy_policy_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'health_notice.dart';
import '../l10n/l10n.dart';

/// Éléments communs aux écrans de connexion, d'inscription et de
/// réinitialisation du mot de passe.

/// Mise en page sombre des écrans d'authentification : logo, [subtitle],
/// contenu, [error] éventuelle puis liens légaux.
class AuthScaffold extends StatelessWidget {
  final String subtitle;
  final Widget child;
  final String? error;

  /// Affiche une flèche de retour (écrans poussés par-dessus la connexion).
  final bool showBack;

  const AuthScaffold({
    super.key,
    required this.subtitle,
    required this.child,
    this.error,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.stout,
      appBar: showBack
          ? AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.foam,
              elevation: 0,
            )
          : null,
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
                      subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.foamSoft,
                      ),
                    ),
                    const SizedBox(height: 32),
                    child,
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE08A6F),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.foamSoft,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                      child: Text(context.l10n.privacyPolicyTitle),
                    ),
                    const SizedBox(height: 4),
                    const HealthNotice(onDark: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gère l'état "chargement / erreur" d'un formulaire d'authentification.
mixin AuthFormState<T extends StatefulWidget> on State<T> {
  bool loading = false;
  String? error;
  Timer? _cooldownTicker;

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    super.dispose();
  }

  /// Exécute [action] en affichant ses [AuthFailure] ; ignore les appels
  /// pendant qu'une action est déjà en cours.
  Future<void> run(Future<void> Function() action) async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void clearError() => setState(() => error = null);

  /// Rafraîchit chaque seconde le compte à rebours du bouton "Renvoyer".
  void startCooldownTicker() {
    _cooldownTicker?.cancel();
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() {});
      if (AuthService.instance.resendWait == Duration.zero) timer.cancel();
    });
  }
}

InputDecoration authFieldDecoration(
  String label,
  IconData icon, {
  Widget? suffixIcon,
  String? helperText,
}) {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.outlineDark),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.foamSoft),
    helperText: helperText,
    helperStyle: TextStyle(color: AppColors.foamSoft.withValues(alpha: 0.7)),
    helperMaxLines: 2,
    prefixIcon: Icon(icon, color: AppColors.foamSoft),
    suffixIcon: suffixIcon,
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

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const EmailField({
    super.key,
    required this.controller,
    required this.enabled,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      maxLength: AuthService.maxEmailLength,
      // Refuse espaces et caractères de contrôle dès la saisie.
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[\s\x00-\x1F\x7F]')),
      ],
      style: const TextStyle(color: AppColors.foam),
      decoration: authFieldDecoration(
        context.l10n.emailAddress,
        Icons.mail_outline,
      ),
      onSubmitted: onSubmitted,
    );
  }
}

/// Champ de mot de passe masqué, avec bouton pour l'afficher.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;

  /// `null` : « Mot de passe » dans la langue de l'app.
  final String? label;

  /// `true` pour un nouveau mot de passe (inscription, réinitialisation) :
  /// le gestionnaire de mots de passe du système peut alors en proposer un.
  final bool isNew;
  final String? helperText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    required this.enabled,
    this.label,
    this.isNew = false,
    this.helperText,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: [
        widget.isNew ? AutofillHints.newPassword : AutofillHints.password,
      ],
      autocorrect: false,
      enableSuggestions: false,
      // Marge au-delà de la limite serveur pour afficher un message clair
      // plutôt que de tronquer silencieusement.
      maxLength: AuthService.maxPasswordLength + 1,
      style: const TextStyle(color: AppColors.foam),
      decoration: authFieldDecoration(
        widget.label ?? context.l10n.password,
        Icons.lock_outline,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          tooltip:
              _obscure ? context.l10n.showPassword : context.l10n.hidePassword,
          color: AppColors.foamSoft,
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}

/// Saisie du code à 6 chiffres reçu par e-mail. [onCompleted] est appelé
/// dès que le dernier chiffre est tapé.
class CodeField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final VoidCallback? onCompleted;

  const CodeField({
    super.key,
    required this.controller,
    required this.enabled,
    this.focusNode,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
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
      decoration: authFieldDecoration(context.l10n.emailCode, Icons.pin),
      onChanged: (value) {
        if (value.length == AuthService.codeLength) onCompleted?.call();
      },
      onSubmitted: (_) => onCompleted?.call(),
    );
  }
}

/// Bouton "Renvoyer le code" avec compte à rebours (voir
/// [AuthService.resendWait]).
class ResendCodeButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const ResendCodeButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final wait = AuthService.instance.resendWait;
    return TextButton(
      onPressed: loading || wait > Duration.zero ? null : onPressed,
      child: Text(
        wait > Duration.zero
            ? context.l10n.resendCodeWait(wait.inSeconds)
            : context.l10n.resendCode,
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
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

/// Séparateur "ou" suivi du bouton "Continuer avec Google".
class GoogleSignInSection extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const GoogleSignInSection({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.outlineDark)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.l10n.or,
                style: TextStyle(
                  color: AppColors.foamSoft.withValues(alpha: 0.7),
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.outlineDark)),
          ],
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: const _GoogleLogo(),
          label: Text(context.l10n.continueWithGoogle),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.foam,
            side: const BorderSide(color: AppColors.outlineDark),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Approximation non contractuelle du logo Google (anneau aux 4 couleurs de
/// la marque) : évite de dépendre d'un asset image tout en restant
/// reconnaissable à côté du libellé "Continuer avec Google".
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const _colors = [
    Color(0xFF4285F4),
    Color(0xFF34A853),
    Color(0xFFFBBC05),
    Color(0xFFEA4335),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.22;
    final arcRect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (var i = 0; i < _colors.length; i++) {
      paint.color = _colors[i];
      canvas.drawArc(
        arcRect,
        -pi / 2 + i * pi / 2,
        pi / 2 - 0.12,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
