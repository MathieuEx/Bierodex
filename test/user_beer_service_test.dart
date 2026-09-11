import 'package:bierodex/data/beers.dart' as beers_data;
import 'package:bierodex/models/beer.dart';
import 'package:bierodex/services/user_beer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [UserBeerService.instance] crée `AuthService.instance`, qui lit
/// `Supabase.instance` : y accéder ne doit donc jamais arriver avant
/// `setUpAll`. Un getter (plutôt qu'un `final` top-level) garantit que
/// l'accès reste paresseux, à chaque appel dans le corps d'un test.
UserBeerService get service => UserBeerService.instance;

const _catalogBeer = Beer(
  id: 'sierra-nevada-pale-ale',
  name: 'Sierra Nevada Pale Ale',
  brewery: 'Sierra Nevada',
  country: 'États-Unis',
  styleId: 'paleAle',
  abv: 5.6,
  description: 'La Pale Ale américaine fondatrice du mouvement craft.',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Aucun appel réseau réel : personne n'est connecté dans ces tests, donc
    // `_pushRemote`/`syncWithRemote` sont des no-op.
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  setUp(() {
    beers_data.beers = const [_catalogBeer];
  });

  test('addBeer fusionne la bière dans le catalogue affiché sans toucher '
      'aux bières du catalogue partagé', () async {
    final beer = await service.addBeer(
      name: 'Ratz Blonde',
      brewery: 'Brasserie Ratz',
      country: 'France',
      styleId: 'belgianBlonde',
      abv: 5.0,
      description: 'Blonde artisanale non filtrée.',
      barcode: '3760123456789',
    );

    expect(beer.isCustom, isTrue);
    expect(beer.id, startsWith('custom-'));
    expect(beers_data.beers, contains(_catalogBeer));
    expect(
      beers_data.beers.any((b) => b.id == beer.id && b.isCustom),
      isTrue,
    );
    expect(
      beers_data.findBeerByBarcode('3760123456789')?.id,
      beer.id,
    );
  });

  test('removeBeer retire uniquement la bière personnelle visée', () async {
    final beer = await service.addBeer(
      name: 'À supprimer',
      brewery: 'Brasserie Test',
      country: 'France',
      styleId: 'ipa',
      abv: 6.0,
      description: '',
    );
    expect(beers_data.findBeerById(beer.id), isNotNull);

    await service.removeBeer(beer.id);

    expect(beers_data.findBeerById(beer.id), isNull);
    expect(beers_data.beers, contains(_catalogBeer));
  });
}
