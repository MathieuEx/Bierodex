import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../services/achievement_service.dart';
import '../services/auth_service.dart';
import '../services/beer_collection_service.dart';
import '../services/notification_service.dart';
import '../services/offline_sync_service.dart';
import '../services/user_beer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/health_notice.dart';
import '../services/submission_service.dart';
import 'moderation_screen.dart';
import 'privacy_policy_screen.dart';
import 'social_screen.dart';
import '../l10n/l10n.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountTitle)),
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
              backgroundColor: Color(0x29F28A17),
              foregroundColor: AppColors.amber,
              child: Icon(Icons.person),
            ),
            title: Text(email),
            subtitle: Text(
              context.l10n.accountSignedIn,
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _SyncStatus(),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text(context.l10n.accountFriendsAndProfile),
            subtitle: Text(context.l10n.accountFriendsAndProfileDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SocialScreen())),
          ),
        ),
        const _ModerationEntry(),
        if (NotificationService.isSupported) const _ReminderSettings(),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: Text(context.l10n.signOut),
          onPressed: () => AuthService.instance.signOut(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.devices_other),
          label: Text(context.l10n.signOutEverywhere),
          onPressed: () => _signOutEverywhere(context),
        ),
        const SizedBox(height: 32),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(context.l10n.privacyPolicyTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever, color: AppColors.error),
          title: Text(
            context.l10n.deleteAccount,
            style: const TextStyle(color: AppColors.error),
          ),
          subtitle: Text(context.l10n.deleteAccountDescription),
          onTap: () => _deleteAccount(context),
        ),
        const SizedBox(height: 24),
        const HealthNotice(),
      ],
    );
  }
}

/// Rassure sur la synchronisation, ou indique combien de modifications
/// faites hors-ligne attendent le retour du réseau.
class _SyncStatus extends StatelessWidget {
  const _SyncStatus();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineSyncService.instance,
      builder: (context, _) {
        final pending = OfflineSyncService.instance.pendingCount;
        if (pending == 0) {
          return Text(
            context.l10n.accountSyncedDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: Text(context.l10n.accountPendingChanges(pending)),
            subtitle: Text(context.l10n.accountPendingChangesDescription),
            trailing: IconButton(
              tooltip: context.l10n.retryNow,
              icon: const Icon(Icons.refresh),
              onPressed: OfflineSyncService.instance.flush,
            ),
          ),
        );
      },
    );
  }
}

class _ReminderSettings extends StatelessWidget {
  const _ReminderSettings();

  @override
  Widget build(BuildContext context) {
    final service = NotificationService.instance;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: ListenableBuilder(
          listenable: service,
          builder: (context, _) => Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(context.l10n.reminderInactivitySetting),
                subtitle: Text(
                  context.l10n.reminderInactivitySettingDescription,
                ),
                value: service.inactivityEnabled,
                onChanged: service.setInactivityEnabled,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.bookmark_border),
                title: Text(context.l10n.reminderWishlistSetting),
                subtitle: Text(context.l10n.reminderWishlistSettingDescription),
                value: service.wishlistEnabled,
                onChanged: service.setWishlistEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visible uniquement pour les comptes listés dans la table `moderators`.
class _ModerationEntry extends StatefulWidget {
  const _ModerationEntry();

  @override
  State<_ModerationEntry> createState() => _ModerationEntryState();
}

class _ModerationEntryState extends State<_ModerationEntry> {
  late final Future<bool> _isModerator = SubmissionService.instance
      .loadIsModerator();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isModerator,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: Text(context.l10n.moderationTitle),
              subtitle: Text(context.l10n.moderationDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModerationScreen()),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _signOutEverywhere(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.signOutEverywhereTitle),
      content: Text(context.l10n.signOutEverywhereDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.signOutEverywhereConfirm),
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
      SnackBar(content: Text(context.l10n.errorServerUnreachable)),
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
  final l10n = context.l10n;
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.deleteAccountInProgress),
      duration: Duration(minutes: 1),
    ),
  );
  try {
    final userId = await AuthService.instance.deleteAccount();
    if (userId != null) {
      await BeerCollectionService.forgetUser(userId);
      await UserBeerService.forgetUser(userId);
      await AchievementService.forgetUser(userId);
    }
    // La déconnexion referme cette page et ramène à l'écran de connexion.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
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
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirmationWord = context.l10n.deleteAccountConfirmationWord;
    final matches = _controller.text.trim().toUpperCase() == confirmationWord;
    return AlertDialog(
      title: Text(context.l10n.deleteAccountTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.deleteAccountWarning),
          const SizedBox(height: 16),
          Text(context.l10n.deleteAccountTypeToConfirm(confirmationWord)),
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
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          // Action destructrice : rouge uni plutôt que le dégradé ambré.
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ).copyWith(backgroundBuilder: (_, _, child) => child!),
          onPressed: matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(context.l10n.deleteAccountConfirm),
        ),
      ],
    );
  }
}
