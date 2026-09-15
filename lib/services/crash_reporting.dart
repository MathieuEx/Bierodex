import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';

/// Point d'entrée unique vers Sentry. Sans DSN (voir [SentryConfig]), tout
/// est un no-op : l'app démarre normalement et les erreurs restent dans la
/// console.
///
/// Réglages volontairement minimaux (voir la politique de confidentialité) :
/// aucune donnée personnelle (ni adresse IP, ni identifiant de compte, ni
/// e-mail), pas de capture d'écran, pas de fil d'Ariane réseau (les URL
/// Supabase contiennent des identifiants de bières et de comptes).
class CrashReporting {
  static Future<void> run(FutureOr<void> Function() appRunner) async {
    if (!SentryConfig.isEnabled) {
      await appRunner();
      return;
    }
    await SentryFlutter.init((options) {
      options
        ..dsn = SentryConfig.dsn
        ..environment = SentryConfig.environment
        ..sendDefaultPii = false
        ..attachScreenshot = false
        ..enableAutoPerformanceTracing = false
        ..tracesSampleRate = 0
        ..beforeBreadcrumb = _scrubBreadcrumb
        ..beforeSend = _scrubEvent;
    }, appRunner: appRunner);
  }

  /// Signale une erreur rattrapée par l'app mais anormale (ex. une
  /// synchronisation refusée par le serveur).
  static Future<void> report(Object error, StackTrace? stackTrace) async {
    debugPrint('Erreur signalée : $error');
    if (!SentryConfig.isEnabled) return;
    await Sentry.captureException(error, stackTrace: stackTrace);
  }

  static Breadcrumb? _scrubBreadcrumb(Breadcrumb? crumb, Hint hint) {
    if (crumb == null) return null;
    if (crumb.category == 'http' || crumb.type == 'http') return null;
    return crumb;
  }

  static SentryEvent? _scrubEvent(SentryEvent event, Hint hint) {
    return event
      ..user = null
      ..request = null
      ..serverName = null;
  }
}
