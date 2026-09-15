import 'package:flutter/material.dart';

import '../data/countries.dart';
import '../models/beer.dart';
import '../models/beer_style.dart';
import '../models/beer_user_status.dart';
import '../l10n/l10n.dart';

/// Une bière dégustée et son statut, la brique de base de tous les calculs
/// ci-dessous.
typedef TastedBeer = ({Beer beer, BeerUserStatus status});

/// Statistiques, badges et recommandations, dérivés du catalogue et de la
/// collection. Fonctions pures, sans lecture des singletons : l'écran leur
/// passe `beers`, `BeerCollectionService.statuses` et `findStyleById`, et
/// les tests leurs propres données.
class CollectionInsights {
  final List<Beer> catalog;
  final Map<String, BeerUserStatus> statuses;
  final BeerStyle? Function(String styleId) styleOf;

  /// Bières dégustées présentes dans le catalogue (une bière personnelle
  /// supprimée depuis n'apparaît plus nulle part).
  late final List<TastedBeer> tasted = [
    for (final beer in catalog)
      if (statuses[beer.id]?.tried ?? false)
        (beer: beer, status: statuses[beer.id]!),
  ];

  CollectionInsights({
    required this.catalog,
    required this.statuses,
    required this.styleOf,
  });

  // -------------------------------------------------------------------------
  // Statistiques
  // -------------------------------------------------------------------------

