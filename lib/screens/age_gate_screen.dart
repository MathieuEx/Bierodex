import 'package:flutter/material.dart';

import '../services/legal_age_service.dart';
import '../theme/app_theme.dart';
import '../widgets/health_notice.dart';

/// Premier écran de l'app sur un nouvel appareil : l'utilisateur déclare
/// avoir l'âge légal avant d'accéder au moindre contenu sur la bière.
class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  bool _refused = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.stout,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sports_bar,
                    size: 48,
                    color: AppColors.copper,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'BIERODEX',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.foam,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_refused)
                    Text(
                      'Le Bierodex est réservé aux personnes ayant l\'âge '
                      'légal de consommer de l\'alcool. Reviens nous voir '
                      'dans quelques années !',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.foam,
                      ),
                    )
                  else ...[
                    Text(
                      'As-tu ${LegalAgeService.legalAge} ans ou plus ?',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.foam,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cette application présente des boissons alcoolisées. '
                      'Elle est réservée aux personnes majeures.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.foamSoft,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: AppColors.stout,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: LegalAgeService.instance.confirm,
                      child: Text(
                        'Oui, j\'ai ${LegalAgeService.legalAge} ans ou plus',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.foamSoft,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => setState(() => _refused = true),
                      child: const Text('Non'),
                    ),
                  ],
                  const SizedBox(height: 40),
                  const HealthNotice(onDark: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
