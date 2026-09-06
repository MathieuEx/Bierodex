import 'package:flutter/material.dart';
import 'package:interactive_world_map/interactive_world_map.dart';

import '../data/country_iso.dart';
import 'country_group_detail_screen.dart';

class WorldMapTab extends StatefulWidget {
  const WorldMapTab({super.key});

  @override
  State<WorldMapTab> createState() => _WorldMapTabState();
}

class _WorldMapTabState extends State<WorldMapTab> {
  final _controller = WorldMapController();

  static const _continents = <String, UnRegion>{
    'Europe': UnRegion.europe,
    'Asie': UnRegion.asia,
    'Amériques': UnRegion.americas,
    'Afrique': UnRegion.africa,
    'Océanie': UnRegion.oceania,
  };

  @override
  void initState() {
    super.initState();
    _controller.highlightedIds = allDataMapIds;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToRegion(UnRegion region) {
    _controller.fitToCountries(
      region.mapIds(),
      options: const FitOptions(
        padding: 24,
        duration: Duration(milliseconds: 500),
        excludeRemoteIslands: true,
      ),
    );
  }

  void _resetToWorld() {
    _controller.transformationController.value = Matrix4.identity();
  }

  void _onCountryTap(String mapId) {
    final countries = mapIdToCountryNames[mapId];
    if (countries == null || countries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune bière référencée pour ce pays pour le moment.'),
        ),
      );
      return;
    }

    _controller.fitToCountries(
      {mapId},
      options: const FitOptions(
        padding: 40,
        duration: Duration(milliseconds: 450),
        excludeRemoteIslands: true,
      ),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CountryGroupDetailScreen(
            title: countries.join(' / '),
            countries: countries,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Touche un pays en bleu pour voir ses bières. Les continents '
            'ci-dessous zooment directement sur la région.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ActionChip(
                avatar: const Icon(Icons.public, size: 18),
                label: const Text('Monde'),
                onPressed: _resetToWorld,
              ),
              const SizedBox(width: 8),
              for (final entry in _continents.entries) ...[
                ActionChip(
                  label: Text(entry.key),
                  onPressed: () => _goToRegion(entry.value),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: InteractiveWorldMap(
            controller: _controller,
            selectOnTap: true,
            toggleSelectionOnTap: true,
            onCountryTap: _onCountryTap,
            style: WorldMapStyle(
              landFillColor: scheme.surfaceContainerHighest,
              highlightedFillColor: scheme.primary.withValues(alpha: 0.55),
              selectedFillColor: scheme.primary,
              borderColor: scheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}
