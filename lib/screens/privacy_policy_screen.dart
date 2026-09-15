import 'package:flutter/material.dart';

import '../config/legal_config.dart';

/// Politique de confidentialité, accessible sans être connecté (depuis
/// l'écran de connexion) et depuis "Mon compte". La même politique est
/// publiée sur le web (web/confidentialite.html) pour les fiches des
/// stores : garder les deux versions synchronisées.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, List<String>)>[
    (
      'Qui est responsable ?',
      [
        'Le Bierodex est édité par ${LegalConfig.publisher}, responsable du '
            'traitement de tes données. Contact : ${LegalConfig.contactEmail}.',
      ],
    ),
    (
      'Données collectées',
      [
        'Compte : ton adresse e-mail et un identifiant technique. Si tu te '
            'connectes avec Google, Google nous transmet aussi ton nom et ta '
            'photo de profil ; nous ne recevons jamais ton mot de passe Google.',
        'Collection : les bières marquées comme bues ou à goûter, tes notes, '
            'dates de dégustation et commentaires, ainsi que les bières que tu '
            'ajoutes toi-même (nom, brasserie, code-barres, photo).',
        'Aucune donnée de localisation, aucun contact, aucune publicité, '
            'aucun traceur publicitaire.',
      ],
    ),
    (
      'Pourquoi ?',
      [
        'Uniquement pour faire fonctionner l\'app : te connecter et '
            'synchroniser ta collection entre tes appareils (base légale : '
            'exécution du service que tu demandes). Tes données ne sont ni '
            'vendues, ni partagées à des fins commerciales.',
      ],
    ),
    (
      'Où sont-elles stockées ?',
      [
        'Chez Supabase (hébergement ${LegalConfig.supabaseRegion}), avec un '
            'accès limité à ton seul compte. Une copie est gardée sur ton '
            'appareil pour un usage hors-ligne ; la session de connexion y est '
            'chiffrée par le système (Keychain / Keystore).',
      ],
    ),
    (
      'Services tiers',
      [
        'Open Food Facts : quand tu scannes un code-barres inconnu, ce code '
            'est envoyé à Open Food Facts pour retrouver le produit.',
        'OpenStreetMap et Wikimedia Commons : fonds de carte et photos, '
            'chargés directement depuis leurs serveurs (ton adresse IP leur '
            'est donc visible).',
        'Google : uniquement si tu choisis "Continuer avec Google".',
      ],
    ),
    (
      'Durée de conservation',
      [
        'Tant que ton compte existe. La suppression du compte efface '
            'immédiatement et définitivement toutes tes données de nos '
            'serveurs et de l\'appareil utilisé.',
      ],
    ),
    (
      'Tes droits',
      [
        'Tu peux accéder à tes données, les corriger, les exporter ou '
            'demander leur suppression, et t\'opposer à leur traitement. '
            'La suppression est disponible directement dans "Mon compte" ; '
            'pour le reste, écris à ${LegalConfig.contactEmail}.',
        'Tu peux aussi introduire une réclamation auprès de la CNIL '
            '(www.cnil.fr).',
      ],
    ),
    (
      'Âge',
      [
        'L\'app présente des boissons alcoolisées et est réservée aux '
            'personnes majeures.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Confidentialité')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Dernière mise à jour : ${LegalConfig.lastUpdated}',
              style: textTheme.bodySmall,
            ),
            for (final (title, paragraphs) in _sections) ...[
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
