import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Globe stylisé en projection orthographique, centré sur [center] : un
/// quadrillage de méridiens et parallèles, un semis de points discrets pour
/// les brasseries connues (qui dessinent les zones brassicoles), des points
/// dorés pour celles déjà goûtées, et un repère pour la bière mise en avant.
/// Pas de fond de carte : l'image reste légère et identique hors-ligne.
class GlobePainter extends CustomPainter {
  final ({double lat, double lng}) center;
  final ({double lat, double lng})? highlight;
  final List<({double lat, double lng})> knownPoints;
  final List<({double lat, double lng})> triedPoints;

  const GlobePainter({
    required this.center,
    this.highlight,
    this.knownPoints = const [],
    this.triedPoints = const [],
  });

  /// Projette un point ; `null` s'il est sur la face cachée.
  Offset? _project(double lat, double lng, Offset origin, double radius) {
    final phi = lat * math.pi / 180;
    final lambda = lng * math.pi / 180;
    final phi0 = center.lat * math.pi / 180;
    final lambda0 = center.lng * math.pi / 180;
    final cosC = math.sin(phi0) * math.sin(phi) +
        math.cos(phi0) * math.cos(phi) * math.cos(lambda - lambda0);
    if (cosC < 0) return null;
    final x = math.cos(phi) * math.sin(lambda - lambda0);
    final y = math.cos(phi0) * math.sin(phi) -
        math.sin(phi0) * math.cos(phi) * math.cos(lambda - lambda0);
    return origin + Offset(x * radius, -y * radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - 2;
    final origin = size.center(Offset.zero);
    final sphere = Rect.fromCircle(center: origin, radius: radius);

    // Halo cuivré autour de la sphère.
    canvas.drawCircle(
      origin,
      radius + 6,
      Paint()
        ..color = AppColors.copper.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawCircle(
      origin,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.1,
          colors: const [
            Color(0xFF4A3524),
            Color(0xFF241A13),
            Color(0xFF120E0B),
          ],
          stops: const [0, 0.65, 1],
        ).createShader(sphere),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = AppColors.foam.withValues(alpha: 0.13);
    for (var lng = -180; lng < 180; lng += 20) {
      _polyline(canvas, grid, origin, radius, [
        for (var lat = -90; lat <= 90; lat += 3)
          (lat.toDouble(), lng.toDouble()),
      ]);
    }
    for (var lat = -60; lat <= 60; lat += 20) {
      _polyline(canvas, grid, origin, radius, [
        for (var lng = -180; lng <= 180; lng += 3)
          (lat.toDouble(), lng.toDouble()),
      ]);
    }

    final known = Paint()..color = AppColors.foam.withValues(alpha: 0.28);
    for (final p in knownPoints) {
      final o = _project(p.lat, p.lng, origin, radius);
      if (o != null) canvas.drawCircle(o, radius * 0.012, known);
    }
    final tried = Paint()..color = AppColors.gold.withValues(alpha: 0.9);
    for (final p in triedPoints) {
      final o = _project(p.lat, p.lng, origin, radius);
      if (o != null) canvas.drawCircle(o, radius * 0.022, tried);
    }
    canvas.restore();

    // Liseré et reflet.
    canvas.drawCircle(
      origin,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.copper.withValues(alpha: 0.55),
    );

    final h = highlight;
    if (h != null) {
      final o = _project(h.lat, h.lng, origin, radius);
      if (o != null) {
        canvas.drawCircle(
          o,
          radius * 0.11,
          Paint()..color = AppColors.copper.withValues(alpha: 0.25),
        );
        canvas.drawCircle(o, radius * 0.055, Paint()..color = AppColors.copper);
        canvas.drawCircle(
          o,
          radius * 0.055,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.015
            ..color = AppColors.foam,
        );
      }
    }
  }

  void _polyline(
    Canvas canvas,
    Paint paint,
    Offset origin,
    double radius,
    List<(double, double)> points,
  ) {
    final path = Path();
    var drawing = false;
    for (final (lat, lng) in points) {
      final o = _project(lat, lng, origin, radius);
      if (o == null) {
        drawing = false;
        continue;
      }
      if (drawing) {
        path.lineTo(o.dx, o.dy);
      } else {
        path.moveTo(o.dx, o.dy);
        drawing = true;
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GlobePainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.highlight != highlight ||
      oldDelegate.knownPoints.length != knownPoints.length ||
      oldDelegate.triedPoints.length != triedPoints.length;
}
