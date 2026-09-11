import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../data/beers.dart';
import '../data/brewery_locations.dart';
import '../widgets/brewery_beers_sheet.dart';
import '../widgets/brewery_pin.dart';

/// Carte détaillée (tuiles OpenStreetMap) centrée sur un pays, avec un
/// repère précis par brasserie connue. Ouverte depuis le marqueur pays du
/// globe pour voir "de plus près" les brasseries qu'il regroupe.
class CountryMapScreen extends StatefulWidget {
  final String country;

  const CountryMapScreen({super.key, required this.country});

  @override
  State<CountryMapScreen> createState() => _CountryMapScreenState();
}

class _CountryMapScreenState extends State<CountryMapScreen> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final breweries = breweriesForCountry(widget.country);
    final points = <String, ll.LatLng>{
      for (final brewery in breweries)
        if (breweryLocations[brewery] != null)
          brewery: ll.LatLng(
            breweryLocations[brewery]!.lat,
            breweryLocations[brewery]!.lng,
          ),
    };

    final bounds = points.isEmpty
        ? null
        : LatLngBounds.fromPoints(points.values.toList());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.country),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                '${points.length} brasserie${points.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: points.isEmpty
          ? Center(
              child: Text(
                'Aucune brasserie localisée pour ${widget.country}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCameraFit: bounds != null
                    ? CameraFit.bounds(
                        bounds: bounds,
                        padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                        maxZoom: 12,
                      )
                    : null,
                initialCenter: points.values.first,
                initialZoom: 10,
                minZoom: 3,
                maxZoom: 17,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bierodex.app',
                ),
                MarkerLayer(
                  markers: [
                    for (final entry in points.entries)
                      Marker(
                        point: entry.value,
                        width: BreweryPin.width,
                        height: BreweryPin.height,
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () => showBreweryBeersSheet(
                            context,
                            entry.key,
                            breweryLocations[entry.key]!,
                          ),
                          child: BreweryPin(
                            breweryName: entry.key,
                            logoUrl: breweryLocations[entry.key]!.logoUrl,
                          ),
                        ),
                      ),
                  ],
                ),
                const _AttributionOverlay(),
              ],
            ),
    );
  }
}

class _AttributionOverlay extends StatelessWidget {
  const _AttributionOverlay();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        color: Colors.white70,
        child: const Text(
          '© OpenStreetMap contributors',
          style: TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ),
    );
  }
}
