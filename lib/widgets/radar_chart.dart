import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/beer_user_status.dart';
import '../l10n/l10n.dart';

/// Axes du profil de dégustation, dans l'ordre du radar.
/// Libellés des axes du radar, dans la langue de l'app.
List<String> get tastingAxes {
  final l10n = L10n.current;
  return [
    l10n.criterionColor,
    l10n.criterionBitterness,
    l10n.criterionSweetness,
    l10n.criterionBody,
    l10n.criterionRating,
  ];
}

/// Valeurs (1 à 5, ou `null` si non renseignées) d'un statut sur
/// [tastingAxes].
List<int?> tastingValues(BeerUserStatus status) => [
      status.color,
      status.bitterness,
      status.sweetness,
      status.body,
      status.rating,
    ];

class RadarSeries {
  final String label;
  final Color color;
  final List<int?> values;

  const RadarSeries({
    required this.label,
    required this.color,
    required this.values,
  });
}

/// Graphique en radar sur une échelle de 0 à 5, une toile par série. Une
/// valeur manquante est dessinée au centre (0) plutôt que d'interrompre la
/// forme.
class RadarChart extends StatelessWidget {
  final List<String> axes;
  final List<RadarSeries> series;
  final double size;

  const RadarChart({
    super.key,
    required this.axes,
    required this.series,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: [
        for (final s in series)
          '${s.label} : ${[
            for (var i = 0; i < axes.length; i++)
              '${axes[i]} ${s.values[i] ?? L10n.current.notSet}'
          ].join(', ')}',
      ].join('. '),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RadarPainter(
            axes: axes,
            series: series,
            gridColor: theme.colorScheme.outline,
            labelStyle: theme.textTheme.labelSmall!,
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<String> axes;
  final List<RadarSeries> series;
  final Color gridColor;
  final TextStyle labelStyle;

  _RadarPainter({
    required this.axes,
    required this.series,
    required this.gridColor,
    required this.labelStyle,
  });

  static const _max = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Marge pour les libellés d'axes autour de la toile.
    final radius = size.shortestSide / 2 - 30;
    Offset pointAt(int axis, double value) {
      final angle = -math.pi / 2 + 2 * math.pi * axis / axes.length;
      return center +
          Offset(math.cos(angle), math.sin(angle)) * radius * value / _max;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var level = 1; level <= _max; level++) {
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final p = pointAt(i, level.toDouble());
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), gridPaint);
    }
    for (var i = 0; i < axes.length; i++) {
      canvas.drawLine(center, pointAt(i, _max.toDouble()), gridPaint);

      final painter = TextPainter(
        text: TextSpan(text: axes[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final anchor = pointAt(i, _max + 0.9);
      painter.paint(
        canvas,
        anchor - Offset(painter.width / 2, painter.height / 2),
      );
    }

    for (final s in series) {
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final p = pointAt(i, (s.values[i] ?? 0).toDouble());
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = s.color.withValues(alpha: 0.22));
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < axes.length; i++) {
        if (s.values[i] == null) continue;
        canvas.drawCircle(
          pointAt(i, s.values[i]!.toDouble()),
          3.5,
          Paint()..color = s.color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => true;
}
