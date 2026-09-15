import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/beers.dart' as beers_data;
import 'beer_collection_service.dart';
import 'reminder_planner.dart';
import '../l10n/l10n.dart';

/// Rappels locaux, programmés sur l'appareil (aucun serveur) : « rien goûté
/// depuis un mois » et « une bière de ta wishlist t'attend ». Recalculés à
/// chaque changement de la collection (voir [ReminderPlanner]).
///
/// Mobile uniquement (Android, iOS, macOS) : sur le web, [isSupported] vaut
/// `false` et tout est un no-op.
class NotificationService extends ChangeNotifier {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _inactivityKey = 'bierodex.notifications.inactivity';
  static const _wishlistKey = 'bierodex.notifications.wishlist';
  static const _nextWishlistKey = 'bierodex.notifications.nextWishlistAt';
  static const _permissionAskedKey = 'bierodex.notifications.permissionAsked';

  static const _inactivityId = 1;
  static const _wishlistId = 2;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _started = false;
  bool _inactivityEnabled = true;
  bool _wishlistEnabled = true;
  Timer? _debounce;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool get inactivityEnabled => _inactivityEnabled;
  bool get wishlistEnabled => _wishlistEnabled;

  Future<void> start() async {
    if (_started || !isSupported) return;
    _started = true;
    try {
      tz_data.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // L'autorisation est demandée plus bas, une seule fois.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Rappels indisponibles : $error');
      _started = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _inactivityEnabled = prefs.getBool(_inactivityKey) ?? true;
    _wishlistEnabled = prefs.getBool(_wishlistKey) ?? true;
    notifyListeners();

    BeerCollectionService.instance.addListener(_scheduleSoon);
    if ((_inactivityEnabled || _wishlistEnabled) &&
        prefs.getBool(_permissionAskedKey) != true) {
      await prefs.setBool(_permissionAskedKey, true);
      await _requestPermission();
    }
    await reschedule();
  }

  Future<void> setInactivityEnabled(bool enabled) async {
    _inactivityEnabled = enabled;
    await _saveToggle(_inactivityKey, enabled);
  }

  Future<void> setWishlistEnabled(bool enabled) async {
    _wishlistEnabled = enabled;
    await _saveToggle(_wishlistKey, enabled);
  }

  Future<void> _saveToggle(String key, bool enabled) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, enabled);
    if (enabled) await _requestPermission();
    await reschedule();
  }

  Future<bool> _requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    return await macos?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Une dégustation déclenche souvent plusieurs changements d'affilée
  /// (statut, note, date) : on attend qu'ils soient passés.
  void _scheduleSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), reschedule);
  }

  Future<void> reschedule() async {
    if (!_started) return;
    final statuses = BeerCollectionService.instance.statuses;
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final l10n = L10n.current;

    await _plugin.cancel(id: _inactivityId);
    final inactivity = _inactivityEnabled
        ? ReminderPlanner.inactivity(statuses, now)
        : null;
    if (inactivity != null) {
      await _schedule(
        _inactivityId,
        inactivity.at,
        title: l10n.reminderInactivityTitle,
        body: l10n.reminderInactivityBody(inactivity.idleDays!),
      );
    }

    await _plugin.cancel(id: _wishlistId);
    final savedNext = prefs.getString(_nextWishlistKey);
    final wishlist = _wishlistEnabled
        ? ReminderPlanner.wishlist(
            statuses,
            now,
            nextAt: savedNext == null ? null : DateTime.tryParse(savedNext),
          )
        : null;
    final beer = wishlist == null
        ? null
        : beers_data.findBeerById(wishlist.beerId!);
    if (wishlist != null && beer != null) {
      await prefs.setString(_nextWishlistKey, wishlist.at.toIso8601String());
      await _schedule(
        _wishlistId,
        wishlist.at,
        title: l10n.reminderWishlistTitle,
        body: l10n.reminderWishlistBody(beer.name, beer.brewery),
      );
    }
  }

  Future<void> _schedule(
    int id,
    DateTime at, {
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        title: title,
        body: body,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            L10n.current.reminderChannelName,
            channelDescription: L10n.current.reminderChannelDescription,
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (error) {
      debugPrint('Rappel non programmé : $error');
    }
  }
}
