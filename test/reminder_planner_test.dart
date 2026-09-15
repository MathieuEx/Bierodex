import 'package:bierodex/models/beer_user_status.dart';
import 'package:bierodex/services/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 15, 10);

  group('inactivité', () {
    test('aucun rappel sans aucune dégustation', () {
      expect(ReminderPlanner.inactivity({}, now), isNull);
      expect(
        ReminderPlanner.inactivity({
          'a': const BeerUserStatus(wishlist: true),
        }, now),
        isNull,
      );
    });

    test('30 jours après la dernière dégustation, à 18 h', () {
      final reminder = ReminderPlanner.inactivity({
        'old': BeerUserStatus(tried: true, triedAt: DateTime(2026, 8, 1)),
        'last': BeerUserStatus(tried: true, triedAt: DateTime(2026, 9, 10, 21)),
      }, now)!;

      expect(reminder.at, DateTime(2026, 10, 10, 18));
      expect(reminder.idleDays, 29);
    });

    test('délai déjà dépassé : reporté d\'une semaine', () {
      final reminder = ReminderPlanner.inactivity({
        'a': BeerUserStatus(tried: true, triedAt: DateTime(2026, 6, 1)),
      }, now)!;

      expect(reminder.at, DateTime(2026, 9, 22, 18));
      expect(reminder.idleDays, greaterThan(100));
    });
  });

  group('wishlist', () {
    const statuses = {
      'a': BeerUserStatus(wishlist: true),
      'b': BeerUserStatus(wishlist: true),
      'c': BeerUserStatus(tried: true),
    };

    test('aucun rappel si la wishlist est vide', () {
      expect(
        ReminderPlanner.wishlist({'c': const BeerUserStatus(tried: true)}, now),
        isNull,
      );
    });

    test(
      'conserve la date déjà prévue et choisit une bière de la wishlist',
      () {
        final planned = DateTime(2026, 9, 20, 18);
        final reminder = ReminderPlanner.wishlist(
          statuses,
          now,
          nextAt: planned,
        )!;

        expect(reminder.at, planned);
        expect(['a', 'b'], contains(reminder.beerId));
        // Même date, même bière : rouvrir l'app ne change pas le message.
        expect(
          ReminderPlanner.wishlist(statuses, now, nextAt: planned)!.beerId,
          reminder.beerId,
        );
      },
    );

    test('date passée : nouveau rappel dans deux semaines', () {
      final reminder = ReminderPlanner.wishlist(
        statuses,
        now,
        nextAt: DateTime(2026, 9, 1, 18),
      )!;
      expect(reminder.at, DateTime(2026, 9, 29, 18));
    });
  });
}
