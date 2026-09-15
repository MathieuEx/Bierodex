import 'package:bierodex/data/beer_styles.dart' as beer_styles_data;
import 'package:bierodex/data/beers.dart' as beers_data;
import 'package:bierodex/data/brewery_locations.dart' as brewery_locations_data;
import 'package:bierodex/models/beer.dart';
import 'package:bierodex/models/beer_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bierodex/main.dart';
import 'package:bierodex/theme/brand.dart';

/// Avance l'horloge simulée d'une durée fixe, largement suffisante pour nos
/// transitions (< 1 s), plutôt que `pumpAndSettle()`.
Future<void> settle(WidgetTester tester, {int pumps = 6}) async {
  for (var i = 0; i < pumps; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// Le catalogue (styles/bières/brasseries) vit maintenant dans Supabase :
/// on peuple ici un petit jeu de données de test directement, plutôt que
/// de faire un vrai appel réseau (bloqué par flutter_test de toute façon).
void _seedFixtureCatalog() {
  beer_styles_data.beerStyles = const [
    BeerStyle(
      id: 'paleAle',
      name: 'Pale Ale',
      family: BeerFamily.aleHaute,
      origin: 'Royaume-Uni',
      abvRange: '4,5 – 6,2 %',
      description: 'Ale ambrée équilibrée entre malt et houblon.',
    ),
  ];
  beers_data.beers = const [
    Beer(
      id: 'sierra-nevada-pale-ale',
      name: 'Sierra Nevada Pale Ale',
      brewery: 'Sierra Nevada',
      country: 'États-Unis',
      styleId: 'paleAle',
      abv: 5.6,
      description: 'La Pale Ale américaine fondatrice du mouvement craft.',
    ),
  ];
  brewery_locations_data.breweryLocations = {};
}

/// Onglet de la barre de navigation du bas, repéré par son libellé.
Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Un projet factice suffit : ces tests ne font aucun appel réseau réel
    // (flutter_test intercepte les requêtes HTTP), on a juste besoin que
    // `Supabase.instance` soit initialisé pour que les services ne plantent
    // pas en le lisant.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _seedFixtureCatalog();
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    BierodexApp(catalogFuture: Future<void>.value(), requireSignIn: false),
  );

  testWidgets('Bierodex affiche la carte au démarrage', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    expect(find.byType(BrandWordmark), findsOneWidget);
    expect(find.text('Europe'), findsOneWidget);
  });

  testWidgets('Ouvrir les styles depuis la carte affiche la liste des styles', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.byIcon(Icons.local_drink_outlined));
    await settle(tester);

    expect(find.text('Styles de bières'), findsOneWidget);
    expect(find.text('Pale Ale'), findsOneWidget);
  });

  testWidgets('Naviguer vers un style affiche ses bières', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(navTab('Styles'));
    await settle(tester);

    final paleAleFinder = find.text('Pale Ale');
    await tester.scrollUntilVisible(paleAleFinder, 100);
    await tester.tap(paleAleFinder);
    await settle(tester);

    expect(find.text('Sierra Nevada Pale Ale'), findsOneWidget);
  });

  testWidgets('Marquer une bière comme bue et la noter la fait apparaître '
      'dans Ma collection', (WidgetTester tester) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(navTab('Styles'));
    await settle(tester);

    final paleAleFinder = find.text('Pale Ale');
    await tester.scrollUntilVisible(paleAleFinder, 100);
    await tester.tap(paleAleFinder);
    await settle(tester);

    await tester.tap(find.text('Sierra Nevada Pale Ale'));
    await settle(tester);

    expect(find.text('J\'ai bu cette bière'), findsOneWidget);
    await tester.tap(find.text('J\'ai bu cette bière'));
    await settle(tester);

    final starFinder = find.byIcon(Icons.star_border_rounded).first;
    await tester.tap(starFinder);
    await settle(tester);

    // Retour à l'onglet Styles (deux pages empilées : style puis bière).
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    await tester.tap(navTab('Collection'));
    await settle(tester);

    expect(find.text('Sierra Nevada Pale Ale'), findsOneWidget);
    expect(find.textContaining('1 / '), findsOneWidget);
  });

  testWidgets('La carte réagit aux boutons de continent sans planter', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('Europe'));
    await settle(tester);

    await tester.tap(find.text('Asie'));
    await settle(tester);
  });
}
