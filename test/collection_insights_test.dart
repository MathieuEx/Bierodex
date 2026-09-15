import 'package:bierodex/models/beer.dart';
import 'package:bierodex/models/beer_style.dart';
import 'package:bierodex/models/beer_user_status.dart';
import 'package:bierodex/services/collection_insights.dart';
import 'package:flutter_test/flutter_test.dart';

const _styles = {
  'ipa': BeerStyle(
    id: 'ipa',
    name: 'IPA',
    family: BeerFamily.aleHaute,
    origin: 'Royaume-Uni',
    abvRange: '',
    description: '',
  ),
  'stout': BeerStyle(
    id: 'stout',
    name: 'Stout',
    family: BeerFamily.aleHaute,
    origin: 'Irlande',
    abvRange: '',
    description: '',
  ),
  'pils': BeerStyle(
    id: 'pils',
    name: 'Pilsner',
    family: BeerFamily.lagerBasse,
    origin: 'République tchèque',
    abvRange: '',
    description: '',
  ),
  'lambic': BeerStyle(
    id: 'lambic',
    name: 'Lambic',
    family: BeerFamily.spontanee,
    origin: 'Belgique',
    abvRange: '',
    description: '',
  ),
};

Beer _beer(String id, String styleId, {String country = 'France'}) => Beer(
      id: id,
      name: id,
      brewery: 'Brasserie $id',
      country: country,
      styleId: styleId,
      abv: 5,
      description: '',
    );

CollectionInsights _insights(
  List<Beer> catalog,
  Map<String, BeerUserStatus> statuses,
) =>
    CollectionInsights(
      catalog: catalog,
      statuses: statuses,
      styleOf: (id) => _styles[id],
    );

BeerUserStatus _tried({int? rating, DateTime? at}) =>
    BeerUserStatus(tried: true, rating: rating, triedAt: at);

