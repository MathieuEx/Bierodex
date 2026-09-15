import 'dart:async';
import 'dart:ui';

import 'package:bierodex/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configuration commune à tous les tests (chargée automatiquement par
/// `flutter test`) : l'app tourne en français, quelle que soit la langue de
/// la machine qui lance les tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
  binding.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
  L10n.debugLocale = const Locale('fr');
  await L10n.initialize();
  await testMain();
}
