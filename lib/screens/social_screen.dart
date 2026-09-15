import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/social.dart';
import '../services/social_service.dart';
import '../theme/app_theme.dart';
import 'shared_profile_screen.dart';
import '../l10n/l10n.dart';

/// Profil (pseudo, visibilité, lien public) et gestion des amis.
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late Future<void> _loading = _load();

  Future<void> _load() async {
    final profile = await SocialService.instance.loadProfile();
    if (profile != null) await SocialService.instance.loadFriendships();
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is SocialFailure ? error.message : '$error'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountFriendsAndProfile)),
      body: FutureBuilder<void>(
        future: _loading,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _loading = _load()),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListenableBuilder(
            listenable: SocialService.instance,
            builder: (context, _) {
              final service = SocialService.instance;
              final profile = service.profile;
              return RefreshIndicator(
                onRefresh: () async {
                  try {
                    await _load();
                  } catch (e) {
                    _showError(e);
                  }
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ProfileCard(profile: profile, onError: _showError),
                    if (profile != null) ...[
                      const SizedBox(height: 24),
                      _AddFriendField(onError: _showError),
                      if (service.receivedRequests.isNotEmpty) ...[
                        _SectionTitle(context.l10n.socialReceivedRequests),
                        for (final request in service.receivedRequests)
                          _FriendshipTile(
                            friendship: request,
                            onError: _showError,
                          ),
                      ],
                      _SectionTitle(context.l10n.socialMyFriends),
                      if (service.friends.isEmpty)
                        Text(
                          context.l10n.socialNoFriends,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      for (final friend in service.friends)
                        _FriendshipTile(
                          friendship: friend,
                          onError: _showError,
                        ),
                      if (service.sentRequests.isNotEmpty) ...[
                        _SectionTitle(context.l10n.socialSentRequests),
                        for (final request in service.sentRequests)
                          _FriendshipTile(
                            friendship: request,
                            onError: _showError,
                          ),
                      ],
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );
}

class _ProfileCard extends StatelessWidget {
  final UserProfile? profile;
  final ValueChanged<Object> onError;

  const _ProfileCard({required this.profile, required this.onError});

  Future<void> _edit(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProfileEditor(initial: profile),
    );
  }

  Future<void> _shareLink(BuildContext context, Uri link) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        uri: link,
        subject: context.l10n.socialShareSubject,
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = profile;
    if (current == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.socialCreateProfile,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.socialCreateProfileDescription,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _edit(context),
                child: Text(context.l10n.socialChooseUsername),
              ),
            ],
          ),
        ),
      );
    }

    final link = current.visibility == ProfileVisibility.public
        ? SocialService.profileLink(current.username)
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0x29C9752B),
                  foregroundColor: AppColors.copper,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.displayName ?? '@${current.username}',
                        style: textTheme.titleMedium,
                      ),
                      if (current.displayName != null)
                        Text(
                          '@${current.username}',
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.socialEditProfile,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _edit(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  switch (current.visibility) {
                    ProfileVisibility.private => Icons.lock_outline,
                    ProfileVisibility.friends => Icons.group_outlined,
                    ProfileVisibility.public => Icons.public,
                  },
                  size: 18,
                  color: AppColors.copper,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.socialCollectionVisibility(
                      current.visibility.label.toLowerCase(),
                      current.visibility.description,
                    ),
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(context.l10n.socialViewAsOthers),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SharedProfileScreen(username: current.username),
                    ),
                  ),
                ),
                if (link != null) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.ios_share),
                    label: Text(context.l10n.socialShareLink),
                    onPressed: () =>
                        _shareLink(context, link).catchError(onError),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.link),
                    label: Text(context.l10n.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: '$link'));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.socialLinkCopied)),
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditor extends StatefulWidget {
  final UserProfile? initial;

  const _ProfileEditor({required this.initial});

  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final _username = TextEditingController(text: widget.initial?.username);
  late final _displayName = TextEditingController(
    text: widget.initial?.displayName,
  );
  late ProfileVisibility _visibility =
      widget.initial?.visibility ?? ProfileVisibility.private;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _username.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final username = SocialService.normalizeUsername(_username.text);
    final problem = SocialService.usernameProblem(username);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await SocialService.instance.saveProfile(
        username: username,
        displayName: _displayName.text,
        visibility: _visibility,
      );
      if (mounted) Navigator.of(context).pop();
    } on SocialFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.socialMyProfile, style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _username,
              autocorrect: false,
              enableSuggestions: false,
              maxLength: SocialService.maxUsernameLength,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9_@]')),
              ],
              decoration: InputDecoration(
                labelText: context.l10n.socialUsername,
                prefixText: '@',
                errorText: _error,
                helperText: context.l10n.socialUsernameHelper,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayName,
              maxLength: SocialService.maxDisplayNameLength,
              decoration: InputDecoration(
                labelText: context.l10n.socialDisplayNameOptional,
              ),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.socialWhoCanSee, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            RadioGroup<ProfileVisibility>(
              groupValue: _visibility,
              onChanged: (value) {
                if (value != null) setState(() => _visibility = value);
              },
              child: Column(
                children: [
                  for (final option in ProfileVisibility.values)
                    RadioListTile<ProfileVisibility>(
                      contentPadding: EdgeInsets.zero,
                      value: option,
                      title: Text(option.label),
                      subtitle: Text(option.description),
                    ),
                ],
              ),
            ),
            Text(
              context.l10n.socialSharedDataNotice,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? context.l10n.saving : context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFriendField extends StatefulWidget {
  final ValueChanged<Object> onError;

  const _AddFriendField({required this.onError});

  @override
  State<_AddFriendField> createState() => _AddFriendFieldState();
}

class _AddFriendFieldState extends State<_AddFriendField> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final username = SocialService.normalizeUsername(_controller.text);
    if (username.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final accepted = await SocialService.instance.sendFriendRequest(username);
      _controller.clear();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            accepted
                ? l10n.socialNowFriends(username)
                : l10n.socialRequestSent(username),
          ),
        ),
      );
    } catch (e) {
      widget.onError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _send(),
      decoration: InputDecoration(
        labelText: context.l10n.socialAddFriend,
        hintText: context.l10n.socialAddFriendHint,
        prefixText: '@',
        suffixIcon: _busy
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                tooltip: context.l10n.socialSendRequest,
                icon: const Icon(Icons.person_add_alt_1),
                onPressed: _send,
              ),
      ),
    );
  }
}

