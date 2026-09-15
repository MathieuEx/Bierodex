import 'dart:async';
import 'dart:io';

import 'package:bierodex/services/sync_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'la file survit à un redémarrage (rechargement du même compte)',
    () async {
      final queue = SyncQueue('beer_status');
      await queue.load('user-a');
      await queue.mark('beer-1');
      await queue.mark('beer-2');

      final reloaded = SyncQueue('beer_status');
      await reloaded.load('user-a');
      expect(reloaded.pending, {'beer-1', 'beer-2'});
    },
  );

  test('chaque compte a sa propre file', () async {
    final queue = SyncQueue('beer_status');
    await queue.load('user-a');
    await queue.mark('beer-1');

    await queue.load('user-b');
    expect(queue.pending, isEmpty);
  });

  test('une erreur réseau garde tout en file et arrête la tournée', () async {
    final queue = SyncQueue('beer_status');
    await queue.load('user-a');
    await queue.mark('beer-1');
    await queue.mark('beer-2');

    final sent = <String>[];
    final done = await queue.flush((id) async {
      sent.add(id);
      throw const SocketException('Pas de réseau');
    });

    expect(done, isFalse);
    expect(sent, hasLength(1));
    expect(queue.pending, {'beer-1', 'beer-2'});
  });

  test('un envoi réussi vide la file', () async {
    final queue = SyncQueue('beer_status');
    await queue.load('user-a');
    await queue.mark('beer-1');

    expect(await queue.flush((_) async {}), isTrue);
    expect(queue.pending, isEmpty);
  });

  test('un refus définitif du serveur ne bloque pas les suivants', () async {
    final queue = SyncQueue('beer_status');
    await queue.load('user-a');
    await queue.mark('beer-bad');
    await queue.mark('beer-good');

    final sent = <String>[];
    final done = await queue.flush((id) async {
      sent.add(id);
      if (id == 'beer-bad') {
        throw const PostgrestException(message: 'check', code: '23514');
      }
    });

    expect(done, isTrue);
    expect(sent, containsAll(['beer-bad', 'beer-good']));
    expect(queue.pending, isEmpty);
  });

  test('une modification pendant l\'envoi reste en file', () async {
    final queue = SyncQueue('beer_status');
    await queue.load('user-a');
    await queue.mark('beer-1');

    final sending = Completer<void>();
    final flush = queue.flush((_) => sending.future);
    await queue.mark('beer-1');
    sending.complete();

    expect(await flush, isFalse);
    expect(queue.pending, {'beer-1'});
  });

  test('un changement de compte pendant l\'envoi ne touche pas la file du '
      'nouveau compte', () async {
    SharedPreferences.setMockInitialValues({
      'bierodex.syncQueue.beer_status.user-b': ['orval'],
    });
    final queue = SyncQueue('beer_status');
    await queue.load('user-a');
    await queue.mark('orval');

    final sending = Completer<void>();
    final flush = queue.flush((_) => sending.future);
    await queue.load('user-b');
    sending.complete();

    expect(await flush, isFalse);
    expect(queue.pending, {'orval'});
  });

  test('isPermanentFailure distingue refus serveur et panne réseau', () {
    expect(
      SyncQueue.isPermanentFailure(
        const PostgrestException(message: 'rls', code: '42501'),
      ),
      isTrue,
    );
    expect(
      SyncQueue.isPermanentFailure(
        const PostgrestException(message: 'jwt', code: 'PGRST301'),
      ),
      isFalse,
    );
    expect(
      SyncQueue.isPermanentFailure(const SocketException('offline')),
      isFalse,
    );
    expect(SyncQueue.isPermanentFailure(TimeoutException('slow')), isFalse);
  });
}
