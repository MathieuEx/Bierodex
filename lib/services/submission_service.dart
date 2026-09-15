import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/beers.dart' as beers_data;
import '../models/social.dart';
import 'auth_service.dart';
import 'beer_collection_service.dart';
import 'social_service.dart' show SocialFailure;
import 'user_beer_service.dart';
import '../l10n/l10n.dart';

/// Bières ajoutées à la main, proposées au catalogue commun puis validées
/// (ou refusées) par un modérateur. Voir `supabase/add_social.sql`.
class SubmissionService extends ChangeNotifier {
  SubmissionService._() {
    AuthService.instance.addListener(_onAuthChanged);
  }

  static final SubmissionService instance = SubmissionService._();

  static const _table = 'beer_submissions';

  SupabaseClient get _client => Supabase.instance.client;

  String? _userId;

  /// Dernière proposition connue pour chaque bière personnelle
  /// (clé : `user_beers.id`).
  Map<String, BeerSubmission> _mine = const {};
  bool? _isModerator;

  bool get isModerator => _isModerator ?? false;

  BeerSubmission? submissionFor(String userBeerId) => _mine[userBeerId];

  void _onAuthChanged() {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == _userId) return;
    _userId = userId;
    _mine = const {};
    _isModerator = null;
    notifyListeners();
  }

  Future<void> loadMine() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    _userId = user.id;
    final rows = await _guard(
      () => _client
          .from(_table)
          .select()
          .eq('submitted_by', user.id)
          .order('created_at'),
    );
    // Triées par date : la plus récente proposition d'une bière l'emporte.
    _mine = {
      for (final row in rows)
        row['user_beer_id'] as String: BeerSubmission.fromRow(row),
    };
    notifyListeners();
  }

  Future<bool> loadIsModerator() async {
    if (AuthService.instance.currentUser == null) return false;
    try {
      _isModerator = await _client.rpc('is_moderator') as bool? ?? false;
    } catch (_) {
      _isModerator = false;
    }
    notifyListeners();
    return isModerator;
  }

  Future<void> submit(String userBeerId) async {
    await _guard(
      () => _client.rpc(
        'submit_user_beer',
        params: {'p_user_beer_id': userBeerId},
      ),
    );
    await loadMine();
  }

  Future<void> withdraw(BeerSubmission submission) async {
    await _guard(() => _client.from(_table).delete().eq('id', submission.id));
    await loadMine();
  }

  /// Une fois une proposition acceptée, la bière existe deux fois chez son
  /// auteur : dans son carnet (`custom-…`) et dans le catalogue
  /// (`community-…`). On déplace alors sa dégustation vers la fiche du
  /// catalogue et on retire la copie personnelle. Sans effet tant que le
  /// catalogue chargé ne contient pas encore la nouvelle fiche (il sera
  /// rechargé au prochain lancement). Idempotent.
  Future<int> adoptApprovedBeers() async {
    if (AuthService.instance.currentUser == null) return 0;
    await loadMine();
    var adopted = 0;
    for (final submission in _mine.values) {
      final catalogId = submission.catalogBeerId;
      if (submission.status != SubmissionStatus.approved || catalogId == null) {
        continue;
      }
      final custom = beers_data.findBeerById(submission.userBeerId);
      final catalog = beers_data.findBeerById(catalogId);
      if (custom == null || !custom.isCustom) continue;
      if (catalog == null || catalog.isCustom) continue;
      await BeerCollectionService.instance.moveStatus(
        from: submission.userBeerId,
        to: catalogId,
      );
      await UserBeerService.instance.removeBeer(submission.userBeerId);
      adopted++;
    }
    return adopted;
  }

  // --- Modération -----------------------------------------------------------

  Future<List<BeerSubmission>> pendingSubmissions() async {
    final rows = await _guard(
      () => _client
          .from(_table)
          .select()
          .eq('status', 'pending')
          .order('created_at'),
    );
    return [for (final row in rows) BeerSubmission.fromRow(row)];
  }

  /// Accepte (en appliquant les corrections éventuelles) ou refuse une
  /// proposition. Retourne l'identifiant de la bière créée si acceptée.
  Future<String?> review(
    BeerSubmission submission, {
    required bool approve,
    String? note,
    String? name,
    String? brewery,
    String? country,
    String? styleId,
    double? abv,
    String? description,
  }) async {
    final result = await _guard(
      () => _client.rpc(
        'review_submission',
        params: {
          'p_submission_id': submission.id,
          'p_approve': approve,
          'p_note': note,
          'p_name': name,
          'p_brewery': brewery,
          'p_country': country,
          'p_style_id': styleId,
          'p_abv': abv,
          'p_description': description,
        },
      ),
    );
    return result as String?;
  }

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      throw SocialFailure(messageFor(e.message));
    } catch (_) {
      throw SocialFailure(L10n.current.errorServerUnreachable);
    }
  }

  @visibleForTesting
  static String messageFor(String message) {
    final l10n = L10n.current;
    if (message.contains('already_submitted')) {
      return l10n.submissionAlreadySubmitted;
    }
    if (message.contains('already_in_catalog')) {
      return l10n.submissionAlreadyInCatalog;
    }
    if (message.contains('too_many_submissions')) {
      return l10n.submissionTooMany;
    }
    if (message.contains('beer_not_found')) {
      return l10n.submissionBeerNotSynced;
    }
    if (message.contains('not_moderator')) {
      return l10n.submissionNotModerator;
    }
    if (message.contains('submission_not_found')) {
      return l10n.submissionAlreadyReviewed;
    }
    return l10n.errorGeneric;
  }
}
