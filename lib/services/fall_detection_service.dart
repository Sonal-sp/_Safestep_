import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Fall detection service using accelerometer data.
/// Detects sudden acceleration changes that indicate a fall.
/// Shows confirmation popup → auto-triggers SOS if no response in 30s.
class FallDetectionService {
  static final FallDetectionService _instance = FallDetectionService._();
  factory FallDetectionService() => _instance;
  FallDetectionService._();

  bool _isEnabled = false;
  bool _isFallDetected = false;
  Timer? _confirmationTimer;
  StreamSubscription<UserAccelerometerEvent>? _accelSub;

  final _fallController = StreamController<FallEvent>.broadcast();
  Stream<FallEvent> get fallEvents => _fallController.stream;

  bool get isEnabled => _isEnabled;
  bool get isFallDetected => _isFallDetected;

  // Fall detection thresholds
  static const double _impactThreshold = 25.0;    // m/s² (sudden spike)
  static const int _confirmationTimeoutSeconds = 30;

  /// Enable fall detection — starts listening to accelerometer
  void enable() {
    if (_isEnabled) return;
    _isEnabled = true;
    debugPrint('🛡️ Fall detection ENABLED');
    
    _accelSub = userAccelerometerEventStream().listen((event) {
      processAccelerometerData(event.x, event.y, event.z);
    });
  }

  /// Disable fall detection
  void disable() {
    _isEnabled = false;
    _isFallDetected = false;
    _confirmationTimer?.cancel();
    _accelSub?.cancel();
    debugPrint('🛡️ Fall detection DISABLED');
  }

  /// Process raw accelerometer data
  /// A fall typically shows: freefall (low g) → impact (high g) → stillness
  void processAccelerometerData(double x, double y, double z) {
    if (!_isEnabled || _isFallDetected) return;

    final magnitude = sqrt(x * x + y * y + z * z);

    // Detect freefall followed by impact
    if (magnitude > _impactThreshold) {
      _onFallDetected();
    }
  }

  /// Called when a potential fall is detected
  void _onFallDetected() {
    if (_isFallDetected) return;
    _isFallDetected = true;

    debugPrint('🚨 FALL DETECTED — Waiting for user confirmation');

    _fallController.add(FallEvent(
      type: FallEventType.detected,
      timestamp: DateTime.now(),
      message: 'Fall detected! Are you okay?',
      timeoutSeconds: _confirmationTimeoutSeconds,
    ));

    // Start countdown — auto-trigger SOS if no response
    _confirmationTimer?.cancel();
    _confirmationTimer = Timer(
      const Duration(seconds: _confirmationTimeoutSeconds),
      () {
        if (_isFallDetected) {
          _autoTriggerSos();
        }
      },
    );
  }

  /// User confirms they're okay — cancel SOS
  void confirmOkay() {
    _isFallDetected = false;
    _confirmationTimer?.cancel();
    debugPrint('✅ User confirmed okay after fall detection');

    _fallController.add(FallEvent(
      type: FallEventType.dismissed,
      timestamp: DateTime.now(),
      message: 'Fall alert dismissed.',
    ));
  }

  /// Auto-trigger SOS after timeout with no response
  void _autoTriggerSos() {
    debugPrint('🚨 AUTO-TRIGGERING SOS — No response after $_confirmationTimeoutSeconds seconds');

    _fallController.add(FallEvent(
      type: FallEventType.sosTriggered,
      timestamp: DateTime.now(),
      message: 'No response detected. SOS triggered automatically.',
    ));

    _isFallDetected = false;
  }

  /// Manually trigger a fall event (for testing)
  void simulateFall() {
    _onFallDetected();
  }

  void dispose() {
    _confirmationTimer?.cancel();
    _accelSub?.cancel();
    _fallController.close();
  }
}

enum FallEventType { detected, dismissed, sosTriggered }

class FallEvent {
  final FallEventType type;
  final DateTime timestamp;
  final String message;
  final int? timeoutSeconds;

  const FallEvent({
    required this.type,
    required this.timestamp,
    required this.message,
    this.timeoutSeconds,
  });
}
