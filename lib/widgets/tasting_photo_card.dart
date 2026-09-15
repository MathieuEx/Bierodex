import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/beer_collection_service.dart';
import '../services/tasting_photo_service.dart';
import '../l10n/l10n.dart';

/// Photo personnelle prise au moment de la dégustation (appareil photo ou
/// galerie), stockée dans le bucket privé de l'utilisateur.
class TastingPhotoCard extends StatefulWidget {
  final String beerId;

  const TastingPhotoCard({super.key, required this.beerId});

  @override
  State<TastingPhotoCard> createState() => _TastingPhotoCardState();
}

class _TastingPhotoCardState extends State<TastingPhotoCard> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      // Redimensionnée et compressée côté appareil : une photo de
      // dégustation n'a pas besoin de 12 Mpx, et l'envoi reste rapide.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final path = await TastingPhotoService.instance.upload(
        widget.beerId,
        bytes,
      );
      await BeerCollectionService.instance.setPhotoPath(widget.beerId, path);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoSaveFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.photoDeleteTitle),
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
    if (confirmed != true) return;
    setState(() => _busy = true);
    await BeerCollectionService.instance.setPhotoPath(widget.beerId, null);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BeerCollectionService.instance,
      builder: (context, _) {
        final status = BeerCollectionService.instance.statusFor(widget.beerId);
        if (!status.tried) return const SizedBox.shrink();
        final path = status.photoPath;
        final textTheme = Theme.of(context).textTheme;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (path != null) _SignedPhoto(key: ValueKey(path), path: path),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.myPhoto,
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            context.l10n.photoPrivate,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else ...[
                      IconButton(
                        tooltip: context.l10n.takePhoto,
                        icon: const Icon(Icons.photo_camera_outlined),
                        onPressed: () => _pick(ImageSource.camera),
                      ),
                      IconButton(
                        tooltip: context.l10n.chooseFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        onPressed: () => _pick(ImageSource.gallery),
                      ),
                      if (path != null)
                        IconButton(
                          tooltip: context.l10n.deletePhoto,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _remove,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignedPhoto extends StatefulWidget {
  final String path;

  const _SignedPhoto({super.key, required this.path});

  @override
  State<_SignedPhoto> createState() => _SignedPhotoState();
}

class _SignedPhotoState extends State<_SignedPhoto> {
  late Future<String> _url = TastingPhotoService.instance.signedUrl(
    widget.path,
  );

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    return SizedBox(
      height: 280,
      child: FutureBuilder<String>(
        future: _url,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _retry(placeholderColor);
          }
          if (!snapshot.hasData) {
            return ColoredBox(
              color: placeholderColor,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) => _retry(placeholderColor),
          );
        },
      ),
    );
  }

  Widget _retry(Color color) => ColoredBox(
        color: color,
        child: Center(
          child: TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.photoUnavailableRetry),
            onPressed: () => setState(() {
              _url = TastingPhotoService.instance.signedUrl(widget.path);
            }),
          ),
        ),
      );
}
