import 'dart:async';
import 'dart:io'; // ✅ IMPORTANT
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  StreamSubscription<Position>? _positionStreamSub;
  final _locationController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _locationController.stream;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// ✅ Handle Permissions
  Future<bool> handlePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    // Background permission (Android)
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        debugPrint('⚠️ Background location not granted');
      }
    }

    return true;
  }

  /// ✅ Start Tracking
  Future<void> startTracking() async {
    if (_isTracking) return;

    final hasPermission = await handlePermissions();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    _isTracking = true;

    LocationSettings locationSettings;

    if (!kIsWeb && Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Guardian Mode Active",
          notificationText: "SafeStep is protecting you",
          enableWakeLock: true,
        ),
      );
    } else if (!kIsWeb && Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      // Web / fallback
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _locationController.add(position);
        debugPrint('📍 ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        debugPrint('❌ Stream Error: $error');
        stopTracking();
      },
    );
  }

  /// ✅ Stop Tracking
  void stopTracking() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _isTracking = false;
    debugPrint('🛑 Tracking stopped');
  }

  /// ✅ Get Current Location
  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('❌ Get Location Error: $e');
      return await Geolocator.getLastKnownPosition();
    }
  }
}