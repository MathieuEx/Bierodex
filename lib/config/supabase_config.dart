/// Identifiants du projet Supabase du Bierodex.
///
/// Fournis au moment du build via `--dart-define-from-file=env.json` (voir
/// `env.example.json` pour le format attendu) plutôt qu'écrits en dur ici :
/// le repo étant public, on évite d'exposer l'URL/clé dans le code source
/// pour ne pas laisser n'importe qui spammer des inscriptions ou consommer
/// le quota gratuit du projet. La clé "anon" reste protégée par les
/// policies Row Level Security des tables, pas par sa confidentialité — ce
/// n'est donc pas un secret classique, mais mieux vaut ne pas la publier
/// inutilement pour autant. Ne jamais mettre ici la "service_role key".
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
