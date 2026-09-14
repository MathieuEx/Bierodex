import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon compte')),
      // Toujours connecté ici : la connexion est obligatoire pour entrer
      // dans l'app, et une déconnexion referme cette page (voir
      // `BierodexApp` dans lib/main.dart).
      body: const _SignedInView(),
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
            contentPadding: const EdgeInsets.all(14),
            leading: const CircleAvatar(
              backgroundColor: Color(0x29C9752B),
              foregroundColor: AppColors.copper,
              child: Icon(Icons.person),
            ),
            title: Text(email),
            subtitle: Text(
              'Connecté',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ta collection (bières bues et notées) est synchronisée avec ce '
          'compte et accessible depuis n\'importe quel appareil.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
          onPressed: () => AuthService.instance.signOut(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.devices_other),
          label: const Text('Se déconnecter de tous les appareils'),
          onPressed: () => _signOutEverywhere(context),
        ),
      ],
    );
  }
}

Future<void> _signOutEverywhere(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tous les appareils ?'),
      content: const Text(
        'Toutes les sessions ouvertes avec ce compte (téléphone, tablette, '
        'navigateur...) seront fermées. À faire en cas de perte ou de vol '
        'd\'un appareil.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Tout déconnecter'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await AuthService.instance.signOut(everywhere: true);
  } on AuthException {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Impossible de joindre le serveur. Vérifie ta connexion internet.',
        ),
      ),
    );
  }
}
