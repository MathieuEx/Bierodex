/// Suivi des plantages via Sentry, fourni comme les autres réglages via
/// `--dart-define-from-file=env.json` (clé `SENTRY_DSN`, onglet Client Keys
/// du projet Sentry). Laissé vide (développement, tests, CI), Sentry n'est
/// pas initialisé et rien ne quitte l'appareil.
class SentryConfig {
  static const String dsn = String.fromEnvironment('SENTRY_DSN');

  /// Nom de l'environnement affiché dans Sentry (`production` par défaut).
  static const String environment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'production',
  );

  static bool get isEnabled => dsn.isNotEmpty;
}
