import 'package:flutter/material.dart';

import '../services/legal_age_service.dart';
import '../theme/app_theme.dart';
import '../theme/brand.dart';
import '../widgets/health_notice.dart';
import '../l10n/l10n.dart';

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
      backgroundColor: AppColors.night,
      body: NightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset('assets/logo_icon.png', height: 120),
                    ),
                    const SizedBox(height: 16),
                    const Center(child: BrandWordmark(size: 44)),
                    const SizedBox(height: 32),
                    if (_refused)
                      Text(
                        context.l10n.ageGateRefused,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.foam,
                        ),
                      )
                    else ...[
                      Text(
                        context.l10n.ageGateQuestion(LegalAgeService.legalAge),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.foam,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.ageGateNotice,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.foamSoft,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                        ),
                        onPressed: LegalAgeService.instance.confirm,
                        child: Text(
                          context.l10n.ageGateYes(LegalAgeService.legalAge),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.foamSoft,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => setState(() => _refused = true),
                        child: Text(context.l10n.no),
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
      ),
    );
  }
}
