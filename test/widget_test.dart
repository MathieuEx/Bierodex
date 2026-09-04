import 'package:flutter_test/flutter_test.dart';

import 'package:bierodex/main.dart';

void main() {
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
}
