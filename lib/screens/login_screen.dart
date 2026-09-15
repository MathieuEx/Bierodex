import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_form.dart';
import 'password_reset_screen.dart';
import 'sign_up_screen.dart';
import '../l10n/l10n.dart';

/// Écran d'entrée de l'app tant que personne n'est connecté (voir
/// `BierodexApp` dans `lib/main.dart`) : e-mail et mot de passe, ou compte
/// Google. Mène à la création de compte et au mot de passe oublié. Une fois
/// connecté, la session est conservée : cet écran ne revient qu'après une
/// déconnexion.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AuthFormState {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  AuthService get _auth => AuthService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // En cas de succès, `BierodexApp` remplace cet écran : rien d'autre à faire.
  Future<void> _signIn() => run(() async {
    try {
      await _auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      TextInput.finishAutofillContext();
    } on EmailNotConfirmed {
      if (!mounted) return;
      final email = AuthService.normalizeEmail(_emailController.text)!;
      _passwordController.clear();
      // Sans `await` : le formulaire ne doit pas rester bloqué pendant que
      // la page de confirmation est ouverte.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SignUpScreen(unconfirmedEmail: email),
        ),
      );
    }
  });

  Future<void> _signInWithGoogle() => run(() => _auth.signInWithGoogle());

  void _openSignUp() {
    clearError();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpScreen(initialEmail: _emailController.text),
      ),
    );
  }

  void _openPasswordReset() {
    clearError();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PasswordResetScreen(initialEmail: _emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      subtitle: context.l10n.loginSubtitle,
      error: error,
      child: Column(
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
            onSubmitted: (_) => _signIn(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: loading ? null : _openPasswordReset,
              child: Text(context.l10n.forgotPassword),
            ),
          ),
          AuthPrimaryButton(
            label: context.l10n.signIn,
            loading: loading,
            onPressed: _signIn,
          ),
          const SizedBox(height: 20),
          GoogleSignInSection(loading: loading, onPressed: _signInWithGoogle),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.l10n.noAccountYet,
                style: const TextStyle(color: AppColors.foamSoft),
              ),
              TextButton(
                onPressed: loading ? null : _openSignUp,
                child: Text(context.l10n.createAccount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
