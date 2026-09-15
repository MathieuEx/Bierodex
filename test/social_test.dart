import 'package:bierodex/data/beers.dart' as beers_data;
import 'package:bierodex/l10n/l10n.dart';
import 'package:bierodex/models/beer.dart';
import 'package:bierodex/models/beer_user_status.dart';
import 'package:bierodex/models/social.dart';
import 'package:bierodex/services/social_service.dart';
import 'package:bierodex/services/submission_service.dart';
import 'package:bierodex/widgets/tasting_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pseudo', () {
    test('normalizeUsername retire espaces, @ et majuscules', () {
      expect(SocialService.normalizeUsername('  @Mathieu_42 '), 'mathieu_42');
    });

    test('usernameProblem suit la contrainte serveur', () {
      expect(SocialService.usernameProblem('abc'), isNull);
      expect(SocialService.usernameProblem('a_b_1234567890123456'), isNull);
      expect(SocialService.usernameProblem('ab'), isNotNull);
      expect(SocialService.usernameProblem('a' * 21), isNotNull);
      expect(SocialService.usernameProblem('jean-luc'), isNotNull);
      expect(SocialService.usernameProblem('élodie'), isNotNull);
    });
  });

  test('les erreurs serveur sont traduites', () {
    expect(
      SocialService.messageFor('23505', 'duplicate key'),
      'Ce pseudo est déjà pris.',
    );
    expect(
      SocialService.messageFor('P0001', 'profile_not_found'),
      contains('Aucun profil'),
    );
    expect(
      SubmissionService.messageFor('already_in_catalog'),
      contains('code-barres'),
    );
    expect(SocialService.messageFor(null, 'boom'), contains('erreur'));
  });

  test('SharedProfile.fromJson ne garde que statut, note et date', () {
    final profile = SharedProfile.fromJson({
      'username': 'amie',
      'display_name': null,
      'visibility': 'friends',
      'is_self': false,
      'entries': [
        {
          'beer_id': 'orval',
          'tried': true,
          'wishlist': false,
          'rating': 5,
          'tried_at': '2026-09-01T18:00:00Z',
        },
        {'beer_id': 'custom-1', 'tried': false, 'wishlist': true},
      ],
      'custom_beers': [
        {
          'id': 'custom-1',
          'name': 'Brassin maison',
          'brewery': 'Garage',
          'country': 'France',
          'style_id': 'saison',
          'abv': 6,
          'description': '',
        },
      ],
    });

    expect(profile.label, '@amie');
    expect(profile.visibility, ProfileVisibility.friends);
    expect(profile.statuses['orval']!.rating, 5);
    expect(profile.statuses['orval']!.note, isNull);
    expect(profile.statuses['custom-1']!.wishlist, isTrue);
    expect(profile.customBeers['custom-1']!.isCustom, isTrue);
  });

  test('une visibilité inconnue retombe sur privé', () {
    expect(ProfileVisibility.fromValue('everyone'), ProfileVisibility.private);
  });

  testWidgets('la carte de dégustation se rend sans brasserie localisée', (
    tester,
  ) async {
    const beer = Beer(
      id: 'test',
      name: 'Une bière au nom vraiment très long',
      brewery: 'Brasserie',
      country: 'Belgique',
      styleId: 'inconnu',
      abv: 6.2,
      description: '',
    );
    beers_data.beers = const [beer];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: TastingShareCard(
            beer: beer,
            status: BeerUserStatus(
              tried: true,
              rating: 4,
              triedAt: DateTime(2026, 9, 15),
              aromas: const ['agrumes', 'miel'],
            ),
            username: 'mathieu',
            triedBreweries: triedBreweriesFrom(['test']),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Dégustée le 15/09/2026'), findsOneWidget);
    expect(find.text('@mathieu'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
  });
}
