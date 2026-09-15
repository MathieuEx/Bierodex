import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Langues de l'app : français sur un appareil réglé en français, anglais
/// partout ailleurs.
Locale resolveAppLocale(Locale? deviceLocale) =>
    deviceLocale?.languageCode == 'fr'
        ? const Locale('fr')
        : const Locale('en');

extension AppLocalizationsContext on BuildContext {
  /// Textes traduits, dans les widgets : `context.l10n.maCle`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Accès aux traductions hors des widgets (messages d'erreur des services,
/// badges, rappels programmés) : suit la langue de l'appareil.
class L10n {
  static Locale? _override;

  static AppLocalizations get current => lookupAppLocalizations(locale);

  static Locale get locale =>
      _override ?? resolveAppLocale(PlatformDispatcher.instance.locale);

  /// À appeler une fois au démarrage (et dans les tests) : charge les noms
  /// de mois et formats de date des langues de l'app.
  static Future<void> initialize() => initializeDateFormatting();

  /// Les tests fixent la langue plutôt que de dépendre de la machine.
  @visibleForTesting
  static set debugLocale(Locale? locale) => _override = locale;
}

/// Nombre décimal au format de la langue (`4,5` en français, `4.5` en
/// anglais).
String formatDecimal(double value, {int digits = 1}) =>
    NumberFormat.decimalPatternDigits(
      locale: L10n.current.localeName,
      decimalDigits: digits,
    ).format(value);

/// Date courte : `15/09/2026` en français, `9/15/2026` en anglais.
String formatDate(DateTime date) =>
    DateFormat.yMd(L10n.current.localeName).format(date);

/// Mois abrégé : `sept.` en français, `Sep` en anglais.
String formatShortMonth(DateTime date) =>
    DateFormat.MMM(L10n.current.localeName).format(date);
