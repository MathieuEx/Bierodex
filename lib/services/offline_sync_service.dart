import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'beer_collection_service.dart';
import 'user_beer_service.dart';

/// Déclenche l'envoi des modifications faites hors-ligne (files de
/// [UserBeerService] et [BeerCollectionService]) : au retour du réseau, au
/// retour au premier plan de l'app, et toutes les [_retryDelay] tant qu'il
/// reste quelque chose à envoyer (le système peut annoncer un réseau sans
/// accès réel à internet, ex. un Wi-Fi d'hôtel).
class OfflineSyncService extends ChangeNotifier with WidgetsBindingObserver {
  OfflineSyncService._();

  static final OfflineSyncService instance = OfflineSyncService._();

  static const _retryDelay = Duration(minutes: 1);

  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  Timer? _retryTimer;
  bool _started = false;
  bool _flushing = false;

  /// Nombre de modifications locales pas encore confirmées par le serveur.
  int get pendingCount =>
      UserBeerService.instance.syncQueue.pending.length +
      BeerCollectionService.instance.syncQueue.pending.length;

  bool get hasPending => pendingCount > 0;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    UserBeerService.instance.syncQueue.addListener(_onQueueChanged);
    BeerCollectionService.instance.syncQueue.addListener(_onQueueChanged);
    try {
      _connectivity = Connectivity().onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) unawaited(flush());
      });
    } catch (error) {
      // Plateforme sans plugin (tests) : le minuteur prend le relais.
      debugPrint('Suivi du réseau indisponible : $error');
    }
    _onQueueChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(flush());
  }

  void _onQueueChanged() {
    if (hasPending) {
      _retryTimer ??= Timer.periodic(_retryDelay, (_) => flush());
    } else {
      _retryTimer?.cancel();
      _retryTimer = null;
    }
    notifyListeners();
  }

  /// Envoie tout ce qui est en attente, bières personnelles d'abord (la
  /// dégustation d'une bière ajoutée hors-ligne la référence).
  Future<void> flush() async {
    if (_flushing || !hasPending) return;
    _flushing = true;
    try {
      if (await UserBeerService.instance.flushPending()) {
        await BeerCollectionService.instance.flushPending();
      }
    } finally {
      _flushing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivity?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
