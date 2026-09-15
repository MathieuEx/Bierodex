import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'auth_service.dart';

/// Photos de dégustation, rangées dans le bucket **privé** Supabase Storage
/// `tasting-photos` (voir `supabase/add_tasting_details.sql`). Chaque
/// fichier vit sous `<user_id>/…` : les policies Storage n'autorisent un
/// compte qu'à lire et écrire dans son propre dossier, et l'affichage passe
/// par des URL signées à durée de vie courte, jamais par une URL publique.
class TastingPhotoService {
  TastingPhotoService._();

  static final TastingPhotoService instance = TastingPhotoService._();

  static const bucket = 'tasting-photos';
  static const _signedUrlLifetime = Duration(hours: 1);
  static const _uuid = Uuid();

  /// URL signées déjà obtenues, réutilisées tant qu'elles restent valides
  /// (marge d'une minute) pour ne pas en redemander à chaque rebuild.
  final Map<String, ({String url, DateTime expiresAt})> _signedUrls = {};

  StorageFileApi get _storage => Supabase.instance.client.storage.from(bucket);

  /// Envoie la photo et retourne son chemin dans le bucket. Un nom unique
  /// par envoi : remplacer une photo ne réutilise jamais une URL signée
  /// encore en cache pour l'ancienne.
  Future<String> upload(String beerId, Uint8List bytes) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      throw StateError('Connexion requise pour enregistrer une photo.');
    }
    final safeBeerId = beerId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final path = '${user.id}/$safeBeerId-${_uuid.v4()}.jpg';
    await _storage.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    return path;
  }

  Future<void> delete(String path) async {
    _signedUrls.remove(path);
    if (AuthService.instance.currentUser == null) return;
    try {
      await _storage.remove([path]);
    } catch (_) {
      // Fichier déjà absent ou réseau indisponible : la ligne de la
      // collection ne le référence plus, rien de bloquant.
    }
  }

  Future<String> signedUrl(String path) async {
    final cached = _signedUrls[path];
    final now = DateTime.now();
    if (cached != null &&
        cached.expiresAt.isAfter(now.add(const Duration(minutes: 1)))) {
      return cached.url;
    }
    final url = await _storage.createSignedUrl(
      path,
      _signedUrlLifetime.inSeconds,
    );
    _signedUrls[path] = (url: url, expiresAt: now.add(_signedUrlLifetime));
    return url;
  }
}
