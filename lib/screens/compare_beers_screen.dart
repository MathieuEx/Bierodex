import 'package:flutter/material.dart';

import '../data/beers.dart';
import '../models/beer.dart';
import '../models/beer_user_status.dart';
import '../services/beer_collection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/radar_chart.dart';
import '../l10n/l10n.dart';

/// Superpose les profils de dégustation de deux bières sur un même radar,
/// avec le détail critère par critère et les arômes communs.
class CompareBeersScreen extends StatefulWidget {
  final String firstId;

  const CompareBeersScreen({super.key, required this.firstId});

  @override
  State<CompareBeersScreen> createState() => _CompareBeersScreenState();
}

class _CompareBeersScreenState extends State<CompareBeersScreen> {
  static const _secondColor = Color(0xFF3F6E8C);

  String? _secondId;

  List<Beer> get _candidates {
    final statuses = BeerCollectionService.instance.statuses;
    return [
      for (final beer in beers)
        if (beer.id != widget.firstId &&
            (statuses[beer.id]?.tried ?? false) &&
            statuses[beer.id]!.hasTastingProfile)
          beer,
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    final service = BeerCollectionService.instance;
    final first = findBeerById(widget.firstId);
    final candidates = _candidates;
    final second = _secondId != null
        ? findBeerById(_secondId!)
        : (candidates.isNotEmpty ? candidates.first : null);
    final textTheme = Theme.of(context).textTheme;

    if (first == null) {
      return Scaffold(body: Center(child: Text(context.l10n.beerNotFound)));
    }
    final firstStatus = service.statusFor(first.id);
    final secondStatus = second != null ? service.statusFor(second.id) : null;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.compare)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Legend(color: AppColors.copper, label: first.name),
          const SizedBox(height: 8),
          if (candidates.isEmpty)
            Text(context.l10n.compareEmpty, style: textTheme.bodyMedium)
          else
            DropdownButtonFormField<String>(
              initialValue: second?.id,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.compareWith),
              items: [
                for (final beer in candidates)
                  DropdownMenuItem(
                    value: beer.id,
                    child: Text(beer.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) => setState(() => _secondId = id),
            ),
          const SizedBox(height: 16),
          Center(
            child: RadarChart(
              size: 300,
              axes: tastingAxes,
              series: [
                RadarSeries(
                  label: first.name,
                  color: AppColors.copper,
                  values: tastingValues(firstStatus),
                ),
                if (second != null && secondStatus != null)
                  RadarSeries(
                    label: second.name,
                    color: _secondColor,
                    values: tastingValues(secondStatus),
                  ),
              ],
            ),
          ),
          if (second != null && secondStatus != null) ...[
            const SizedBox(height: 16),
            _Legend(color: _secondColor, label: second.name),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    for (var i = 0; i < tastingAxes.length; i++)
                      ListTile(
                        dense: true,
                        title: Text(tastingAxes[i]),
                        trailing: Text(
                          '${_format(tastingValues(firstStatus)[i])}'
                          '  ·  ${_format(tastingValues(secondStatus)[i])}',
                          style: textTheme.labelLarge,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AromaComparison(first: firstStatus, second: secondStatus),
          ],
        ],
      ),
    );
  }

  static String _format(int? value) => value == null ? '–' : '$value/5';
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class _AromaComparison extends StatelessWidget {
  final BeerUserStatus first;
  final BeerUserStatus second;

  const _AromaComparison({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    final common = first.aromas.where(second.aromas.contains).toList();
    if (first.aromas.isEmpty && second.aromas.isEmpty) {
      return const SizedBox.shrink();
    }
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.commonAromas, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (common.isEmpty)
          Text(context.l10n.noCommonAromas, style: textTheme.bodyMedium)
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final aroma in common)
                Chip(label: Text(tastingAromas[aroma]!)),
            ],
          ),
      ],
    );
  }
}
