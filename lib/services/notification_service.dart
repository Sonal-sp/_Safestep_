import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_io.dart'
    as platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import 'package:uuid/uuid.dart';

import '../models/medication.dart';
import '../services/firebase_service.dart';

/// Unified push notification system for SafeStep.
/// Covers: SOS, medicine reminders, missed meds, safety alerts,
/// incident alerts, low battery, fall detection, route changes.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _uuid = const Uuid();
  final FirebaseService _fb = FirebaseService();

  bool _initialized = false;

  // ─── NOTIFICATION CHANNELS ──────────────────────────────────
  static const _chMedicine = 'safestep_medicines';
  static const _chMedicineName = 'Medicine Reminders';

  static const _chEmergency = 'safestep_emergency';
  static const _chEmergencyName = 'Emergency Alerts';

  static const _chSafety = 'safestep_safety';
  static const _chSafetyName = 'Safety Alerts';

  static const _chTracking = 'safestep_tracking';
  static const _chTrackingName = 'Location Tracking';

  static const _chGeneral = 'safestep_general';
  static const _chGeneralName = 'General Notifications';

  // ─── INITIALIZATION ─────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Create all notification channels
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _chMedicine,
          _chMedicineName,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          description: 'Medication reminders and missed dose alerts',
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _chEmergency,
          _chEmergencyName,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          description:
              'SOS alerts, fall detection, and emergency notifications',
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _chSafety,
          _chSafetyName,
          importance: Importance.high,
          playSound: true,
          description: 'Unsafe area warnings, route changes, and safety alerts',
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _chTracking,
          _chTrackingName,
          importance: Importance.low,
          playSound: false,
          description: 'Live location sharing status updates',
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _chGeneral,
          _chGeneralName,
          importance: Importance.defaultImportance,
          description: 'General app notifications',
        ),
      );
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Route based on payload
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload type
      // This would be handled by the app's navigation system
    }
  }

  // ─── PERMISSIONS ────────────────────────────────────────────
  Future<void> requestPermissions() async {
    if (platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    if (platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      // Android 13+ EXACT ALARM PERMISSION (CRITICAL for reliability)
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  /// ⚠️ ANDROID BATTERY OPTIMIZATION NOTE:
  /// For reliable notifications when app killed:
  /// 1. Settings > Apps > SafeStep > Battery > Unrestricted
  /// 2. Settings > Apps > Special app access > Alarms & reminders > SafeStep

  // ─── MEDICINE REMINDERS (2 NOTIFICATIONS) ──────────────

  /// Schedule exactly 2 notifications: pre-reminder + exact time (daily repeat)
  Future<void> scheduleMedicineWithPreReminder(Medication m) async {
    final parts = m.time.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Next day if past
    if (scheduledTime.isBefore(now)) {
      scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    final medName = m.name.isNotEmpty ? m.name : 'Your Medicine';
    final medDosage = m.dosage.isEmpty ? '' : m.dosage;

    final baseId = m.id.hashCode & 0x7FFFFFFF;

    // 1. PRE-REMINDER (2 min before) - skip if already past
    final preTime = scheduledTime.subtract(const Duration(minutes: 2));
    if (preTime.isAfter(now)) {
      await _plugin.zonedSchedule(
        baseId + 1,
        '⏰ Upcoming Medicine',
        'Take $medName in 2 minutes',
        preTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _chMedicine,
            _chMedicineName,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
        payload: 'medicine:${m.id}:pre',
      );
    }

    // 2. EXACT TIME

    await _plugin.zonedSchedule(
      baseId + 2,
      '💊 Time to take $medName',
      'Take $medName${medDosage.isNotEmpty ? ' - $medDosage' : ''}',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chMedicine,
          _chMedicineName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
      payload: 'medicine:${m.id}:exact',
    );
  }

  // REMOVED OLD cancelAll version - using ID tracking ✅

  /// Reschedule all missed/upcoming meds on app start
  Future<void> initializeAndReschedule() async {
    await initialize();

    // 🚨 CLEAR ALL OLD NOTIFICATIONS ON START - NO GHOSTS
    await _plugin.cancelAll();

    final uid = _fb.currentUser?.uid;
    if (uid == null) {
      log('No user logged in - skipping reschedule');
      return;
    }

    final medsStream = _fb.medicationsStream(uid);
    final meds = await medsStream.first;

    if (meds.isEmpty) {
      log('No medications - nothing to schedule');
      return;
    }

    for (final med in meds) {
      if (med.name.isEmpty) continue; // Skip invalid

      await scheduleMedicineWithPreReminder(med);
    }
  }

  // ─── EMERGENCY NOTIFICATIONS ────────────────────────────────
  Future<void> showEmergencyNotification(String title, String body) async {
    await _plugin.show(
      _uuid.v4().hashCode,
      '🚨 $title',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chEmergency,
          _chEmergencyName,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFDC2626),
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: 'emergency',
    );
  }

  // ─── FALL DETECTION NOTIFICATION ────────────────────────────
  Future<void> showFallDetectionAlert() async {
    await _plugin.show(
      'fall_detection'.hashCode,
      '🤖 Fall Detected!',
      'Are you okay? SOS will trigger automatically in 30 seconds if no response.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chEmergency,
          _chEmergencyName,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFDC2626),
          fullScreenIntent: true,
          ongoing: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: 'fall_detection',
    );
  }

  // ─── LOW BATTERY NOTIFICATION ───────────────────────────────
  Future<void> showLowBatteryAlert(int batteryLevel) async {
    await _plugin.show(
      'low_battery'.hashCode,
      '🔋 Low Battery Safety Mode',
      'Battery at $batteryLevel%. Your location has been shared with emergency contacts.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chEmergency,
          _chEmergencyName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFF59E0B),
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: 'low_battery',
    );
  }

  // ─── SAFETY ALERTS ──────────────────────────────────────────
  Future<void> showSafetyAlert(String title, String body) async {
    await _plugin.show(
      _uuid.v4().hashCode,
      '⚠️ $title',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chSafety,
          _chSafetyName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFF59E0B),
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: 'safety',
    );
  }

  // ─── TRACKING NOTIFICATIONS ─────────────────────────────────
  Future<void> showTrackingNotification(String title, String body) async {
    await _plugin.show(
      'tracking'.hashCode,
      '📍 $title',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chTracking,
          _chTrackingName,
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF2563EB),
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
      payload: 'tracking',
    );
  }

  // ─── INCIDENT ALERT ─────────────────────────────────────────
  Future<void> showIncidentAlert(String type, String location) async {
    await _plugin.show(
      _uuid.v4().hashCode,
      '🚨 Incident Reported Nearby',
      '$type reported near $location. Stay alert.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chSafety,
          _chSafetyName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFF59E0B),
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: 'incident',
    );
  }

  // ─── GENERAL NOTIFICATIONS ──────────────────────────────────
  Future<void> showImmediate(String title, String body) async {
    await _plugin.show(
      _uuid.v4().hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chGeneral,
          _chGeneralName,
          importance: Importance.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF2563EB),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ─── CANCEL ─────────────────────────────────────────────────
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel specific medicine's 2 reminders (pre + exact)
  Future<void> cancelMedicineReminder(String medicationId) async {
    final baseId = medicationId.hashCode & 0x7FFFFFFF;
    await _plugin.cancel(baseId + 1); // pre-reminder
    await _plugin.cancel(baseId + 2); // exact reminder
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
