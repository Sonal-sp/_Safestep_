import 'package:geolocator/geolocator.dart';

class NearbyPlace {
  final String name;
  final String address;
  final double? distanceMeters; // ✅ made nullable (safer)
  final double lat;
  final double lng;
  final bool isOpen;

  // Route data
  Map<String, dynamic>? routeInfo;
  List<Map<String, double>>? polylinePoints;
  String? formattedDistance;
  String? formattedDuration;

  NearbyPlace({
    required this.name,
    required this.address,
    this.distanceMeters,
    required this.lat,
    required this.lng,
    this.isOpen = true,
    this.routeInfo,
    this.polylinePoints,
    this.formattedDistance,
    this.formattedDuration,
  });

  /// ✅ JSON parsing (safe)
  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] ?? true,
    );
  }

  /// ✅ JSON serialization
  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'distanceMeters': distanceMeters,
        'lat': lat,
        'lng': lng,
        'isOpen': isOpen,
      };

  /// ✅ Update with OSRM route data (safe + correct)
  void updateRoute(Map<String, dynamic> routeData) {
    routeInfo = routeData;

    final distance = (routeData['distance'] as num?)?.toDouble() ?? 0.0;
    final duration = (routeData['duration'] as num?)?.toDouble() ?? 0.0;

    formattedDistance = _formatDistance(distance);
    formattedDuration = _formatDuration(duration);

    // ✅ Safe polyline parsing
    if (routeData['polyline'] != null) {
      polylinePoints = (routeData['polyline'] as List)
          .map<Map<String, double>>((p) => {
                'lat': (p['lat'] as num).toDouble(),
                'lng': (p['lng'] as num).toDouble(),
              })
          .toList();
    }
  }

  /// ✅ Format distance
  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// ✅ Format duration
  String _formatDuration(double seconds) {
    final mins = (seconds / 60).round();
    return '$mins min';
  }

  /// ✅ Safe distance getter
  String get straightDistance =>
      _formatDistance(distanceMeters ?? 0);

  /// ✅ Convert to Position (for OSRM)
  Position get position => Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}