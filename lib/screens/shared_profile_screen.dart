import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../data/countries.dart';
import '../models/beer.dart';
import '../models/social.dart';
import '../services/auth_service.dart';
import '../services/beer_collection_service.dart';
import '../services/social_service.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import 'beer_detail_screen.dart';
import '../l10n/l10n.dart';

/// Collection d'un autre profil (ami, ou profil public ouvert depuis un
/// lien), en lecture seule.
class SharedProfileScreen extends StatefulWidget {
  final String username;

  /// Ouvert directement depuis un lien sur le web, sans compte : pas de
  /// retour possible, et les fiches du catalogue ne sont pas cliquables
  /// (elles exposeraient le suivi personnel, réservé aux comptes).
  final bool standalone;

  const SharedProfileScreen({
    super.key,
    required this.username,
    this.standalone = false,
  });

  @override
  State<SharedProfileScreen> createState() => _SharedProfileScreenState();
}

class _SharedProfileScreenState extends State<SharedProfileScreen> {
  late Future<SharedProfile?> _future = SocialService.instance
      .fetchSharedProfile(widget.username);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.standalone,
        title: Text('@${SocialService.normalizeUsername(widget.username)}'),
      ),
      body: FutureBuilder<SharedProfile?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _Message(
              icon: Icons.cloud_off,
              text: '${snapshot.error}',
              onRetry: () => setState(() {
                _future = SocialService.instance.fetchSharedProfile(
                  widget.username,
                );
              }),
            );
          }
          final profile = snapshot.data;
          if (profile == null) {
            return _Message(
              icon: Icons.lock_outline,
              text: context.l10n.sharedProfileUnavailable,
            );
          }
          return _ProfileBody(
            profile: profile,
            canOpenBeers: !widget.standalone && AuthService.instance.isSignedIn,
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  const _Message({required this.icon, required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.copper),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ],
      ),
    ),
  );
}

class _ProfileBody extends StatelessWidget {
  final SharedProfile profile;
  final bool canOpenBeers;

  const _ProfileBody({required this.profile, required this.canOpenBeers});

  Beer? _beer(String id) => findBeerById(id) ?? profile.customBeers[id];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final tried = [
      for (final entry in profile.statuses.entries)
        if (entry.value.tried && _beer(entry.key) != null)
          (beer: _beer(entry.key)!, status: entry.value),
    ];
    final wishlist = [
      for (final entry in profile.statuses.entries)
        if (entry.value.wishlist && _beer(entry.key) != null) _beer(entry.key)!,
    ]..sort((a, b) => a.name.compareTo(b.name));

    final countries = {for (final t in tried) t.beer.country}.length;
    final ratings = [for (final t in tried) ?t.status.rating];
    final average = ratings.isEmpty
        ? null
        : ratings.reduce((a, b) => a + b) / ratings.length;
    final myTried = BeerCollectionService.instance.triedBeerIds.toSet();
    final inCommon = profile.isSelf || !canOpenBeers
        ? null
        : tried.where((t) => myTried.contains(t.beer.id)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(profile.label, style: textTheme.headlineSmall),
        if (profile.displayName != null)
          Text('@${profile.username}', style: textTheme.bodySmall),
        const SizedBox(height: 16),
        Row(
          children: [
            _Stat(
              value: '${tried.length}',
              label: l10n.sharedProfileTastedStat(tried.length),
            ),
            _Stat(
              value: '$countries',
              label: l10n.statsTileCountries(countries),
            ),
            _Stat(
              value: average == null ? '–' : formatDecimal(average),
              label: l10n.statsTileAverage,
            ),
            if (inCommon != null)
              _Stat(value: '$inCommon', label: l10n.sharedProfileInCommon),
          ],
        ),
        if (profile.isSelf) ...[
          const SizedBox(height: 12),
          Text(
            l10n.sharedProfilePreview(profile.visibility.label.toLowerCase()),
            style: textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 24),
        Text(l10n.tastedSection.toUpperCase(), style: textTheme.titleSmall),
        const SizedBox(height: 4),
        if (tried.isEmpty) Text(l10n.noBeersYet, style: textTheme.bodyMedium),
        for (final t in tried)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.sports_bar_outlined,
              color:
                  findStyleById(t.beer.styleId)?.family.color ??
                  AppColors.walnut,
            ),
            title: Text(t.beer.name),
            subtitle: Text(
              '${t.beer.brewery} · ${countryName(t.beer.country)}',
            ),
            trailing: t.status.rating == null
                ? null
                : StarRating(rating: t.status.rating, size: 14),
            onTap: canOpenBeers && !t.beer.isCustom
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BeerDetailScreen(beerId: t.beer.id),
                    ),
                  )
                : null,
          ),
        if (wishlist.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.wishlistLabel.toUpperCase(), style: textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final beer in wishlist)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bookmark_outline),
              title: Text(beer.name),
              subtitle: Text('${beer.brewery} · ${countryName(beer.country)}'),
              onTap: canOpenBeers && !beer.isCustom
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BeerDetailScreen(beerId: beer.id),
                      ),
                    )
                  : null,
            ),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(color: AppColors.copper),
          ),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
