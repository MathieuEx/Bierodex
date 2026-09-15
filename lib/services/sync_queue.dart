import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'crash_reporting.dart';

/// Identifiants modifiés localement mais pas encore confirmés par Supabase,
/// pour un compte et une table donnés. Persistée sur l'appareil : une
/// modification faite hors-ligne survit à la fermeture de l'app et part au
/// retour du réseau (voir [OfflineSyncService]).
///
/// La file ne stocke que des identifiants, jamais le contenu : au moment de
/// l'envoi, c'est la dernière version locale qui part (ou une suppression si
/// l'entrée n'existe plus). Dix modifications de la même bière hors-ligne ne
/// font donc qu'un seul envoi.
class SyncQueue extends ChangeNotifier {
  SyncQueue(this.name);

  /// Nom de la file (sert de clé de stockage), ex. `beer_status`.
  final String name;

  final Set<String> _pending = {};

  /// Numéro de modification par identifiant, en mémoire uniquement : un
  /// envoi réussi ne retire l'identifiant de la file que si aucune nouvelle
  /// modification n'est arrivée pendant l'envoi.
  final Map<String, int> _revisions = {};

  String? _userId;

  Set<String> get pending => Set.unmodifiable(_pending);

  bool isPending(String id) => _pending.contains(id);

  String _keyFor(String userId) => 'bierodex.syncQueue.$name.$userId';

  /// Charge la file du compte [userId] (vide si `null`).
  Future<void> load(String? userId) async {
    _userId = userId;
    _pending.clear();
    _revisions.clear();
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      _pending.addAll(prefs.getStringList(_keyFor(userId)) ?? const []);
    }
    notifyListeners();
  }

  /// Note que [id] doit être (re)envoyé. Renvoie le numéro de modification
  /// à passer à [complete] une fois l'envoi confirmé.
  Future<int> mark(String id) async {
    final revision = (_revisions[id] ?? 0) + 1;
    _revisions[id] = revision;
    if (_pending.add(id)) {
      await _persist();
      notifyListeners();
    }
    return revision;
  }

  /// Retire [id] de la file si [revision] est toujours la dernière
  /// modification connue (voir [mark]). Sans [revision], retire sans
  /// condition.
  Future<void> complete(String id, [int? revision]) async {
    if (revision != null && (_revisions[id] ?? 0) != revision) return;
    if (_pending.remove(id)) {
      await _persist();
      notifyListeners();
    }
  }

  static Future<void> forgetUser(String name, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bierodex.syncQueue.$name.$userId');
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (_pending.isEmpty) {
      await prefs.remove(_keyFor(userId));
    } else {
      await prefs.setStringList(_keyFor(userId), _pending.toList());
    }
  }

  /// Envoie chaque identifiant en attente avec [send]. Une erreur réseau
  /// arrête la tournée (inutile d'insister) et laisse la file intacte ; un
  /// refus définitif du serveur (voir [isPermanentFailure]) est signalé puis
  /// retiré de la file, pour ne pas bloquer les suivants indéfiniment. Les
  /// données restent de toute façon sur l'appareil.
  ///
  /// Renvoie `true` si la file est vide à la fin.
  Future<bool> flush(Future<void> Function(String id) send) async {
    final owner = _userId;
    for (final id in _pending.toList()) {
      final revision = _revisions[id] ?? 0;
      try {
        await send(id);
        // Changement de compte pendant l'envoi : la file chargée entre-temps
        // est celle d'un autre compte, qui peut suivre la même bière.
        if (_userId != owner) return false;
        await complete(id, revision);
      } catch (error, stackTrace) {
        if (_userId != owner) return false;
        if (!isPermanentFailure(error)) {
          debugPrint('Synchronisation $name reportée : $error');
          return false;
        }
        unawaited(CrashReporting.report(error, stackTrace));
        await complete(id, revision);
      }
    }
    return _pending.isEmpty;
  }

  /// Le serveur a répondu et refuse la donnée (contrainte, droits, format) :
  /// la renvoyer à l'identique échouerait toujours. Tout le reste (pas de
  /// réseau, délai dépassé, erreur 5xx, session à rafraîchir) est considéré
  /// comme passager.
  @visibleForTesting
  static bool isPermanentFailure(Object error) {
    if (error is! PostgrestException) return false;
    final code = error.code ?? '';
    // Classes SQLSTATE : 22 données invalides, 23 contrainte d'intégrité,
    // 42 droits insuffisants / syntaxe.
    return code.startsWith('22') ||
        code.startsWith('23') ||
        code.startsWith('42');
  }
}
