/// Adresse publique de la version web du Bierodex, fournie comme les autres
/// réglages via `--dart-define-from-file=env.json` (clé `PUBLIC_WEB_URL`,
/// par ex. `https://bierodex.example`). Les liens de profil public pointent
/// vers `<PUBLIC_WEB_URL>/?profil=<pseudo>`, que l'app web ouvre sans
/// connexion (voir `BierodexApp` dans lib/main.dart). Laissée vide, le
/// bouton « Partager le lien » est masqué.
class ShareConfig {
  static const String webBaseUrl = String.fromEnvironment('PUBLIC_WEB_URL');
}
