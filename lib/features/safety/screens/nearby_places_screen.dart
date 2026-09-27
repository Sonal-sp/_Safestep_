import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/osrm_service.dart';
import '../../../services/places_service.dart';
import '../../../models/nearby_place.dart';

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  Position? _currentPosition;
  bool _isLoading = true;
  String? _error;

  List<NearbyPlace> _places = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /// ✅ HIGH ACCURACY LOCATION
  Future<void> _initLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint("📍 REAL LOCATION: ${pos.latitude}, ${pos.longitude}");

      _currentPosition = pos;
      await _fetchNearbyPlaces(pos);
    } catch (e) {
      setState(() => _error = "Location error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ FETCH NEARBY PLACES (DELEGATED TO SERVICE)
  Future<void> _fetchNearbyPlaces(Position pos) async {
    try {
      final results = await Future.wait([
        PlacesService.getNearby(
          type: 'hospital',
          position: pos,
          forceRefresh: true,
        ),
        PlacesService.getNearby(
          type: 'pharmacy',
          position: pos,
          forceRefresh: true,
        ),
        PlacesService.getNearby(
          type: 'police station',
          position: pos,
          forceRefresh: true,
        ),
      ]);

      // Flatten results
      final allPlaces = results.expand((x) => x).toList();

      // Final sort across all categories
      allPlaces.sort(
        (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
      );

      setState(() {
        _places = allPlaces.take(20).toList();
      });

      debugPrint("✅ UI: Displaying ${_places.length} nearby places");
    } catch (e) {
      debugPrint("❌ UI Fetch Error: $e");
      setState(() => _error = "Failed to fetch nearby places");
    }
  }

  /// ✅ OSRM ROUTE
  Future<void> _getRoute(NearbyPlace place) async {
    if (_currentPosition == null) return;

    final route = await OsrmService.getRoute(
      source: _currentPosition!,
      destination: place.position,
    );

    if (route != null) {
      setState(() {
        place.updateRoute(route);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Route not found")));
      }
    }
  }

  /// ✅ GOOGLE MAPS
  Future<void> _openInMaps(NearbyPlace place) async {
    final url = Uri.parse(
      "https://www.google.com/maps?q=${place.lat},${place.lng}",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Safe Places')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _places.isEmpty
          ? const Center(child: Text("No nearby places found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    title: Text(
                      place.name,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.address),
                        const SizedBox(height: 4),
                        Text(
                          place.straightDistance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        if (place.formattedDistance != null)
                          Text(
                            "Route: ${place.formattedDistance} • ${place.formattedDuration}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () => _openInMaps(place),
                        ),
                        IconButton(
                          icon: const Icon(Icons.route),
                          onPressed: () => _getRoute(place),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