  /// Nombre de bières dégustées par style, du plus fréquent au plus rare.
  List<({BeerStyle style, int count})> get countByStyle {
    final counts = <String, int>{};
    for (final t in tasted) {
      counts.update(t.beer.styleId, (c) => c + 1, ifAbsent: () => 1);
    }
    return [
      for (final entry in counts.entries)
        if (styleOf(entry.key) != null)
          (style: styleOf(entry.key)!, count: entry.value),
    ]..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.style.name.compareTo(b.style.name);
    });
  }

  Map<BeerFamily, int> get countByFamily {
    final counts = {for (final family in BeerFamily.values) family: 0};
    for (final t in tasted) {
      final family = styleOf(t.beer.styleId)?.family;
      if (family != null) counts[family] = counts[family]! + 1;
    }
    return counts;
  }

  /// Nombre de bières dégustées par pays, du plus fréquent au plus rare.
  List<({String country, int count})> get countByCountry {
    final counts = <String, int>{};
    for (final t in tasted) {
      counts.update(t.beer.country, (c) => c + 1, ifAbsent: () => 1);
    }
    return [
      for (final entry in counts.entries)
        (country: entry.key, count: entry.value),
    ]..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.country.compareTo(b.country);
    });
  }

  /// Note moyenne par style (uniquement les styles ayant au moins une bière
  /// notée), de la meilleure à la moins bonne.
  List<({BeerStyle style, double average, int count})> get averageByStyle {
    final ratings = <String, List<int>>{};
    for (final t in tasted) {
      final rating = t.status.rating;
      if (rating == null) continue;
      ratings.putIfAbsent(t.beer.styleId, () => []).add(rating);
    }
    return [
      for (final entry in ratings.entries)
        if (styleOf(entry.key) != null)
          (
            style: styleOf(entry.key)!,
            average: _mean(entry.value),
            count: entry.value.length,
          ),
    ]..sort((a, b) {
      final byAverage = b.average.compareTo(a.average);
      return byAverage != 0 ? byAverage : b.count.compareTo(a.count);
    });
  }

  /// Dégustations par mois sur les [months] derniers mois (le mois courant
  /// inclus), du plus ancien au plus récent.
  List<({DateTime month, int count})> monthlyTastings({
    required DateTime now,
    int months = 12,
  }) {
    final start = DateTime(now.year, now.month - months + 1);
    final counts = List.filled(months, 0);
    for (final t in tasted) {
      final date = t.status.triedAt;
      if (date == null) continue;
      final index = (date.year - start.year) * 12 + date.month - start.month;
      if (index >= 0 && index < months) counts[index]++;
    }
    return [
      for (var i = 0; i < months; i++)
        (month: DateTime(start.year, start.month + i), count: counts[i]),
    ];
  }

  // -------------------------------------------------------------------------
  // Badges
  // -------------------------------------------------------------------------

  List<Achievement> get achievements {
    final countries = {for (final t in tasted) t.beer.country};
    final europeanCountries = countries
        .where((c) => countryContinents[c] == 'Europe')
        .length;
    final continents = {
      for (final c in countries)
        if (countryContinents[c] != null) countryContinents[c]!,
    };
    final families = countByFamily;
    final styles = {for (final t in tasted) t.beer.styleId};
    final streak = longestMonthlyStreak;
    final detailed = tasted.where((t) => t.status.hasTastingProfile).length;
    final photos = tasted.where((t) => t.status.photoPath != null).length;
    final l10n = L10n.current;

    return [
      Achievement(
        id: 'first_tasting',
        title: l10n.achievementFirstTastingTitle,
        description: l10n.achievementFirstTastingDescription,
        icon: Icons.sports_bar,
        color: const Color(0xFFF28A17),
        progress: tasted.length,
        target: 1,
      ),
      Achievement(
        id: 'tasted_10',
        title: l10n.achievementTasted10Title,
        description: l10n.achievementTasted10Description,
        icon: Icons.menu_book_outlined,
        color: const Color(0xFFF28A17),
        progress: tasted.length,
        target: 10,
      ),
      Achievement(
        id: 'tasted_25',
        title: l10n.achievementTasted25Title,
        description: l10n.achievementTasted25Description,
        icon: Icons.auto_stories_outlined,
        color: const Color(0xFFFDB602),
        progress: tasted.length,
        target: 25,
      ),
      Achievement(
        id: 'tasted_50',
        title: l10n.achievementTasted50Title,
        description: l10n.achievementTasted50Description,
        icon: Icons.workspace_premium_outlined,
        color: const Color(0xFFFDB602),
        progress: tasted.length,
        target: 50,
      ),
      Achievement(
        id: 'styles_10',
        title: l10n.achievementStyles10Title,
        description: l10n.achievementStyles10Description,
        icon: Icons.palette_outlined,
        color: const Color(0xFF6B4226),
        progress: styles.length,
        target: 10,
      ),
      Achievement(
        id: 'europe_tour',
        title: l10n.achievementEuropeTourTitle,
        description: l10n.achievementEuropeTourDescription,
        icon: Icons.castle_outlined,
        color: const Color(0xFF3F6E8C),
        progress: europeanCountries,
        target: 10,
      ),
      Achievement(
        id: 'world_tour',
        title: l10n.achievementWorldTourTitle,
        description: l10n.achievementWorldTourDescription,
        icon: Icons.public,
        color: const Color(0xFF3F7D4C),
        progress: continents.length,
        target: 5,
      ),
      Achievement(
        id: 'spontaneous_explorer',
        title: l10n.achievementSpontaneousTitle,
        description: l10n.achievementSpontaneousDescription,
        icon: Icons.bubble_chart_outlined,
        color: const Color(0xFF8B3A3A),
        progress: families[BeerFamily.spontanee]!,
        target: 3,
      ),
      Achievement(
        id: 'four_families',
        title: l10n.achievementFourFamiliesTitle,
        description: l10n.achievementFourFamiliesDescription,
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFF8B3A3A),
        progress: families.values.where((count) => count > 0).length,
        target: BeerFamily.values.length,
      ),
      // Des séries en mois plutôt qu'en jours : l'app récompense la
      // curiosité sur la durée, pas la fréquence de consommation.
      Achievement(
        id: 'streak_3_months',
        title: l10n.achievementStreak3Title,
        description: l10n.achievementStreak3Description,
        icon: Icons.calendar_month_outlined,
        color: const Color(0xFF5B4E3F),
        progress: streak,
        target: 3,
      ),
      Achievement(
        id: 'streak_6_months',
        title: l10n.achievementStreak6Title,
        description: l10n.achievementStreak6Description,
        icon: Icons.event_repeat_outlined,
        color: const Color(0xFF5B4E3F),
        progress: streak,
        target: 6,
      ),
      Achievement(
        id: 'detailed_5',
        title: l10n.achievementDetailed5Title,
        description: l10n.achievementDetailed5Description,
        icon: Icons.radar,
        color: const Color(0xFFF28A17),
        progress: detailed,
        target: 5,
      ),
      Achievement(
        id: 'photos_5',
        title: l10n.achievementPhotos5Title,
        description: l10n.achievementPhotos5Description,
        icon: Icons.photo_camera_outlined,
        color: const Color(0xFF6B4226),
        progress: photos,
        target: 5,
      ),
    ];
  }

  /// Plus longue suite de mois calendaires consécutifs comptant chacun au
  /// moins une dégustation datée.
  int get longestMonthlyStreak {
    final months = <int>{
      for (final t in tasted)
        if (t.status.triedAt != null)
          t.status.triedAt!.year * 12 + t.status.triedAt!.month,
    }.toList()..sort();
    var best = 0;
    var current = 0;
    for (var i = 0; i < months.length; i++) {
      current = (i > 0 && months[i] == months[i - 1] + 1) ? current + 1 : 1;
      if (current > best) best = current;
    }
    return best;
  }

  // -------------------------------------------------------------------------
  // Recommandations
  // -------------------------------------------------------------------------

  /// Moyenne à partir de laquelle un style ou une famille est considéré
  /// comme apprécié.
  static const likedThreshold = 3.5;

  /// Bières pas encore goûtées, choisies d'après les styles les mieux notés
  /// (puis, à défaut, les familles de fermentation appréciées). Au plus
  /// [perStyle] bières par style pour garder de la variété ; les bières
  /// déjà mises « à goûter » passent devant à score égal.
  List<Recommendation> recommendations({int limit = 10, int perStyle = 3}) {
    final styleAverages = {for (final s in averageByStyle) s.style.id: s};

    final familyRatings = <BeerFamily, List<int>>{};
    for (final t in tasted) {
      final family = styleOf(t.beer.styleId)?.family;
      final rating = t.status.rating;
      if (family == null || rating == null) continue;
      familyRatings.putIfAbsent(family, () => []).add(rating);
    }
    final familyAverages = {
      for (final entry in familyRatings.entries) entry.key: _mean(entry.value),
    };

    final candidates = <Recommendation>[];
    for (final beer in catalog) {
      final status = statuses[beer.id];
      if (status?.tried ?? false) continue;
      final style = styleOf(beer.styleId);
      if (style == null) continue;
      final onWishlist = status?.wishlist ?? false;
      final wishlistBonus = onWishlist ? 0.25 : 0.0;

      final styleAverage = styleAverages[style.id];
      if (styleAverage != null) {
        // Un style mal noté n'est pas repêché par sa famille.
        if (styleAverage.average < likedThreshold) continue;
        candidates.add(
          Recommendation(
            beer: beer,
            reason: L10n.current.recommendationLikedStyle(
              style.name,
              formatDecimal(styleAverage.average),
            ),
            score: 1 + styleAverage.average + wishlistBonus,
            onWishlist: onWishlist,
          ),
        );
        continue;
      }

      final familyAverage = familyAverages[style.family];
      if (familyAverage != null && familyAverage >= likedThreshold) {
        candidates.add(
          Recommendation(
            beer: beer,
            reason: L10n.current.recommendationLikedFamily(
              style.family.label.toLowerCase(),
              style.name,
            ),
            score: familyAverage + wishlistBonus,
            onWishlist: onWishlist,
          ),
        );
      }
    }

    candidates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.beer.name.compareTo(b.beer.name);
    });

    final perStyleCount = <String, int>{};
    final result = <Recommendation>[];
    for (final candidate in candidates) {
      final count = perStyleCount[candidate.beer.styleId] ?? 0;
      if (count >= perStyle) continue;
      perStyleCount[candidate.beer.styleId] = count + 1;
      result.add(candidate);
      if (result.length >= limit) break;
    }
    return result;
  }

  static double _mean(List<int> values) =>
      values.reduce((a, b) => a + b) / values.length;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.progress,
    required this.target,
  });

  bool get unlocked => progress >= target;

  double get ratio => (progress / target).clamp(0, 1).toDouble();
}

class Recommendation {
  final Beer beer;
  final String reason;
  final double score;
  final bool onWishlist;

  const Recommendation({
    required this.beer,
    required this.reason,
    required this.score,
    required this.onWishlist,
  });
}
