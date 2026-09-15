import 'package:flutter/material.dart';

import '../models/social.dart';
import '../services/social_service.dart' show SocialFailure;
import '../services/submission_service.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';

/// Sur la fiche d'une bière ajoutée à la main : la proposer au catalogue
/// commun, et suivre où en est la validation.
class CommunitySubmissionCard extends StatefulWidget {
  final String beerId;

  const CommunitySubmissionCard({super.key, required this.beerId});

  @override
  State<CommunitySubmissionCard> createState() =>
      _CommunitySubmissionCardState();
}

class _CommunitySubmissionCardState extends State<CommunitySubmissionCard> {
  late Future<void> _loading = SubmissionService.instance.loadMine().catchError(
        (_) {},
      );
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String success) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } on SocialFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.submissionConfirmTitle),
        content: Text(context.l10n.submissionConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.submit),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => SubmissionService.instance.submit(widget.beerId),
      context.l10n.submissionThanks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) => ListenableBuilder(
        listenable: SubmissionService.instance,
        builder: (context, _) {
          final textTheme = Theme.of(context).textTheme;
          final submission = SubmissionService.instance.submissionFor(
            widget.beerId,
          );
          final loading = snapshot.connectionState != ConnectionState.done;
          final l10n = context.l10n;

          final (icon, title, text) = switch (submission?.status) {
            null => (
                Icons.public,
                l10n.submissionSharedCatalog,
                l10n.submissionSharedCatalogDescription,
              ),
            SubmissionStatus.pending => (
                Icons.hourglass_top,
                l10n.submissionPending,
                l10n.submissionPendingDescription,
              ),
            SubmissionStatus.approved => (
                Icons.verified_outlined,
                l10n.submissionApproved,
                l10n.submissionApprovedDescription,
              ),
            SubmissionStatus.rejected => (
                Icons.block,
                l10n.submissionRejectedTitle,
                submission!.reviewNote ?? l10n.submissionRejectedDescription,
              ),
          };

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: AppColors.copper, size: 20),
                      const SizedBox(width: 8),
                      Text(title, style: textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(text, style: textTheme.bodyMedium),
                  if (!loading) ...[
                    const SizedBox(height: 8),
                    if (submission == null ||
                        submission.status == SubmissionStatus.rejected)
                      OutlinedButton(
                        onPressed: _busy ? null : _submit,
                        child: Text(
                          submission == null
                              ? l10n.submissionSubmit
                              : l10n.submissionResubmit,
                        ),
                      )
                    else if (submission.status == SubmissionStatus.pending)
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _run(
                                  () => SubmissionService.instance.withdraw(
                                    submission,
                                  ),
                                  l10n.submissionWithdrawn,
                                ),
                        child: Text(context.l10n.submissionWithdraw),
                      ),
                  ] else
                    TextButton(
                      onPressed: () => setState(() {
                        _loading = SubmissionService.instance
                            .loadMine()
                            .catchError((_) {});
                      }),
                      child: Text(context.l10n.loading),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
