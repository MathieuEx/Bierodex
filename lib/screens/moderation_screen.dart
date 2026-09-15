import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../models/beer_style.dart';
import '../models/social.dart';
import '../services/social_service.dart' show SocialFailure;
import '../services/submission_service.dart';
import '../utils/text_normalize.dart';
import '../l10n/l10n.dart';

/// File des bières proposées par la communauté, réservée aux modérateurs
/// (le serveur refuse de toute façon les autres comptes, voir
/// `review_submission` dans supabase/add_social.sql).
class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  late Future<List<BeerSubmission>> _future = SubmissionService.instance
      .pendingSubmissions();

  void _reload() => setState(() {
    _future = SubmissionService.instance.pendingSubmissions();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.moderationTitle)),
      body: FutureBuilder<List<BeerSubmission>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: _reload,
                child: Text('${snapshot.error} · ${context.l10n.retry}'),
              ),
            );
          }
          final submissions = snapshot.data!;
          if (submissions.isEmpty) {
            return Center(child: Text(context.l10n.moderationEmpty));
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _SubmissionCard(
                submission: submissions[index],
                onReviewed: _reload,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final BeerSubmission submission;
  final VoidCallback onReviewed;

  const _SubmissionCard({required this.submission, required this.onReviewed});

  /// Bières du catalogue au nom ou au code-barres proche : les doublons sont
  /// la première raison de refuser.
  List<String> get _possibleDuplicates {
    final name = normalizeForSearch(submission.name);
    return [
      for (final beer in beers)
        if (!beer.isCustom &&
            ((submission.barcode != null &&
                    beer.barcode == submission.barcode) ||
                normalizeForSearch(beer.name) == name ||
                (normalizeForSearch(beer.brewery) ==
                        normalizeForSearch(submission.brewery) &&
                    normalizeForSearch(beer.name).contains(name))))
          '${beer.name} (${beer.brewery})',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = findStyleById(submission.styleId);
    final duplicates = _possibleDuplicates;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final reviewed = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => _ReviewSheet(submission: submission),
          );
          if (reviewed == true) onReviewed();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(submission.name, style: textTheme.titleMedium),
              Text(
                '${submission.brewery} · ${submission.country} · '
                '${style?.name ?? submission.styleId} · '
                '${formatDecimal(submission.abv)} %',
                style: textTheme.bodySmall,
              ),
              if (duplicates.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.moderationPossibleDuplicate(
                    duplicates.take(3).join(', '),
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  final BeerSubmission submission;

  const _ReviewSheet({required this.submission});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late final _name = TextEditingController(text: widget.submission.name);
  late final _brewery = TextEditingController(text: widget.submission.brewery);
  late final _country = TextEditingController(text: widget.submission.country);
  late final _abv = TextEditingController(
    text: widget.submission.abv.toStringAsFixed(1),
  );
  late final _description = TextEditingController(
    text: widget.submission.description,
  );
  final _note = TextEditingController();
  late String _styleId = widget.submission.styleId;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _brewery, _country, _abv, _description, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _review(bool approve) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final abv = double.tryParse(_abv.text.replaceAll(',', '.'));
    if (approve && (abv == null || abv < 0 || abv > 100)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.invalidAbv)));
      return;
    }
    setState(() => _busy = true);
    try {
      await SubmissionService.instance.review(
        widget.submission,
        approve: approve,
        note: _note.text,
        name: _name.text,
        brewery: _brewery.text,
        country: _country.text,
        styleId: _styleId,
        abv: abv,
        description: _description.text.trim(),
      );
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            approve ? l10n.moderationApproved : l10n.submissionRejected,
          ),
        ),
      );
    } on SocialFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.moderationReview,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (submission.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Image.network(
                  submission.imageUrl!,
                  height: 140,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (submission.barcode != null)
              Text(context.l10n.barcodeValue(submission.barcode!)),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: context.l10n.fieldName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _brewery,
              decoration: InputDecoration(labelText: context.l10n.fieldBrewery),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _country,
              decoration: InputDecoration(labelText: context.l10n.fieldCountry),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _styleId,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.fieldStyle),
              items: [
                for (final family in BeerFamily.values)
                  for (final style in stylesForFamily(family))
                    DropdownMenuItem(value: style.id, child: Text(style.name)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _styleId = value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _abv,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: context.l10n.fieldAbv),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.fieldDescription,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: context.l10n.moderationNote,
                helperText: context.l10n.moderationNoteHelper,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _review(false),
                    child: Text(context.l10n.decline),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : () => _review(true),
                    child: Text(context.l10n.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
