import 'package:bierodex/l10n/l10n.dart';
import 'package:bierodex/screens/age_gate_screen.dart';
import 'package:bierodex/services/legal_age_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la confirmation de l\'âge est mémorisée sur l\'appareil', () async {
    SharedPreferences.setMockInitialValues({});
    await LegalAgeService.instance.load();
    expect(LegalAgeService.instance.isConfirmed, isFalse);

    await LegalAgeService.instance.confirm();
    await LegalAgeService.instance.load();
    expect(LegalAgeService.instance.isConfirmed, isTrue);
  });

  testWidgets('répondre "Non" bloque l\'accès à l\'app', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await LegalAgeService.instance.load();
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AgeGateScreen(),
      ),
    );

    await tester.tap(find.text('Non'));
    await tester.pump();

    expect(find.textContaining('réservé aux personnes'), findsOneWidget);
    expect(find.textContaining('ans ou plus'), findsNothing);
    expect(LegalAgeService.instance.isConfirmed, isFalse);
  });
}
