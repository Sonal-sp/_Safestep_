import 'package:cloud_firestore/cloud_firestore.dart';

/// Incident report model for community safety reporting.
class IncidentReport {
  final String id;
  final String userId;
  final String type; // 'crime' | 'unsafe_area' | 'poor_lighting' | 'other'
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? imageUrl;
  final DateTime timestamp;
  final int upvotes;
  final String status; // 'pending' | 'confirmed' | 'resolved'

  const IncidentReport({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.imageUrl,
    required this.timestamp,
    this.upvotes = 0,
    this.status = 'pending',
  });

  factory IncidentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return IncidentReport(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'other',
      description: data['description'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.fromDate(timestamp),
        'upvotes': upvotes,
        'status': status,
      };

  String get typeLabel {
    switch (type) {
      case 'crime': return 'Crime';
      case 'unsafe_area': return 'Unsafe Area';
      case 'poor_lighting': return 'Poor Lighting';
      default: return 'Other';
    }
  }

  IconLabel get typeIcon {
    switch (type) {
      case 'crime': return IconLabel('🚨', 'Crime');
      case 'unsafe_area': return IconLabel('⚠️', 'Unsafe Area');
      case 'poor_lighting': return IconLabel('💡', 'Poor Lighting');
      default: return IconLabel('📍', 'Other');
    }
  }
}

class IconLabel {
  final String emoji;
  final String label;
  const IconLabel(this.emoji, this.label);
}
