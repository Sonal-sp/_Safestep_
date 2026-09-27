import 'package:cloud_firestore/cloud_firestore.dart';

/// Live location sharing session for Guardian Mode.
class LocationSession {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String? destination;
  final double? destLatitude;
  final double? destLongitude;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'active' | 'completed' | 'stopped_unexpectedly'
  final String shareLink;
  final DateTime lastUpdated;

  const LocationSession({
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    this.destination,
    this.destLatitude,
    this.destLongitude,
    required this.startTime,
    this.endTime,
    this.status = 'active',
    required this.shareLink,
    required this.lastUpdated,
  });

  factory LocationSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return LocationSession(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      destination: data['destination'] as String?,
      destLatitude: (data['destLatitude'] as num?)?.toDouble(),
      destLongitude: (data['destLongitude'] as num?)?.toDouble(),
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'active',
      shareLink: data['shareLink'] as String? ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
        'destination': destination,
        'destLatitude': destLatitude,
        'destLongitude': destLongitude,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
        'status': status,
        'shareLink': shareLink,
        'lastUpdated': Timestamp.fromDate(lastUpdated),
      };

  bool get isActive => status == 'active';

  LocationSession copyWith({
    double? latitude,
    double? longitude,
    String? status,
    DateTime? endTime,
    String? shareLink,
    DateTime? lastUpdated,
  }) =>
      LocationSession(
        id: id,
        userId: userId,
        userName: userName,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        destination: destination,
        destLatitude: destLatitude,
        destLongitude: destLongitude,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        shareLink: shareLink ?? this.shareLink,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}
