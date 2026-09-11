import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../models/beer_style.dart';
import '../services/open_food_facts_service.dart';
import '../services/user_beer_service.dart';
import 'beer_detail_screen.dart';

/// Formulaire d'ajout d'une bière absente du catalogue partagé, ouvert le
/// plus souvent après un scan de code-barres sans correspondance (voir
/// [BarcodeScannerScreen]), mais accessible aussi sans code-barres.
/// L'ajout reste personnel (voir [UserBeerService]) : le catalogue public
/// reste géré côté Supabase, pas modifiable depuis l'app.
class AddBeerScreen extends StatefulWidget {
  final String? barcode;

  const AddBeerScreen({super.key, this.barcode});

  @override
  State<AddBeerScreen> createState() => _AddBeerScreenState();
}

class _AddBeerScreenState extends State<AddBeerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breweryController = TextEditingController();
  final _countryController = TextEditingController();
  final _abvController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _styleId;
  String? _imageUrl;
  bool _loadingLookup = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) _lookup();
  }

  Future<void> _lookup() async {
    setState(() => _loadingLookup = true);
    final product = await OpenFoodFactsService.instance.lookup(widget.barcode!);
    if (!mounted) return;
    setState(() {
      _loadingLookup = false;
      if (product != null) {
        _nameController.text = product.name ?? '';
        _breweryController.text = product.brand ?? '';
        _imageUrl = product.imageUrl;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breweryController.dispose();
    _countryController.dispose();
    _abvController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;
    if (_styleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un style de bière.')),
      );
      return;
    }

    setState(() => _saving = true);
    final beer = await UserBeerService.instance.addBeer(
      name: _nameController.text.trim(),
      brewery: _breweryController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? 'Inconnu'
          : _countryController.text.trim(),
      styleId: _styleId!,
      abv: double.tryParse(_abvController.text.replaceAll(',', '.')) ?? 0,
      description: _descriptionController.text.trim(),
      barcode: widget.barcode,
      imageUrl: _imageUrl,
      imageCredit: _imageUrl != null ? 'Open Food Facts (CC BY-SA)' : null,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => BeerDetailScreen(beerId: beer.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une bière')),
      body: _loadingLookup
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.barcode != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Code-barres : ${widget.barcode}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (_imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl!,
                          height: 160,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom de la bière'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _breweryController,
                    decoration: const InputDecoration(labelText: 'Brasserie'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Pays'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _styleId,
                    decoration: const InputDecoration(labelText: 'Style'),
                    items: [
                      for (final family in BeerFamily.values)
                        ...stylesForFamily(family).map(
                          (style) => DropdownMenuItem(
                            value: style.id,
                            child: Text(
                              style.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _styleId = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _abvController,
                    decoration: const InputDecoration(labelText: 'ABV (%)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Ajouter à mon carnet'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cette bière n\'est visible que dans ton carnet, pas dans '
                    'le catalogue partagé.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }
}