void main() {
  group('statistiques', () {
    test('compte par style, famille et pays, en ignorant les non-bues', () {
      final insights = _insights(
        [
          _beer('a', 'ipa', country: 'Belgique'),
          _beer('b', 'ipa'),
          _beer('c', 'pils'),
          _beer('d', 'stout'),
        ],
        {
          'a': _tried(),
          'b': _tried(),
          'c': _tried(),
          'd': const BeerUserStatus(wishlist: true),
        },
      );

      expect(insights.countByStyle.first.style.id, 'ipa');
      expect(insights.countByStyle.first.count, 2);
      expect(insights.countByFamily[BeerFamily.aleHaute], 2);
      expect(insights.countByFamily[BeerFamily.lagerBasse], 1);
      expect(insights.countByFamily[BeerFamily.spontanee], 0);
      expect(insights.countByCountry.first, (country: 'France', count: 2));
    });

    test('note moyenne par style, de la meilleure à la moins bonne', () {
      final insights = _insights(
        [_beer('a', 'ipa'), _beer('b', 'ipa'), _beer('c', 'pils')],
        {
          'a': _tried(rating: 5),
          'b': _tried(rating: 4),
          'c': _tried(rating: 2),
        },
      );

      final averages = insights.averageByStyle;
      expect(averages.map((s) => s.style.id), ['ipa', 'pils']);
      expect(averages.first.average, 4.5);
      expect(averages.first.count, 2);
    });

    test('dégustations par mois sur une fenêtre glissante', () {
      final insights = _insights(
        [_beer('a', 'ipa'), _beer('b', 'ipa'), _beer('c', 'ipa')],
        {
          'a': _tried(at: DateTime(2026, 9, 3)),
          'b': _tried(at: DateTime(2026, 9, 20)),
          'c': _tried(at: DateTime(2025, 1, 1)), // hors fenêtre
        },
      );

      final months = insights.monthlyTastings(now: DateTime(2026, 9, 15));
      expect(months, hasLength(12));
      expect(months.first.month, DateTime(2025, 10));
      expect(months.last, (month: DateTime(2026, 9), count: 2));
      expect(months.fold<int>(0, (sum, m) => sum + m.count), 2);
    });
  });

  group('badges', () {
    Achievement byId(CollectionInsights insights, String id) =>
        insights.achievements.firstWhere((a) => a.id == id);

    test('Tour d\'Europe : 10 pays européens distincts', () {
      const european = [
        'France',
        'Belgique',
        'Allemagne',
        'Irlande',
        'Pays-Bas',
        'Espagne',
        'Italie',
        'Pologne',
        'Danemark',
        'Écosse',
      ];
      final catalog = [
        for (final country in european)
          _beer(country, 'pils', country: country),
        _beer('usa', 'ipa', country: 'États-Unis'),
      ];

      final nine = _insights(catalog, {
        for (final country in european.take(9)) country: _tried(),
        'usa': _tried(),
      });
      expect(byId(nine, 'europe_tour').progress, 9);
      expect(byId(nine, 'europe_tour').unlocked, isFalse);

      final ten = _insights(catalog, {
        for (final country in european) country: _tried(),
      });
      expect(byId(ten, 'europe_tour').unlocked, isTrue);
    });

    test('Explorateur des fermentations spontanées : 3 bières', () {
      final catalog = [for (var i = 0; i < 3; i++) _beer('l$i', 'lambic')];
      final insights = _insights(catalog, {
        for (final beer in catalog) beer.id: _tried(),
      });
      expect(byId(insights, 'spontaneous_explorer').unlocked, isTrue);
      expect(byId(insights, 'four_families').progress, 1);
    });

    test('série mensuelle : mois consécutifs, même à cheval sur l\'année', () {
      final insights = _insights(
        [for (var i = 0; i < 5; i++) _beer('b$i', 'ipa')],
        {
          'b0': _tried(at: DateTime(2025, 11, 2)),
          'b1': _tried(at: DateTime(2025, 12, 28)),
          'b2': _tried(at: DateTime(2026, 1, 5)),
          'b3': _tried(at: DateTime(2026, 1, 20)), // même mois
          'b4': _tried(at: DateTime(2026, 4, 1)), // série rompue
        },
      );
      expect(insights.longestMonthlyStreak, 3);
      expect(byId(insights, 'streak_3_months').unlocked, isTrue);
      expect(byId(insights, 'streak_6_months').unlocked, isFalse);
    });
  });

  group('recommandations', () {
    test('propose des bières non goûtées des styles les mieux notés', () {
      final insights = _insights(
        [
          _beer('ipa-1', 'ipa'),
          _beer('ipa-2', 'ipa'),
          _beer('ipa-3', 'ipa'),
          _beer('pils-1', 'pils'),
          _beer('pils-2', 'pils'),
        ],
        {
          'ipa-1': _tried(rating: 5),
          'pils-1': _tried(rating: 2),
          'ipa-3': const BeerUserStatus(wishlist: true),
        },
      );

      final recommendations = insights.recommendations();
      expect(recommendations.map((r) => r.beer.id), ['ipa-3', 'ipa-2']);
      expect(recommendations.first.onWishlist, isTrue);
      expect(recommendations.first.reason, contains('IPA'));
    });

    test(
      'se rabat sur la famille appréciée, sans repêcher un style détesté',
      () {
        final insights = _insights(
          [
            _beer('ipa-1', 'ipa'),
            _beer('stout-1', 'stout'),
            _beer('pils-1', 'pils'),
          ],
          {'ipa-1': _tried(rating: 4)},
        );

        final ids = insights.recommendations().map((r) => r.beer.id);
        expect(ids, ['stout-1']);
      },
    );

    test('aucune recommandation sans note', () {
      final insights = _insights(
        [_beer('a', 'ipa'), _beer('b', 'ipa')],
        {'a': _tried()},
      );
      expect(insights.recommendations(), isEmpty);
    });

    test('limite le nombre de bières par style', () {
      final catalog = [for (var i = 0; i < 6; i++) _beer('ipa-$i', 'ipa')];
      final insights = _insights(catalog, {'ipa-0': _tried(rating: 5)});
      expect(insights.recommendations(perStyle: 3), hasLength(3));
    });
  });

  test('BeerUserStatus : aller-retour JSON et ligne Supabase', () {
    final status = BeerUserStatus(
      tried: true,
      rating: 4,
      triedAt: DateTime.utc(2026, 9, 1),
      color: 3,
      bitterness: 5,
      sweetness: 1,
      body: 2,
      aromas: const ['agrumes', 'resineux'],
      photoPath: 'user/beer.jpg',
    );

    final fromJson = BeerUserStatus.fromJson(status.toJson());
    final fromRow = BeerUserStatus.fromRow(
      status.toRow(userId: 'user', beerId: 'beer'),
    );
    for (final copy in [fromJson, fromRow]) {
      expect(copy.color, 3);
      expect(copy.bitterness, 5);
      expect(copy.aromas, ['agrumes', 'resineux']);
      expect(copy.photoPath, 'user/beer.jpg');
      expect(copy.hasTastingProfile, isTrue);
    }

    final unknownAroma = BeerUserStatus.fromJson({
      'tried': true,
      'aromas': ['agrumes', 'inconnu', 42],
    });
    expect(unknownAroma.aromas, ['agrumes']);
  });
}
