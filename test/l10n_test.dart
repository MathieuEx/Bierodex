import 'package:bierodex/data/countries.dart';
import 'package:bierodex/l10n/l10n.dart';
import 'package:bierodex/models/beer_style.dart';
import 'package:bierodex/screens/age_gate_screen.dart';
import 'package:bierodex/services/legal_age_service.dart';
import 'package:bierodex/services/social_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => L10n.debugLocale = const Locale('fr'));

  test('français sur un appareil en français, anglais partout ailleurs', () {
    expect(resolveAppLocale(const Locale('fr', 'CA')), const Locale('fr'));
    expect(resolveAppLocale(const Locale('en', 'US')), const Locale('en'));
    expect(resolveAppLocale(const Locale('de')), const Locale('en'));
    expect(resolveAppLocale(null), const Locale('en'));
  });

  test('les textes hors widgets suivent la langue', () {
    L10n.debugLocale = const Locale('en');
    expect(SocialService.messageFor('23505', 'duplicate key'),
        'This username is already taken.');
    expect(BeerFamily.spontanee.label, 'Spontaneous fermentation');
    expect(countryName('Allemagne'), 'Germany');
    expect(countryName('Pays imaginaire'), 'Pays imaginaire');
    expect(formatDecimal(4.5), '4.5');

    L10n.debugLocale = const Locale('fr');
    expect(countryName('Allemagne'), 'Allemagne');
    expect(formatDecimal(4.5), '4,5');
  });

  testWidgets('l\'écran d\'âge s\'affiche en anglais', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await LegalAgeService.instance.load();
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AgeGateScreen(),
      ),
    );

    expect(find.text('Are you 18 or older?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pump();
    expect(find.textContaining('legal drinking age'), findsOneWidget);
  });
}
