import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_contact.dart';
import '../models/sos_alert.dart';
import '../services/firebase_service.dart';
import '../services/notification_manager.dart';

/// Centralized SOS service — handles the full emergency workflow:
/// 1. Log alert in Firestore (with GPS)
/// 2. Call primary contact
/// 3. Send SMS with location to all contacts
/// 4. Trigger push notification
/// 5. Escalation if no response
class SosService {
  static final SosService _instance = SosService._();
  factory SosService() => _instance;
  SosService._();

  final _firebase = FirebaseService();
  final _notifications = NotificationManager();

  bool _isTriggered = false;
  bool get isTriggered => _isTriggered;

  /// Full SOS workflow
  Future<SosResult> triggerSos({
    required String userId,
    required List<EmergencyContact> contacts,
    double? latitude,
    double? longitude,
    String triggerSource = 'manual',
  }) async {
    if (contacts.isEmpty) {
      return SosResult(
        success: false,
        message: 'No emergency contacts configured',
      );
    }

    _isTriggered = true;

    try {
      // 1. Create SOS alert record
      final alert = SosAlert(
        id: '${userId}_sos_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        contactsCalled: contacts.map((c) => c.name).join(', '),
        status: 'triggered',
        triggerSource: triggerSource,
      );

      // 2. Log to Firestore
      await _firebase.addSosAlert(alert);

      // 3. Show immediate local notification
      await _notifications.showNotification(
        title: 'SOS Alert Triggered',
        body: 'Emergency contacts are being notified. Stay calm.',
      );

      // 4. Find primary contact (or first available)
      final primaryContact = contacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => contacts.first,
      );

      // 5. Build SMS message with GPS link
      final locationLink = (latitude != null && longitude != null)
          ? 'https://www.google.com/maps?q=$latitude,$longitude'
          : 'Location unavailable';

      final smsBody = Uri.encodeComponent(
        '🚨 EMERGENCY SOS from SafeStep!\n\n'
        'I need immediate help!\n'
        'Location: $locationLink\n\n'
        'This is an automated emergency alert.',
      );

      // 6. Send SMS to ALL contacts
      for (final contact in contacts) {
        final smsUri = Uri.parse('sms:${contact.phone}?body=$smsBody');
        try {
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
          }
        } catch (_) {
          // Continue to next contact even if one fails
        }
      }

      // 7. Call primary contact
      final callUri = Uri.parse('tel:${primaryContact.phone}');
      bool callSuccess = false;
      if (await canLaunchUrl(callUri)) {
        callSuccess = await launchUrl(callUri);
      }

      return SosResult(
        success: true,
        message: callSuccess
            ? 'SOS triggered! Calling ${primaryContact.name}...'
            : 'SOS logged. SMS sent. Could not initiate call.',
        alert: alert,
        contactCalled: primaryContact,
      );
    } catch (e) {
      return SosResult(success: false, message: 'SOS Error: ${e.toString()}');
    }
  }

  /// Escalation: call secondary contacts if primary didn't respond
  Future<void> escalate({
    required String userId,
    required List<EmergencyContact> contacts,
  }) async {
    // Get non-primary contacts
    final secondaryContacts = contacts.where((c) => !c.isPrimary).toList();
    if (secondaryContacts.isEmpty) return;

    for (final contact in secondaryContacts) {
      final callUri = Uri.parse('tel:${contact.phone}');
      try {
        if (await canLaunchUrl(callUri)) {
          await launchUrl(callUri);
          break; // Call one at a time
        }
      } catch (_) {
        continue;
      }
    }

    await _notifications.showNotification(
      title: 'SOS Escalated',
      body: 'Attempting to reach secondary contacts.',
    );
  }

  /// Resolve the current SOS
  void resolve() {
    _isTriggered = false;
  }
}

class SosResult {
  final bool success;
  final String message;
  final SosAlert? alert;
  final EmergencyContact? contactCalled;

  const SosResult({
    required this.success,
    required this.message,
    this.alert,
    this.contactCalled,
  });
}
