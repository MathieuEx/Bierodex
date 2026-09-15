import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../data/countries.dart';
import '../models/beer_style.dart';
import '../services/beer_collection_service.dart';
import '../services/collection_insights.dart';
import '../theme/app_theme.dart';
import 'beer_detail_screen.dart';
import '../l10n/l10n.dart';

/// « Mes statistiques » : répartition des dégustations (style, famille,
/// pays, mois), carte de chaleur des pays, badges et recommandations.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.statsTitle)),
      body: ListenableBuilder(
        listenable: BeerCollectionService.instance,
        builder: (context, _) {
          final insights = CollectionInsights(
            catalog: beers,
            statuses: BeerCollectionService.instance.statuses,
            styleOf: findStyleById,
          );
          final tasted = insights.tasted;
          final rated = [
            for (final t in tasted)
              if (t.status.rating != null) t.status.rating!,
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _SummaryTiles(
                tasted: tasted.length,
                styles: insights.countByStyle.length,
                countries: insights.countByCountry.length,
                average: rated.isEmpty
                    ? null
                    : rated.reduce((a, b) => a + b) / rated.length,
              ),
              if (tasted.isEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  context.l10n.statsEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ] else ...[
                _Section(
                  title: context.l10n.statsByMonth,
                  subtitle: context.l10n.statsLast12Months,
                  child: _MonthlyChart(
                    data: insights.monthlyTastings(now: DateTime.now()),
                  ),
                ),
                _Section(
                  title: context.l10n.statsByFamily,
                  child: _BarList(
                    rows: [
                      for (final family in BeerFamily.values)
                        _BarRow(
                          label: family.label,
                          value: insights.countByFamily[family]!.toDouble(),
                          valueLabel: '${insights.countByFamily[family]}',
                          color: family.color,
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: context.l10n.statsByStyle,
                  child: _BarList(
                    collapsedCount: 8,
                    rows: [
                      for (final s in insights.countByStyle)
                        _BarRow(
                          label: s.style.name,
                          value: s.count.toDouble(),
                          valueLabel: '${s.count}',
                        ),
                    ],
                  ),
                ),
                if (insights.averageByStyle.isNotEmpty)
                  _Section(
                    title: context.l10n.statsAverageByStyle,
                    child: _BarList(
                      collapsedCount: 8,
                      maxValue: 5,
                      rows: [
                        for (final s in insights.averageByStyle)
                          _BarRow(
                            label: s.style.name,
                            value: s.average,
                            valueLabel: '${formatDecimal(s.average)}/5'
                                ' · ${s.count}',
                            color: AppColors.gold,
                          ),
                      ],
                    ),
                  ),
                _Section(
                  title: context.l10n.statsCountries,
                  subtitle: context.l10n.statsCountriesHint,
                  child: Column(
                    children: [
                      _CountryHeatmap(data: insights.countByCountry),
                      const SizedBox(height: 12),
                      _BarList(
                        collapsedCount: 5,
                        rows: [
                          for (final c in insights.countByCountry)
                            _BarRow(
                              label: countryName(c.country),
                              value: c.count.toDouble(),
                              valueLabel: '${c.count}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              _Section(
                title: context.l10n.statsForYou,
                subtitle: context.l10n.statsForYouHint,
                child: _Recommendations(items: insights.recommendations()),
              ),
              _Section(
                title: context.l10n.statsBadges,
                child: _AchievementGrid(items: insights.achievements),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: textTheme.titleSmall),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryTiles extends StatelessWidget {
  final int tasted;
  final int styles;
  final int countries;
  final double? average;

  const _SummaryTiles({
    required this.tasted,
    required this.styles,
    required this.countries,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = [
      ('$tasted', l10n.statsTileBeers(tasted)),
      ('$styles', l10n.statsTileStyles(styles)),
      ('$countries', l10n.statsTileCountries(countries)),
      (average == null ? '–' : formatDecimal(average!), l10n.statsTileAverage),
    ];
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    tiles[i].$1,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    tiles[i].$2,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BarRow {
  final String label;
  final double value;
  final String valueLabel;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.valueLabel,
    this.color = AppColors.copper,
  });
}

/// Barres horizontales étiquetées : le libellé et la valeur sont toujours
/// écrits, la couleur n'est qu'un repère secondaire.
class _BarList extends StatefulWidget {
  final List<_BarRow> rows;
  final double? maxValue;
  final int? collapsedCount;

  const _BarList({required this.rows, this.maxValue, this.collapsedCount});

  @override
  State<_BarList> createState() => _BarListState();
}

class _BarListState extends State<_BarList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final max = widget.maxValue ??
        widget.rows.fold<double>(0, (m, r) => math.max(m, r.value));
    final limit = widget.collapsedCount;
    final canCollapse = limit != null && widget.rows.length > limit;
    final visible = canCollapse && !_expanded
        ? widget.rows.take(limit).toList()
        : widget.rows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in visible)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 128,
                  child: Text(
                    row.label,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final ratio = max <= 0 ? 0.0 : row.value / max;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 12,
                          // Une valeur nulle garde une trace visible.
                          width: math.max(2, constraints.maxWidth * ratio),
                          decoration: BoxDecoration(
                            color: row.color,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    row.valueLabel,
                    style: textTheme.labelMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        if (canCollapse)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? context.l10n.showLess
                    : context.l10n.showAll(widget.rows.length),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<({DateTime month, int count})> data;

  const _MonthlyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final max = data.fold<int>(0, (m, d) => math.max(m, d.count));
    const chartHeight = 120.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final d in data)
          Expanded(
            child: Tooltip(
              message: context.l10n.statsMonthTooltip(
                '${formatShortMonth(d.month)} ${d.month.year}',
                d.count,
              ),
              child: Column(
                children: [
                  if (d.count > 0)
                    Text('${d.count}', style: textTheme.labelSmall)
                  else
                    const SizedBox(height: 14),
                  const SizedBox(height: 2),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height:
                        max == 0 ? 2 : math.max(2, chartHeight * d.count / max),
                    decoration: BoxDecoration(
                      color: d.count == 0
                          ? Theme.of(context).colorScheme.outlineVariant
                          : AppColors.copper,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatShortMonth(d.month).substring(0, 1).toUpperCase(),
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Carte de chaleur : un cercle par pays goûté, dont l'aire et l'intensité
/// suivent le nombre de bières dégustées.
class _CountryHeatmap extends StatelessWidget {
  final List<({String country, int count})> data;

  const _CountryHeatmap({required this.data});

  @override
  Widget build(BuildContext context) {
    final markers = countryMarkers;
    final max = data.fold<int>(0, (m, d) => math.max(m, d.count));
    final circles = [
      for (final d in data.reversed)
        if (markers[d.country] != null)
          CircleMarker(
            point: ll.LatLng(markers[d.country]!.lat, markers[d.country]!.lng),
            radius: 6 + 18 * math.sqrt(d.count / max),
            color: Color.lerp(
              AppColors.gold,
              AppColors.wine,
              d.count / max,
            )!
                .withValues(alpha: 0.75),
            borderColor: Colors.white,
            borderStrokeWidth: 1.5,
          ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: ll.LatLng(30, 10),
                initialZoom: 0.8,
                minZoom: 0.5,
                maxZoom: 6,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bierodex.app',
                ),
                CircleLayer(circles: circles),
              ],
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white70,
                child: const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 10, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  final List<Recommendation> items;

  const _Recommendations({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        context.l10n.statsNoRecommendations,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Card(
      child: Column(
        children: [
          for (final item in items)
            ListTile(
              leading: Icon(
                item.onWishlist ? Icons.bookmark : Icons.recommend_outlined,
                color: findStyleById(item.beer.styleId)?.family.color ??
                    AppColors.copper,
              ),
              title: Text(item.beer.name),
              subtitle: Text(
                '${item.reason}\n${item.beer.brewery} · ${countryName(item.beer.country)}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BeerDetailScreen(beerId: item.beer.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  final List<Achievement> items;

  const _AchievementGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
        return b.ratio.compareTo(a.ratio);
      });
    final textTheme = Theme.of(context).textTheme;
    final outline = Theme.of(context).colorScheme.outline;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 3 : 2;
        final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final a in sorted)
              Container(
                width: width,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (a.unlocked ? a.color : outline).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (a.unlocked ? a.color : outline).withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          a.unlocked ? a.icon : Icons.lock_outline,
                          color: a.unlocked ? a.color : outline,
                          size: 22,
                        ),
                        const Spacer(),
                        Text(
                          a.unlocked
                              ? context.l10n.achievementUnlocked
                              : '${math.min(a.progress, a.target)}/${a.target}',
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(a.title, style: textTheme.labelLarge),
                    const SizedBox(height: 2),
                    Text(a.description, style: textTheme.bodySmall),
                    if (!a.unlocked) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: a.ratio,
                          minHeight: 4,
                          backgroundColor: outline.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation(a.color),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
