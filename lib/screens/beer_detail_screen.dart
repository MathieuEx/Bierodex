import 'dart:async';

import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../data/countries.dart';
import '../screens/share_tasting_card_screen.dart';
import '../screens/style_detail_screen.dart';
import '../services/beer_collection_service.dart';
import '../services/user_beer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/community_submission_card.dart';
import '../widgets/star_rating.dart';
import '../widgets/tasting_photo_card.dart';
import '../widgets/tasting_profile_card.dart';
import '../l10n/l10n.dart';

class BeerDetailScreen extends StatelessWidget {
  final String beerId;

  const BeerDetailScreen({super.key, required this.beerId});

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.beerDeleteTitle),
        content: Text(context.l10n.beerDeleteDescription(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await UserBeerService.instance.removeBeer(beerId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final beer = findBeerById(beerId);
    if (beer == null) {
      return Scaffold(body: Center(child: Text(context.l10n.beerNotFound)));
    }
    final style = findStyleById(beer.styleId);
    final color = style?.family.color ?? AppColors.walnut;

    return Scaffold(
      appBar: AppBar(
        title: Text(beer.name),
        actions: [
          ListenableBuilder(
            listenable: BeerCollectionService.instance,
            builder: (context, _) => BeerCollectionService.instance
                    .isTried(beerId)
                ? IconButton(
                    tooltip: context.l10n.shareMyTasting,
                    icon: const Icon(Icons.ios_share),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShareTastingCardScreen(beerId: beerId),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (beer.isCustom)
            IconButton(
              tooltip: context.l10n.beerDeleteFromNotebook,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, beer.name),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (beer.imageUrl != null)
            _BeerPhoto(
              imageUrl: beer.imageUrl!,
              credit: beer.imageCredit,
              color: color,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: color, width: 4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.2),
                    foregroundColor: color,
                    child: const Icon(Icons.sports_bar_outlined, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beer.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text('${beer.brewery} · ${countryName(beer.country)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (beer.imageUrl != null) ...[
            Text(beer.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('${beer.brewery} · ${countryName(beer.country)}'),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${formatDecimal(beer.abv)}% ABV')),
              if (style != null)
                Chip(
                  label: Text(style.family.label),
                  backgroundColor: color.withValues(alpha: 0.16),
                  labelStyle: TextStyle(color: color),
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                ),
              if (beer.isCustom)
                Chip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: Text(context.l10n.beerAddedByYou),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(beer.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          _MyOpinionCard(beerId: beer.id),
          _TastedOnly(
            beerId: beer.id,
            child: TastingPhotoCard(beerId: beer.id),
          ),
          _TastedOnly(
            beerId: beer.id,
            child: TastingProfileCard(beerId: beer.id),
          ),
          if (beer.isCustom) ...[
            const SizedBox(height: 16),
            CommunitySubmissionCard(beerId: beer.id),
          ],
          const SizedBox(height: 16),
          if (style != null)
            Card(
              child: ListTile(
                leading: Icon(Icons.local_drink_outlined, color: color),
                title: Text(context.l10n.beerStyle(style.name)),
                subtitle: Text(
                  style.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StyleDetailScreen(styleId: style.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Espacement + contenu, affichés seulement pour une bière marquée comme
/// bue (évite un trou vide sous « Mon avis » sinon).
class _TastedOnly extends StatelessWidget {
  final String beerId;
  final Widget child;

  const _TastedOnly({required this.beerId, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) => BeerCollectionService.instance.isTried(beerId)
          ? Padding(padding: const EdgeInsets.only(top: 16), child: child)
          : const SizedBox.shrink(),
    );
  }
}

class _BeerPhoto extends StatelessWidget {
  final String imageUrl;
  final String? credit;
  final Color color;

  const _BeerPhoto({
    required this.imageUrl,
    required this.credit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 260,
            color: color.withValues(alpha: 0.08),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stack) => Center(
                child: Icon(Icons.sports_bar_outlined, size: 48, color: color),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.photoCredit(credit ?? context.l10n.freeLicense),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _MyOpinionCard extends StatelessWidget {
  final String beerId;

  const _MyOpinionCard({required this.beerId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final service = BeerCollectionService.instance;
        final tried = service.isTried(beerId);
        final wishlist = service.isWishlist(beerId);
        final rating = service.ratingFor(beerId);
        final triedAt = service.triedAtFor(beerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.beerMyReview,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      avatar: Icon(
                        wishlist ? Icons.bookmark : Icons.bookmark_outline,
                        size: 18,
                      ),
                      label: Text(context.l10n.wishlistLabel),
                      selected: wishlist,
                      onSelected: (value) => service.setWishlist(beerId, value),
                    ),
                    FilterChip(
                      avatar: Icon(
                        tried ? Icons.check_circle : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(context.l10n.beerTried),
                      selected: tried,
                      onSelected: (value) {
                        service.setTried(beerId, value);
                        if (!value) service.setRating(beerId, null);
                      },
                    ),
                  ],
                ),
                if (tried) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(context.l10n.beerMyRating),
                      const SizedBox(width: 8),
                      StarRating(
                        rating: rating,
                        size: 28,
                        onChanged: (value) => service.setRating(beerId, value),
                      ),
                      if (rating != null)
                        IconButton(
                          tooltip: context.l10n.beerClearRating,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => service.setRating(beerId, null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          triedAt != null
                              ? context.l10n.tastedOn(formatDate(triedAt))
                              : context.l10n.dateUnknown,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: triedAt ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            await service.setTriedAt(beerId, picked);
                          }
                        },
                        child: Text(context.l10n.edit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _NoteField(beerId: beerId),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Champ de note libre, géré indépendamment du [ListenableBuilder] parent
/// pour ne pas perdre le focus ni la position du curseur à chaque
/// notification du service (le texte tapé est source de vérité tant que
/// l'utilisateur édite ; il n'est renvoyé au service qu'après une courte
/// pause de frappe).
class _NoteField extends StatefulWidget {
  final String beerId;

  const _NoteField({required this.beerId});

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: BeerCollectionService.instance.noteFor(widget.beerId) ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      BeerCollectionService.instance.setNote(widget.beerId, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: context.l10n.tastingNotes,
        hintText: context.l10n.tastingNotesHint,
      ),
      onChanged: _onChanged,
    );
  }
}
