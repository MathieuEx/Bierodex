import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../services/auth_service.dart';
import '../services/beer_collection_service.dart';
import '../services/user_beer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/health_notice.dart';
import 'privacy_policy_screen.dart';

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
        const SizedBox(height: 32),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Politique de confidentialité'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever, color: AppColors.error),
          title: const Text(
            'Supprimer mon compte',
            style: TextStyle(color: AppColors.error),
          ),
          subtitle: const Text('Efface définitivement toutes tes données.'),
          onTap: () => _deleteAccount(context),
        ),
        const SizedBox(height: 24),
        const HealthNotice(),
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

Future<void> _deleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(
      content: Text('Suppression en cours...'),
      duration: Duration(minutes: 1),
    ),
  );
  try {
    final userId = await AuthService.instance.deleteAccount();
    if (userId != null) {
      await BeerCollectionService.forgetUser(userId);
      await UserBeerService.forgetUser(userId);
    }
    // La déconnexion referme cette page et ramène à l'écran de connexion.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Ton compte a été supprimé.')),
    );
  } on AuthFailure catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

/// Confirmation renforcée : il faut taper le mot SUPPRIMER, pour qu'un
/// appui distrait ne puisse pas effacer une collection entière.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  static const _confirmationWord = 'SUPPRIMER';

  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _controller.text.trim().toUpperCase() == _confirmationWord;
    return AlertDialog(
      title: const Text('Supprimer ton compte ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ta collection, tes notes, tes commentaires et les bières que tu '
            'as ajoutées seront effacés définitivement, sur tous tes '
            'appareils. Cette action est irréversible.',
          ),
          const SizedBox(height: 16),
          const Text('Tape $_confirmationWord pour confirmer :'),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: matches ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Supprimer définitivement'),
        ),
      ],
    );
  }
}
