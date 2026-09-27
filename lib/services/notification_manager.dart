import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:uuid/uuid.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification != null || message.data.isNotEmpty) {
    NotificationManager().showNotification(
      title: message.notification?.title ?? 'SafeStep Alert',
      body: message.notification?.body ?? 'Action required.',
    );
  }
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._();
  factory NotificationManager() => _instance;
  NotificationManager._();

  final _localNotif = FlutterLocalNotificationsPlugin();
  final _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  static const String _chEmergencyId = 'safestep_emergency';
  static const String _chReminderId = 'safestep_reminder';

  /// Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // TZ handled by NotificationService dynamically

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _chEmergencyId,
          'Emergency Alerts',
          importance: Importance.max,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _chReminderId,
          'Reminders',
          importance: Importance.high,
        ),
      );
    }

    await _fcm.requestPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        showNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
        );
      }
    });

    _initialized = true;
  }

  /// 🔔 Instant notification
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await _localNotif.show(
      const Uuid().v4().hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chEmergencyId,
          'Emergency',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }
}
