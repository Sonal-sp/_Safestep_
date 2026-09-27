import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/location_service.dart';
import '../../../models/location_session.dart';

/// Live location tracking / Guardian Mode screen.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  final _destinationController = TextEditingController();
  StreamSubscription? _locationSub;
  LocationSession? _currentSession;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if we already have an active session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final active = ref.read(activeLocationSessionProvider).valueOrNull;
      if (active != null) {
        setState(() {
          _currentSession = active;
          _startListeningToLocation();
        });
      }
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _locationSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    final firebase = ref.read(firebaseServiceProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use live tracking.')),
      );
      return;
    }

    if (_currentSession != null) {
      // STOP TRACKING
      setState(() => _isLoading = true);
      try {
        LocationService().stopTracking();
        _locationSub?.cancel();
        await firebase.endLocationSession(_currentSession!.id);
        setState(() => _currentSession = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tracking stopped.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error stopping: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // START TRACKING
      setState(() => _isLoading = true);
      try {
        await LocationService().startTracking();
        final position = await LocationService().getCurrentLocation();
        
        if (position == null) throw Exception("Could not get current location");

        final sessionId = const Uuid().v4();
        final shareLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

        final session = LocationSession(
          id: sessionId,
          userId: user.uid,
          userName: user.displayName ?? 'User',
          latitude: position.latitude,
          longitude: position.longitude,
          destination: _destinationController.text.isNotEmpty ? _destinationController.text : null,
          startTime: DateTime.now(),
          shareLink: shareLink,
          lastUpdated: DateTime.now(),
        );

        await firebase.createLocationSession(session);

        setState(() {
          _currentSession = session;
          _startListeningToLocation();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live tracking started. Your contacts can now see your location.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _startListeningToLocation() {
    _locationSub?.cancel();
    _locationSub = LocationService().positionStream.listen((position) async {
      if (_currentSession != null) {
        final updatedLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
        final updatedSession = _currentSession!.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          shareLink: updatedLink,
          lastUpdated: DateTime.now(),
        );
        setState(() => _currentSession = updatedSession);
        await ref.read(firebaseServiceProvider).updateLocationSession(updatedSession);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isTracking = _currentSession != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Guardian Mode')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTracking
                      ? [AppColors.secondary, AppColors.secondaryDark]
                      : [cs.surface, cs.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: isTracking ? null : Border.all(color: cs.outline),
              ),
              child: Column(
                children: [
                  Icon(
                    isTracking ? Icons.my_location_rounded : Icons.location_disabled_rounded,
                    size: 48,
                    color: isTracking ? Colors.white : cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isTracking ? 'Sharing Live Location' : 'Location Sharing Off',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isTracking ? Colors.white : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTracking
                        ? 'Your emergency contacts can see where you are'
                        : 'Start sharing to let contacts track your journey',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isTracking ? Colors.white70 : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Destination field
            if (!isTracking)
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination (optional)',
                  hintText: 'Where are you going?',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
              ),
            const SizedBox(height: 24),

            // Start/Stop button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? AppColors.error : cs.primary,
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded),
                label: Text(isTracking ? 'Stop Sharing' : 'Start Journey'),
              ),
            ),
            const SizedBox(height: 32),

            // Share link section
            if (isTracking) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link_rounded, color: cs.primary),
                        const SizedBox(width: 12),
                        Text('Share Tracking Link', style: theme.textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentSession!.shareLink,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy_rounded, color: cs.primary, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _currentSession!.shareLink));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link copied!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: 'Track my live location on SafeStep: ${_currentSession!.shareLink}',
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share with Contacts'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Safety tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.medicineUpcoming.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Safety Tips', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _tipRow(theme, '• Share your tracking link before starting a trip'),
                  _tipRow(theme, '• Keep your phone charged above 20%'),
                  _tipRow(theme, '• Stay on well-lit, populated routes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(height: 1.6)),
    );
  }
}
