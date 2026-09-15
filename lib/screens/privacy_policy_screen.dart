import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/legal_config.dart';
import '../l10n/l10n.dart';

/// Politique de confidentialité, accessible sans être connecté (depuis
/// l'écran de connexion) et depuis "Mon compte". La même politique est
/// publiée sur le web (web/confidentialite.html) pour les fiches des
/// stores : garder les deux versions synchronisées.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static List<(String, List<String>)> _sections(AppLocalizations l10n) => [
    (
      l10n.privacyWhoTitle,
      [
        l10n.privacyWhoParagraph1(
          LegalConfig.publisher,
          LegalConfig.contactEmail,
        ),
      ],
    ),
    (
      l10n.privacyDataTitle,
      [
        l10n.privacyDataParagraph1,
        l10n.privacyDataParagraph2,
        l10n.privacyDataParagraph3,
        l10n.privacyDataParagraph4,
        l10n.privacyDataParagraph5,
      ],
    ),
    (l10n.privacyWhyTitle, [l10n.privacyWhyParagraph1]),
    (
      l10n.privacySharingTitle,
      [
        l10n.privacySharingParagraph1,
        l10n.privacySharingParagraph2,
        l10n.privacySharingParagraph3,
        l10n.privacySharingParagraph4,
      ],
    ),
    (
      l10n.privacyStorageTitle,
      [l10n.privacyStorageParagraph1(LegalConfig.supabaseRegion)],
    ),
    (
      l10n.privacyThirdPartiesTitle,
      [
        l10n.privacyThirdPartiesParagraph1,
        l10n.privacyThirdPartiesParagraph2,
        l10n.privacyThirdPartiesParagraph3,
        l10n.privacyThirdPartiesParagraph4,
        l10n.privacyThirdPartiesParagraph5,
      ],
    ),
    (l10n.privacyRetentionTitle, [l10n.privacyRetentionParagraph1]),
    (
      l10n.privacyRightsTitle,
      [
        l10n.privacyRightsParagraph1(LegalConfig.contactEmail),
        l10n.privacyRightsParagraph2,
      ],
    ),
    (l10n.privacyAgeTitle, [l10n.privacyAgeParagraph1]),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final lastUpdated = DateFormat.yMMMMd(
      l10n.localeName,
    ).format(LegalConfig.lastUpdated);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              l10n.privacyLastUpdated(lastUpdated),
              style: textTheme.bodySmall,
            ),
            for (final (title, paragraphs) in _sections(l10n)) ...[
              const SizedBox(height: 20),
              Text(title, style: textTheme.titleMedium),
              for (final paragraph in paragraphs) ...[
                const SizedBox(height: 8),
                Text(paragraph, style: textTheme.bodyMedium),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
