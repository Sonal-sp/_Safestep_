import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nearby_place.dart';

class PlacesService {
  static const int _cacheExpiryMinutes = 5;
  static const String _cacheKeyPrefix = 'places_cache_';

  /// ✅ GET MAX RADIUS BY TYPE
  static double _getMaxRadius(String type) {
    return switch (type.toLowerCase()) {
      'hospital' => 10000.0, // 10 km
      'pharmacy' => 5000.0,  // 5 km
      'police station' => 7000.0, // 7 km
      _ => 10000.0,
    };
  }

  /// ✅ FETCH NEARBY PLACES WITH STRICT FILTERING & FALLBACK
  static Future<List<NearbyPlace>> getNearby({
    required String type,
    required Position position,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCacheKey(type, position);

    if (!forceRefresh) {
      final cached = await _getFromCache(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        debugPrint('📍 Cache HIT for $type');
        return cached;
      }
    }

    debugPrint('🔍 USER LOCATION: ${position.latitude}, ${position.longitude}');
    debugPrint('🔍 Fetching $type with STRICT filters...');

    try {
      // 1. Initial Strict Fetch (Bounded by Viewbox)
      List<NearbyPlace> places = await _fetchFromNominatim(
        type: type,
        pos: position,
        useViewbox: true,
      );

      final double maxRadius = _getMaxRadius(type);
      
      // 2. Apply Hard Distance Filter
      List<NearbyPlace> filteredPlaces = places.where((p) {
        final dist = p.distanceMeters ?? 999999.0;
        return dist <= maxRadius;
      }).toList();

      debugPrint('📊 [$type] Total: ${places.length} | Filtered (within ${maxRadius}m): ${filteredPlaces.length} | Removed: ${places.length - filteredPlaces.length}');

      // 3. Fail-Safe Fallback
      if (filteredPlaces.isEmpty) {
        debugPrint('⚠️ No $type found within ${maxRadius}m. Activating Fallback...');
        
        // Fetch again without strict bounding box to find anything nearby
        places = await _fetchFromNominatim(
          type: type,
          pos: position,
          useViewbox: false, 
        );

        // Sort by distance and take nearest regardless of hard limit (up to 20km)
        places.sort((a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
        
        filteredPlaces = places.where((p) => (p.distanceMeters ?? 0) <= 20000).take(10).toList();
        debugPrint('🔄 Fallback: Found ${filteredPlaces.length} results within 20km');
      }

      // 4. Final Sort (Closest First)
      filteredPlaces.sort((a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));

      // Debug Log Each Place
      for (var p in filteredPlaces) {
        debugPrint('📍 ${p.name}: ${(p.distanceMeters! / 1000).toStringAsFixed(2)} km away');
      }

      if (filteredPlaces.isNotEmpty) {
        await _saveToCache(cacheKey, filteredPlaces);
      }
      
      return filteredPlaces;
    } catch (e) {
      debugPrint('❌ Places fetch failed: $e');
      return [];
    }
  }

  /// ✅ INTERNAL FETCH FROM NOMINATIM
  static Future<List<NearbyPlace>> _fetchFromNominatim({
    required String type,
    required Position pos,
    required bool useViewbox,
  }) async {
    final query = _getQuery(type);
    final lat = pos.latitude;
    final lon = pos.longitude;

    // Viewbox: lat ± 0.05, lon ± 0.05
    final minLon = (lon - 0.05).toStringAsFixed(6);
    final maxLat = (lat + 0.05).toStringAsFixed(6);
    final maxLon = (lon + 0.05).toStringAsFixed(6);
    final minLat = (lat - 0.05).toStringAsFixed(6);

    final baseUrl = 'https://nominatim.openstreetmap.org/search?format=json&limit=20&q=$query&lat=$lat&lon=$lon&addressdetails=1&countrycodes=in';
    
    String url = baseUrl;
    if (useViewbox) {
      url += '&bounded=1&viewbox=$minLon,$maxLat,$maxLon,$minLat';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'SafeStepApp/1.0 (support@safestep.com)',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    final List<NearbyPlace> results = [];

    for (final item in data) {
      try {
        final place = _parseNominatimItem(item, pos);
        if (place != null) {
          results.add(place);
        }
      } catch (e) {
        debugPrint('⚠️ Parse skipped: $e');
      }
    }

    return results;
  }

  static String _getQuery(String type) {
    return switch (type.toLowerCase()) {
      'hospital' => 'hospital',
      'pharmacy' => 'pharmacy',
      'police station' => 'police station',
      _ => type,
    };
  }

  static NearbyPlace? _parseNominatimItem(Map<String, dynamic> item, Position userPos) {
    final name = item['display_name']?.toString() ?? 'Unknown Place';
    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lon = double.tryParse(item['lon']?.toString() ?? '');

    if (lat == null || lon == null) return null;

    final distance = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      lat,
      lon,
    );

    return NearbyPlace(
      name: name.split(',').first,
      address: item['display_name'] ?? '',
      lat: lat,
      lng: lon,
      distanceMeters: distance,
      isOpen: true,
    );
  }

  static String _buildCacheKey(String type, Position pos) {
    final lat = pos.latitude.toStringAsFixed(4);
    final lon = pos.longitude.toStringAsFixed(4);
    return '$_cacheKeyPrefix${type}_${lat}_$lon';
  }

  static Future<List<NearbyPlace>?> _getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;

      final data = json.decode(jsonString);
      final expiry = DateTime.parse(data['expiry']);

      if (DateTime.now().isAfter(expiry)) {
        await prefs.remove(key);
        return null;
      }

      final list = (data['places'] as List)
          .map((p) => NearbyPlace.fromJson(p))
          .toList();

      return list;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveToCache(String key, List<NearbyPlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiry = DateTime.now().add(const Duration(minutes: _cacheExpiryMinutes));
      final data = {
        'places': places.map((p) => p.toJson()).toList(),
        'expiry': expiry.toIso8601String(),
      };
      await prefs.setString(key, json.encode(data));
    } catch (_) {}
  }
}
