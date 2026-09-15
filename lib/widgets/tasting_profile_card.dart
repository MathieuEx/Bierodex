import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer_user_status.dart';
import '../screens/compare_beers_screen.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import 'radar_chart.dart';
import '../l10n/l10n.dart';

/// Teintes de bière de la plus pâle à la plus foncée, pour le critère
/// « Couleur » (1 à 5).
const beerColorSwatches = [
  Color(0xFFF3D46B),
  Color(0xFFE3A534),
  Color(0xFFB5651D),
  Color(0xFF6E3B1A),
  Color(0xFF241510),
];

/// Libellés des cinq niveaux de couleur, du plus pâle au plus foncé.
List<String> get beerColorLabels {
  final l10n = L10n.current;
  return [
    l10n.colorStraw,
    l10n.colorGolden,
    l10n.colorAmber,
    l10n.colorBrown,
    l10n.colorBlack,
  ];
}

/// Fiche de dégustation détaillée d'une bière bue : couleur, amertume,
/// douceur, corps, arômes à cocher, et le radar qui en résulte. Chaque
/// modification est enregistrée immédiatement.
class TastingProfileCard extends StatelessWidget {
  final String beerId;

  const TastingProfileCard({super.key, required this.beerId});

  void _save(
    BeerUserStatus s, {
    Object? color = _keep,
    Object? bitterness = _keep,
    Object? sweetness = _keep,
    Object? body = _keep,
    List<String>? aromas,
  }) {
    BeerCollectionService.instance.setTastingProfile(
      beerId,
      color: color == _keep ? s.color : color as int?,
      bitterness: bitterness == _keep ? s.bitterness : bitterness as int?,
      sweetness: sweetness == _keep ? s.sweetness : sweetness as int?,
      body: body == _keep ? s.body : body as int?,
      aromas: aromas ?? s.aromas,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final service = BeerCollectionService.instance;
        final status = service.statusFor(beerId);
        if (!status.tried) return const SizedBox.shrink();
        final textTheme = Theme.of(context).textTheme;

        // On ne propose la comparaison que s'il existe une autre fiche
        // remplie à mettre en face.
        final canCompare = service.statuses.entries.any(
          (e) =>
              e.key != beerId &&
              e.value.tried &&
              e.value.hasTastingProfile &&
              findBeerById(e.key) != null,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.tastingProfileTitle,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.tastingProfileHint,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                _ColorPicker(
                  value: status.color,
                  onChanged: (v) => _save(status, color: v),
                ),
                const SizedBox(height: 12),
                _LevelPicker(
                  label: context.l10n.criterionBitterness,
                  low: context.l10n.bitternessLow,
                  high: context.l10n.bitternessHigh,
                  value: status.bitterness,
                  onChanged: (v) => _save(status, bitterness: v),
                ),
                const SizedBox(height: 12),
                _LevelPicker(
                  label: context.l10n.criterionSweetness,
                  low: context.l10n.sweetnessLow,
                  high: context.l10n.sweetnessHigh,
                  value: status.sweetness,
                  onChanged: (v) => _save(status, sweetness: v),
                ),
                const SizedBox(height: 12),
                _LevelPicker(
                  label: context.l10n.criterionBody,
                  low: context.l10n.bodyLow,
                  high: context.l10n.bodyHigh,
                  value: status.body,
                  onChanged: (v) => _save(status, body: v),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.aromas, style: textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final entry in tastingAromas.entries)
                      FilterChip(
                        label: Text(entry.value),
                        selected: status.aromas.contains(entry.key),
                        visualDensity: VisualDensity.compact,
                        onSelected: (selected) => _save(
                          status,
                          aromas: selected
                              ? [...status.aromas, entry.key]
                              : [
                                  for (final a in status.aromas)
                                    if (a != entry.key) a,
                                ],
                        ),
                      ),
                  ],
                ),
                if (status.hasTastingProfile) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: RadarChart(
                      axes: tastingAxes,
                      series: [
                        RadarSeries(
                          label: findBeerById(beerId)?.name ?? '',
                          color: AppColors.amber,
                          values: tastingValues(status),
                        ),
                      ],
                    ),
                  ),
                ],
                if (canCompare && status.hasTastingProfile)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.compare_arrows),
                      label: Text(context.l10n.compareWithAnother),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CompareBeersScreen(firstId: beerId),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _keep = Object();

/// Cinq pastilles de 1 à 5 ; retoucher la valeur choisie l'efface.
class _LevelPicker extends StatelessWidget {
  final String label;
  final String low;
  final String high;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _LevelPicker({
    required this.label,
    required this.low,
    required this.high,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final outline = Theme.of(context).colorScheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(width: 52, child: Text(low, style: textTheme.bodySmall)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var level = 1; level <= 5; level++)
                    Semantics(
                      button: true,
                      selected: value == level,
                      label: context.l10n.levelOutOfFive(label, level),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onChanged(value == level ? null : level),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: value != null && level <= value!
                                  ? AppColors.amber
                                  : Colors.transparent,
                              border: Border.all(
                                color: value != null && level <= value!
                                    ? AppColors.amber
                                    : outline,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                high,
                style: textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Critère « Couleur » : cinq teintes réelles plutôt que des pastilles.
class _ColorPicker extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _ColorPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value == null
              ? context.l10n.criterionColor
              : '${context.l10n.criterionColor} · ${beerColorLabels[value! - 1]}',
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var level = 1; level <= 5; level++)
              Semantics(
                button: true,
                selected: value == level,
                label:
                    '${context.l10n.criterionColor} ${beerColorLabels[level - 1]}',
                child: GestureDetector(
                  onTap: () => onChanged(value == level ? null : level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: beerColorSwatches[level - 1],
                      border: Border.all(
                        color: value == level
                            ? AppColors.amber
                            : Theme.of(context).colorScheme.outline,
                        width: value == level ? 3.5 : 1.5,
                      ),
                    ),
                    child: value == level
                        ? Icon(
                            Icons.check,
                            size: 20,
                            color: level <= 2 ? AppColors.ink : Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
