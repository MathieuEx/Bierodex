import 'dart:math';

import '../models/beer_user_status.dart';

enum ReminderKind { inactivity, wishlist }

/// Un rappel à programmer. [beerId] vaut la bière de la wishlist concernée
/// ; [idleDays] le nombre de jours sans dégustation au moment où le rappel
/// s'affiche.
class PlannedReminder {
  final ReminderKind kind;
  final DateTime at;
  final String? beerId;
  final int? idleDays;

  const PlannedReminder({
    required this.kind,
    required this.at,
    this.beerId,
    this.idleDays,
  });
}

/// Calcule les rappels à partir de la collection, sans rien programmer
/// (voir `NotificationService`). Tout est recalculé à chaque changement :
/// une dégustation repousse d'elle-même le rappel d'inactivité.
class ReminderPlanner {
  /// Délai sans dégustation avant le rappel « rien goûté depuis un mois ».
  static const inactivityDelay = Duration(days: 30);

  /// Si ce délai est déjà dépassé, le rappel est reporté d'autant à chaque
  /// ouverture de l'app : il ne s'affiche que si elle reste fermée.
  static const inactivitySnooze = Duration(days: 7);

  /// Intervalle entre deux rappels de la wishlist.
  static const wishlistInterval = Duration(days: 14);

  /// Heure d'envoi : en fin de journée, quand on pense à une bière.
  static const hour = 18;

  static PlannedReminder? inactivity(
    Map<String, BeerUserStatus> statuses,
    DateTime now,
  ) {
    DateTime? last;
    for (final status in statuses.values) {
      final date = status.triedAt;
      if (!status.tried || date == null) continue;
      if (last == null || date.isAfter(last)) last = date;
    }
    if (last == null) return null;

    var at = _atHour(last.add(inactivityDelay));
    if (!at.isAfter(now)) at = _atHour(now.add(inactivitySnooze));
    return PlannedReminder(
      kind: ReminderKind.inactivity,
      at: at,
      idleDays: at.difference(last).inDays,
    );
  }

  /// [nextAt] : date déjà choisie pour le prochain rappel (conservée d'une
  /// ouverture à l'autre pour ne pas repousser le rappel indéfiniment), ou
  /// `null`. La bière est tirée au sort, de façon stable pour une date donnée.
  static PlannedReminder? wishlist(
    Map<String, BeerUserStatus> statuses,
    DateTime now, {
    DateTime? nextAt,
  }) {
    final ids = [
      for (final entry in statuses.entries)
        if (entry.value.wishlist) entry.key,
    ]..sort();
    if (ids.isEmpty) return null;

    final at = nextAt != null && nextAt.isAfter(now)
        ? nextAt
        : _atHour(now.add(wishlistInterval));
    final beerId = ids[Random(at.millisecondsSinceEpoch).nextInt(ids.length)];
    return PlannedReminder(kind: ReminderKind.wishlist, at: at, beerId: beerId);
  }

  static DateTime _atHour(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour);
}
