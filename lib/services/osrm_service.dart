import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class OsrmService {
  static const String _baseUrl = 'https://router.project-osrm.org';

  /// ✅ Fetch route using OSRM (GeoJSON based)
  static Future<Map<String, dynamic>?> getRoute({
    required Position source,
    required Position destination,
  }) async {
    try {
      final lon1 = source.longitude.toStringAsFixed(6);
      final lat1 = source.latitude.toStringAsFixed(6);
      final lon2 = destination.longitude.toStringAsFixed(6);
      final lat2 = destination.latitude.toStringAsFixed(6);

      final url =
          '$_baseUrl/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=full&geometries=geojson';

      debugPrint('🚗 OSRM URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint('❌ HTTP ERROR: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);

      // ✅ SAFETY CHECK
      if (data == null ||
          data['routes'] == null ||
          data['routes'].isEmpty) {
        debugPrint('❌ No routes in response');
        return null;
      }

      final route = data['routes'][0];

      final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;

      // ✅ CORRECT WAY: Parse GeoJSON coordinates
      final geometry = route['geometry'];
      List<Map<String, double>> polyline = [];

      if (geometry != null && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'];

        polyline = coords.map<Map<String, double>>((point) {
          return {
            'lat': (point[1] as num).toDouble(), // ✅ lat
            'lng': (point[0] as num).toDouble(), // ✅ lon
          };
        }).toList();
      }

      debugPrint(
          '✅ Route OK: ${(distance / 1000).toStringAsFixed(2)} km, ${(duration / 60).toStringAsFixed(0)} min');

      return {
        'distance': distance,
        'duration': duration,
        'polyline': polyline,
      };
    } catch (e) {
      debugPrint('💥 OSRM ERROR: $e');
      return null;
    }
  }

  /// ✅ Distance formatter
  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// ✅ Duration formatter
  static String formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final hours = (mins / 60).floor();
    final remaining = mins % 60;

    if (hours > 0) return '${hours}h ${remaining}m';
    return '${mins}m';
  }
}