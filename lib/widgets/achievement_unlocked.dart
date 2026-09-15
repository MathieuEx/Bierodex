import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/collection_insights.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';

/// Célèbre un badge qui vient d'être débloqué : le médaillon arrive en
/// rebondissant, entouré d'un halo qui pulse et d'éclats qui s'écartent.
Future<void> showAchievementUnlocked(
  BuildContext context,
  Achievement achievement,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).closeButtonLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, __) =>
        _AchievementUnlockedDialog(achievement: achievement),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;

  const _AchievementUnlockedDialog({required this.achievement});

  @override
  State<_AchievementUnlockedDialog> createState() =>
      _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<_AchievementUnlockedDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final AnimationController _halo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _entrance.dispose();
    _halo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;
    final textTheme = Theme.of(context).textTheme;
    final medalScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.6, curve: Curves.elasticOut),
    );
    final burst = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.15, 1, curve: Curves.easeOutCubic),
    );
    final textFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.achievementUnlockedTitle.toUpperCase(),
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_entrance, _halo]),
                  builder: (context, _) => CustomPaint(
                    painter: _BurstPainter(
                      progress: burst.value,
                      color: achievement.color,
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: medalScale.value,
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: achievement.color,
                            border: Border.all(color: AppColors.gold, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: achievement.color.withValues(
                                  alpha: 0.35 + 0.25 * _halo.value,
                                ),
                                blurRadius: 18 + 16 * _halo.value,
                                spreadRadius: 2 + 6 * _halo.value,
                              ),
                            ],
                          ),
                          child: Icon(
                            achievement.icon,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: textFade,
                child: Column(
                  children: [
                    Text(
                      achievement.title,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      achievement.description,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.cheers),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Éclats qui partent du centre puis s'estompent.
class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _BurstPainter({required this.progress, required this.color});

  static const _rays = 14;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    for (var i = 0; i < _rays; i++) {
      final angle = 2 * math.pi * i / _rays;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final distance = 56 + (maxRadius - 56) * progress;
      final paint = Paint()
        ..color = (i.isEven ? color : AppColors.gold).withValues(alpha: opacity)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + direction * (distance - 12),
        center + direction * distance,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
