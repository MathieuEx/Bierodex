import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../data/beers.dart';
import '../services/beer_collection_service.dart';
import '../services/social_service.dart';
import '../widgets/tasting_share_card.dart';
import '../l10n/l10n.dart';

/// Aperçu de la carte de dégustation, puis partage de l'image générée via
/// la feuille de partage du système (Instagram, WhatsApp, Messages...).
/// L'image est rendue sur l'appareil : rien n'est envoyé à nos serveurs.
class ShareTastingCardScreen extends StatefulWidget {
  final String beerId;

  const ShareTastingCardScreen({super.key, required this.beerId});

  @override
  State<ShareTastingCardScreen> createState() => _ShareTastingCardScreenState();
}

class _ShareTastingCardScreenState extends State<ShareTastingCardScreen> {
  final _boundaryKey = GlobalKey();
  final _shareButtonKey = GlobalKey();
  bool _showUsername = true;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    if (!SocialService.instance.isProfileLoaded) {
      SocialService.instance.loadProfile().catchError((_) => null);
    }
  }

  Future<void> _share() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final buttonBox =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = buttonBox == null
        ? null
        : buttonBox.localToGlobal(Offset.zero) & buttonBox.size;
    setState(() => _sharing = true);
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: 1080 / tastingShareCardSize.width,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final beer = findBeerById(widget.beerId);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              data!.buffer.asUint8List(),
              mimeType: 'image/png',
              name: l10n.shareCardFileName,
            ),
          ],
          text: beer == null ? null : l10n.shareCardText(beer.name),
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final beer = findBeerById(widget.beerId);
    if (beer == null) {
      return Scaffold(body: Center(child: Text(context.l10n.beerNotFound)));
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.shareCardTitle)),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          BeerCollectionService.instance,
          SocialService.instance,
        ]),
        builder: (context, _) {
          final collection = BeerCollectionService.instance;
          final username = SocialService.instance.profile?.username;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: TastingShareCard(
                        beer: beer,
                        status: collection.statusFor(beer.id),
                        username: _showUsername ? username : null,
                        triedBreweries: triedBreweriesFrom(
                          collection.triedBeerIds,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (username != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.shareCardShowUsername),
                  subtitle: Text('@$username'),
                  value: _showUsername,
                  onChanged: (value) => setState(() => _showUsername = value),
                ),
              Text(
                context.l10n.shareCardPrivacyNotice,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: _shareButtonKey,
                onPressed: _sharing ? null : _share,
                icon: const Icon(Icons.ios_share),
                label: Text(
                  _sharing ? context.l10n.preparing : context.l10n.shareImage,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
