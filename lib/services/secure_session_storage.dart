import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stockage de la session Supabase (access token + refresh token) dans le
/// coffre-fort du système plutôt qu'en clair dans SharedPreferences :
/// Keychain sur iOS, Keystore (clés matérielles quand disponibles) sur
/// Android. C'est ce qui permet de "rester connecté" entre deux lancements
/// sans laisser le refresh token lisible par une autre app, une sauvegarde
/// ou quelqu'un qui copierait le stockage de l'appareil.
///
/// Sur les autres plateformes (web, desktop), Supabase garde son stockage
/// par défaut : voir [useSecureSessionStorage].
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({required this.persistSessionKey});

  final String persistSessionKey;

  static const _storage = FlutterSecureStorage(
    // Jamais synchronisé sur iCloud ni restauré sur un autre appareil, mais
    // lisible dès le premier déverrouillage pour que le rafraîchissement
    // du token puisse aussi se faire app en arrière-plan.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> initialize() => _migrateFromSharedPreferences();

  /// Les versions précédentes de l'app laissaient Supabase stocker la
  /// session dans SharedPreferences : on la déplace une fois dans le
  /// coffre-fort (sans déconnecter l'utilisateur) puis on efface la copie
  /// en clair.
  Future<void> _migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(persistSessionKey);
    if (legacy == null) return;
    if (!await _storage.containsKey(key: persistSessionKey)) {
      await _storage.write(key: persistSessionKey, value: legacy);
    }
    await prefs.remove(persistSessionKey);
  }

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: persistSessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _storage.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: persistSessionKey, value: persistSessionString);
}

/// Le coffre-fort n'est utilisé que sur mobile. Sur le web il n'apporterait
/// rien (flutter_secure_storage y range la clé de chiffrement à côté des
/// données, dans le même localStorage) ; sur macOS il exige un entitlement
/// Keychain signé par une équipe de développement.
bool get useSecureSessionStorage =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Même clé que celle utilisée par défaut par supabase_flutter, pour que la
/// migration retrouve la session déjà persistée.
String supabaseSessionKey(String supabaseUrl) =>
    'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';
