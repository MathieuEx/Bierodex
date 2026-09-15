import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Confirmation de l'âge légal (18 ans en France), demandée une seule fois
/// par appareil avant tout autre écran (voir `BierodexApp`). Il s'agit
/// d'une déclaration, pas d'une vérification d'identité : c'est ce que
/// pratiquent les apps et sites de boissons alcoolisées.
class LegalAgeService extends ChangeNotifier {
  LegalAgeService._();

  static final LegalAgeService instance = LegalAgeService._();

  static const legalAge = 18;
  static const _prefsKey = 'bierodex.legalAgeConfirmed.v1';

  bool _confirmed = false;

  bool get isConfirmed => _confirmed;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _confirmed = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> confirm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    _confirmed = true;
    notifyListeners();
  }
}
