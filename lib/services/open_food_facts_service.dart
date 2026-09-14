import 'dart:convert';

import 'package:http/http.dart' as http;

/// Résultat d'une recherche de produit par code-barres sur Open Food Facts
/// (https://world.openfoodfacts.org, données CC BY-SA), utilisé pour
/// préremplir le formulaire d'ajout d'une bière absente du catalogue.
class OpenFoodFactsProduct {
  final String? name;
  final String? brand;
  final String? imageUrl;

  const OpenFoodFactsProduct({this.name, this.brand, this.imageUrl});
}

class OpenFoodFactsService {
  OpenFoodFactsService._();

  static final OpenFoodFactsService instance = OpenFoodFactsService._();

  /// Interroge Open Food Facts pour le produit portant [barcode].
  /// Retourne `null` si le produit est inconnu ou en cas d'erreur réseau —
  /// l'ajout manuel reste toujours possible dans ce cas.
  Future<OpenFoodFactsProduct?> lookup(String barcode) async {
    // Le code est inséré dans le chemin de l'URL : chiffres uniquement,
    // pour qu'une valeur forgée ne puisse pas viser une autre ressource.
    if (!RegExp(r'^[0-9]{6,14}$').hasMatch(barcode)) return null;
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$barcode.json',
      {'fields': 'product_name,brands,image_front_url'},
    );
    try {
      final response = await http
          .get(uri, headers: {'User-Agent': 'Bierodex - Flutter app'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['status'] != 1) return null;

      final product = decoded['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final name = product['product_name'] as String?;
      final brand = (product['brands'] as String?)?.split(',').first.trim();
      final imageUrl = product['image_front_url'] as String?;

      if ((name == null || name.isEmpty) && (brand == null || brand.isEmpty)) {
        return null;
      }
      return OpenFoodFactsProduct(
        name: (name != null && name.isNotEmpty) ? name : null,
        brand: (brand != null && brand.isNotEmpty) ? brand : null,
        // HTTPS uniquement (voir la contrainte `user_beers_input_bounds`).
        imageUrl: (imageUrl != null && imageUrl.startsWith('https://'))
            ? imageUrl
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}
