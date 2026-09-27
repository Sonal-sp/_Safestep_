import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';

/// Battery monitoring service for low-battery safety mode.
/// Triggers at < 10% battery to auto-send location.
class BatteryService {
  static final BatteryService _instance = BatteryService._();
  factory BatteryService() => _instance;
  BatteryService._();

  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSub;

  final _batteryController = StreamController<int>.broadcast();
  final _lowBatteryController = StreamController<bool>.broadcast();

  Stream<int> get batteryLevel => _batteryController.stream;
  Stream<bool> get isLowBattery => _lowBatteryController.stream;

  int _currentLevel = 100;
  bool _isLow = false;
  bool _alertSent = false;
  Timer? _pollingTimer;

  int get currentLevel => _currentLevel;
  bool get isLow => _isLow;

  /// Start monitoring battery level
  void startMonitoring() {
    _batteryStateSub?.cancel();
    _batteryStateSub = _battery.onBatteryStateChanged.listen((BatteryState state) {
      _checkBattery();
    });

    // Poll battery every 60 seconds as a fallback
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkBattery();
    });
    _checkBattery(); // Initial check
  }

  void stopMonitoring() {
    _batteryStateSub?.cancel();
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkBattery() async {
    try {
      _currentLevel = await _battery.batteryLevel;
      
      _batteryController.add(_currentLevel);

      final wasLow = _isLow;
      _isLow = _currentLevel <= 10;
      _lowBatteryController.add(_isLow);

      // Trigger alert only once when battery drops below threshold
      if (_isLow && !wasLow && !_alertSent) {
        _alertSent = true;
        _onLowBattery();
      }

      // Reset alert flag when battery is charged above threshold
      if (!_isLow && wasLow) {
        _alertSent = false;
      }
    } catch (e) {
      debugPrint('BatteryService error: $e');
    }
  }

  void _onLowBattery() {
    // This will be handled by the provider layer which listens to isLowBattery
    debugPrint('⚡ LOW BATTERY DETECTED: $_currentLevel%');
  }

  /// Manually set battery level (for testing or platform channel updates)
  void updateBatteryLevel(int level) {
    _currentLevel = level;
    _batteryController.add(level);

    final wasLow = _isLow;
    _isLow = level <= 10;
    _lowBatteryController.add(_isLow);

    if (_isLow && !wasLow && !_alertSent) {
      _alertSent = true;
      _onLowBattery();
    }
    if (!_isLow && wasLow) {
      _alertSent = false;
    }
  }

  void dispose() {
    _batteryStateSub?.cancel();
    _pollingTimer?.cancel();
    _batteryController.close();
    _lowBatteryController.close();
  }
}
