import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced SOS alert with GPS location, SMS status, and escalation tracking.
class SosAlert {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? contactsCalled;
  final String? smsSent;
  final String status; // 'triggered' | 'resolved' | 'escalated'
  final String? triggerSource; // 'manual' | 'fall_detection' | 'voice' | 'low_battery'

  const SosAlert({
    required this.id,
    required this.userId,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.address,
    this.contactsCalled,
    this.smsSent,
    this.status = 'triggered',
    this.triggerSource = 'manual',
  });

  factory SosAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return SosAlert(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address'] as String?,
      contactsCalled: data['contactsCalled'] as String?,
      smsSent: data['smsSent'] as String?,
      status: data['status'] as String? ?? 'triggered',
      triggerSource: data['triggerSource'] as String? ?? 'manual',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'timestamp': Timestamp.fromDate(timestamp),
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'contactsCalled': contactsCalled,
        'smsSent': smsSent,
        'status': status,
        'triggerSource': triggerSource,
      };

  String get mapsLink {
    if (latitude == null || longitude == null) return '';
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }
}
