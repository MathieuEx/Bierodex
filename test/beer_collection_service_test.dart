import 'package:bierodex/services/beer_collection_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [BeerCollectionService.instance] crée aussi `AuthService.instance`, qui
/// lit `Supabase.instance` : y accéder ne doit donc jamais arriver avant
/// `setUpAll`. Un getter (plutôt qu'un `final` top-level) garantit que
/// l'accès reste paresseux, à chaque appel dans le corps d'un test.
BeerCollectionService get service => BeerCollectionService.instance;

/// C'est par ailleurs un vrai singleton (process-wide) : chaque test utilise
/// un identifiant de bière qui lui est propre pour éviter toute
/// contamination entre tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Aucun appel réseau réel : personne n'est connecté dans ces tests, donc
    // `_pushRemote`/`syncWithRemote` sont des no-op. On a juste besoin que
    // `Supabase.instance` soit initialisé pour que le service ne plante pas.
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  test('setTried(true) marque la bière et horodate la dégustation', () async {
    const id = 'test-tried-beer';
    await service.setTried(id, true);

    expect(service.isTried(id), isTrue);
    expect(service.triedAtFor(id), isNotNull);
    expect(
      service.triedAtFor(id)!.difference(DateTime.now()).inMinutes.abs(),
      lessThan(1),
    );
  });

  test('setTried(false) efface la date de dégustation', () async {
    const id = 'test-untried-beer';
    await service.setTried(id, true);
    await service.setTried(id, false);

    expect(service.isTried(id), isFalse);
    expect(service.triedAtFor(id), isNull);
  });

  test('marquer une bière comme bue retire son statut "à goûter"', () async {
    const id = 'test-wishlist-then-tried';
    await service.setWishlist(id, true);
    expect(service.isWishlist(id), isTrue);

    await service.setTried(id, true);
    expect(service.isTried(id), isTrue);
    expect(service.isWishlist(id), isFalse);
  });

  test('marquer une bière "à goûter" retire son statut bue et sa note',
      () async {
    const id = 'test-tried-then-wishlist';
    await service.setTried(id, true);
    await service.setRating(id, 4);

    await service.setWishlist(id, true);
    expect(service.isTried(id), isFalse);
    expect(service.ratingFor(id), isNull);
    expect(service.isWishlist(id), isTrue);
  });

  test('setNote enregistre et efface une note libre', () async {
    const id = 'test-note-beer';
    expect(service.noteFor(id), isNull);

    await service.setNote(id, 'Bue à la Brasserie Ratz, super souvenir.');
    expect(service.noteFor(id), 'Bue à la Brasserie Ratz, super souvenir.');

    await service.setNote(id, null);
    expect(service.noteFor(id), isNull);
  });

  test('setNote traite une chaîne vide comme "pas de note"', () async {
    const id = 'test-blank-note-beer';
    await service.setNote(id, '   ');
    expect(service.noteFor(id), isNull);
  });

  test('setTriedAt permet de corriger manuellement la date', () async {
    const id = 'test-manual-date-beer';
    final date = DateTime(2023, 5, 12);
    await service.setTried(id, true);
    await service.setTriedAt(id, date);

    expect(service.triedAtFor(id), date);
  });

  test('mostRecentTriedId retourne la bière la plus récemment dégustée',
      () async {
    const older = 'test-recent-older';
    const newer = 'test-recent-newer';
    // D'autres tests de ce fichier dégustent des bières avec `triedAt` égal
    // à `now()` au moment où ils tournent (quelques millisecondes avant ou
    // après ce test) : on se place délibérément dans le futur par rapport
    // à "maintenant" pour ne jamais se faire dépasser par ces entrées-là.
    final base = DateTime.now().add(const Duration(days: 365));
    await service.setTried(older, true);
    await service.setTriedAt(older, base);
    await service.setTried(newer, true);
    await service.setTriedAt(newer, base.add(const Duration(days: 1)));

    expect(service.mostRecentTriedId, newer);
  });

  test('averageRating ignore les bières sans note', () async {
    const rated = 'test-average-rated';
    const unrated = 'test-average-unrated';
    await service.setTried(rated, true);
    await service.setRating(rated, 5);
    await service.setTried(unrated, true);

    expect(service.averageRating, isNotNull);
  });
}
