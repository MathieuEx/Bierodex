import 'package:bierodex/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validation des saisies de l'écran de connexion : fonctions statiques,
/// donc sans `Supabase.initialize` ni appel réseau.
void main() {
  group('normalizeEmail', () {
    test('nettoie espaces et majuscules', () {
      expect(
        AuthService.normalizeEmail('  Jean.Dupont@Example.FR '),
        'jean.dupont@example.fr',
      );
    });

    test('refuse les adresses mal formées ou piégées', () {
      for (final input in [
        '',
        'pas-une-adresse',
        'a@b',
        'a b@example.com',
        'a@example.com\nBcc: victime@example.com',
        "x'); drop table users;--@example.com",
        '<script>alert(1)</script>@example.com',
        '${'a' * 250}@example.com',
      ]) {
        expect(AuthService.normalizeEmail(input), isNull, reason: input);
      }
    });
  });

  group('isValidCode', () {
    test('accepte exactement 6 chiffres', () {
      expect(AuthService.isValidCode('012345'), isTrue);
    });

    test('refuse tout le reste', () {
      for (final input in [
        '',
        '12345',
        '1234567',
        '12a456',
        ' 123456',
        "1' OR 1=1",
      ]) {
        expect(AuthService.isValidCode(input), isFalse, reason: input);
      }
    });
  });
}