class _FriendshipTile extends StatelessWidget {
  final Friendship friendship;
  final ValueChanged<Object> onError;

  const _FriendshipTile({required this.friendship, required this.onError});

  Future<void> _remove(BuildContext context) async {
    if (friendship.accepted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.socialRemoveFriendTitle(friendship.label)),
          content: Text(context.l10n.socialRemoveFriendDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.remove),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      await SocialService.instance.removeFriendship(friendship.id);
    } catch (e) {
      onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle =
        friendship.displayName != null ? '@${friendship.username}' : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0x29C9752B),
        foregroundColor: AppColors.copper,
        child: Icon(Icons.person_outline),
      ),
      title: Text(friendship.label),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: friendship.accepted
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      SharedProfileScreen(username: friendship.username),
                ),
              )
          : null,
      trailing: switch ((friendship.accepted, friendship.sentByMe)) {
        (true, _) => IconButton(
            tooltip: context.l10n.socialRemoveFriend,
            icon: const Icon(Icons.person_remove_outlined),
            onPressed: () => _remove(context),
          ),
        (false, false) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.decline,
                icon: const Icon(Icons.close),
                onPressed: () => _remove(context),
              ),
              IconButton.filled(
                tooltip: context.l10n.accept,
                icon: const Icon(Icons.check),
                onPressed: () => SocialService.instance
                    .acceptFriendRequest(friendship.id)
                    .catchError(onError),
              ),
            ],
          ),
        (false, true) => TextButton(
            onPressed: () => _remove(context),
            child: Text(context.l10n.cancel),
          ),
      },
    );
  }
}
