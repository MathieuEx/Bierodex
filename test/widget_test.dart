import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bierodex/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Bierodex affiche la liste des styles au démarrage',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BierodexApp());
    await tester.pumpAndSettle();

    expect(find.text('Styles de bières'), findsOneWidget);
    expect(find.text('Pale Ale'), findsOneWidget);
  });

  testWidgets('Naviguer vers un style affiche ses bières',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BierodexApp());
    await tester.pumpAndSettle();

    final paleAleFinder = find.text('Pale Ale');
    await tester.scrollUntilVisible(paleAleFinder, 100);
    await tester.tap(paleAleFinder);
    await tester.pumpAndSettle();

    expect(find.text('Sierra Nevada Pale Ale'), findsOneWidget);
  });

  testWidgets('Marquer une bière comme bue et la noter la fait apparaître '
      'dans Ma collection', (WidgetTester tester) async {
    await tester.pumpWidget(const BierodexApp());
    await tester.pumpAndSettle();

    final paleAleFinder = find.text('Pale Ale');
    await tester.scrollUntilVisible(paleAleFinder, 100);
    await tester.tap(paleAleFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sierra Nevada Pale Ale'));
    await tester.pumpAndSettle();

    expect(find.text('J\'ai bu cette bière'), findsOneWidget);
    await tester.tap(find.text('J\'ai bu cette bière'));
    await tester.pumpAndSettle();

    final starFinder = find.byIcon(Icons.star_border_rounded).first;
    await tester.tap(starFinder);
    await tester.pumpAndSettle();

    // Retour à l'écran racine (deux pages empilées : style puis bière).
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.local_bar_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Sierra Nevada Pale Ale'), findsOneWidget);
    expect(find.textContaining('1 / '), findsOneWidget);
  });
}
