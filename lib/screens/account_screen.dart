import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/beer_collection_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon compte')),
      body: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) {
          return AuthService.instance.isSignedIn
              ? const _SignedInView()
              : const _SignInForm();
        },
      ),
    );
  }
}

class _SignedInView extends StatelessWidget {
  const _SignedInView();

  @override
  Widget build(BuildContext context) {
    final email = AuthService.instance.userEmail ?? '';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(email),
            subtitle: const Text('Connecté'),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ta collection (bières bues et notées) est synchronisée avec ce '
          'compte et accessible depuis n\'importe quel appareil.',
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
          onPressed: () => AuthService.instance.signOut(),
        ),
      ],
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.sendCode(email);
      setState(() => _codeSent = true);
    } catch (e) {
      setState(() => _error = 'Impossible d\'envoyer le code : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.verifyCode(email: email, code: code);
      await BeerCollectionService.instance.syncWithRemote();
    } catch (e) {
      setState(() => _error = 'Code invalide ou expiré : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _codeSent
              ? 'Un code à 6 chiffres a été envoyé à ${_emailController.text.trim()}.'
              : 'Connecte-toi pour synchroniser ta collection entre tes appareils.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          enabled: !_codeSent,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Adresse e-mail',
            border: OutlineInputBorder(),
          ),
        ),
        if (_codeSent) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Code reçu par e-mail',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _loading
              ? null
              : (_codeSent ? _verifyCode : _sendCode),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_codeSent ? 'Valider le code' : 'Recevoir un code'),
        ),
        if (_codeSent)
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() {
                      _codeSent = false;
                      _codeController.clear();
                    }),
            child: const Text('Changer d\'adresse e-mail'),
          ),
      ],
    );
  }
}
