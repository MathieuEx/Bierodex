import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Repère "tampon de brasseur" utilisé sur la carte détaillée d'un pays :
/// le logo de la brasserie quand on en a un, sinon un monogramme (première
/// lettre du nom) sur un badge cuivré. La pointe basse du widget correspond
/// aux coordonnées géographiques (utiliser `Alignment.bottomCenter` comme
/// ancrage du [Marker]).
class BreweryPin extends StatelessWidget {
  static const double width = 34;
  static const double height = 44;

  final String breweryName;
  final String? logoUrl;

  const BreweryPin({super.key, required this.breweryName, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 23,
            child: Transform.rotate(
              angle: 0.785398, // 45°
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.copper,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: logoUrl != null ? AppColors.parchment : AppColors.copper,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.parchment, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: logoUrl != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.network(
                        logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => _Monogram(
                          breweryName: breweryName,
                        ),
                      ),
                    )
                  : _Monogram(breweryName: breweryName),
            ),
          ),
        ],
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  final String breweryName;

  const _Monogram({required this.breweryName});

  @override
  Widget build(BuildContext context) {
    final letter = breweryName.trim().isNotEmpty
        ? breweryName.trim()[0].toUpperCase()
        : '?';
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontFamily: 'BigShouldersDisplay',
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: AppColors.parchment,
          height: 1,
        ),
      ),
    );
  }
}
