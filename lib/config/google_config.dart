/// Identifiants OAuth Google (console.cloud.google.com > Identifiants),
/// fournis comme ceux de Supabase via `--dart-define-from-file=env.json`.
/// Ce ne sont pas des secrets (ils sont visibles dans l'app compilée) : le
/// seul secret, celui du client Web, se saisit uniquement dans le tableau de
/// bord Supabase. Laissés vides, le bouton "Continuer avec Google" est masqué.
class GoogleConfig {
  /// Client de type "Application Web". Sert d'audience du jeton sur
  /// Android et iOS, et c'est lui que Supabase connaît.
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// Client de type "iOS" (bundle `com.bierodex.bierodex`).
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
}
