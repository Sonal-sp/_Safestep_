import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/sos_service.dart';
import '../../../services/fall_detection_service.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rippleController;

  bool _isTriggered = false;
  bool _isCountingDown = false;
  int _countdown = 5;
  Timer? _countdownTimer;
  StreamSubscription? _fallSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Listen for fall detection events
    _fallSub = FallDetectionService().fallEvents.listen(_handleFallEvent);
  }

  void _handleFallEvent(FallEvent event) {
    if (event.type == FallEventType.sosTriggered) {
      _executeSos(triggerSource: 'fall_detection');
    }
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 5;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _executeSos();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdown = 5;
    });
  }

  Future<void> _executeSos({String triggerSource = 'manual'}) async {
    _countdownTimer?.cancel();
    setState(() {
      _isCountingDown = false;
      _isTriggered = true;
    });

    final contacts = ref.read(contactsProvider).valueOrNull ?? [];
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    final result = await SosService().triggerSos(
      userId: uid,
      contacts: contacts,
      triggerSource: triggerSource,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success
              ? AppColors.secondary
              : AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showNoContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person_add_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('No Emergency Contact'),
            ],
          ),
          content: const Text(
            'You haven\'t added any emergency contacts yet. '
            'Add a contact to use the SOS feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('LATER'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/contact-form');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD CONTACT'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 48)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _countdownTimer?.cancel();
    _fallSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Header
                Text('Emergency Help', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  _isCountingDown
                      ? 'SOS will trigger in $_countdown seconds...\nTap anywhere to cancel.'
                      : _isTriggered
                      ? 'SOS Triggered! Help is on the way.'
                      : 'Press and hold the button below to\ntrigger an emergency alert.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: _isCountingDown ? AppColors.error : null,
                    fontWeight: _isCountingDown ? FontWeight.w700 : null,
                  ),
                ),
                const SizedBox(height: 60),

                // SOS BUTTON with ripple effect
                GestureDetector(
                  onTap: () {
                    if (_isCountingDown) {
                      _cancelCountdown();
                    } else if (!_isTriggered) {
                      final contacts =
                          ref.read(contactsProvider).valueOrNull ?? [];
                      if (contacts.isEmpty) {
                        _showNoContactDialog();
                      } else {
                        _startCountdown();
                      }
                    }
                  },
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple rings
                        ...List.generate(3, (i) {
                          return AnimatedBuilder(
                            animation: _rippleController,
                            builder: (_, _) {
                              final progress =
                                  (_rippleController.value + i * 0.33) % 1.0;
                              return Container(
                                width: 200 + (progress * 80),
                                height: 200 + (progress * 80),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        (_isCountingDown || _isTriggered
                                                ? AppColors.error
                                                : AppColors.error.withAlpha(30))
                                            .withAlpha(
                                              ((1 - progress) * 80).toInt(),
                                            ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Main button
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isTriggered
                                  ? AppColors.secondary
                                  : AppColors.error,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isTriggered
                                              ? AppColors.secondary
                                              : AppColors.error)
                                          .withAlpha(100),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withAlpha(200),
                                width: 6,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isCountingDown)
                                    Text(
                                      '$_countdown',
                                      style: const TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    )
                                  else if (_isTriggered)
                                    const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 64,
                                    )
                                  else ...[
                                    const Icon(
                                      Icons.emergency_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'SOS',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Quick actions row
                if (!_isTriggered && !_isCountingDown)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickAction(
                        icon: Icons.local_hospital_rounded,
                        label: 'Nearby\nHospitals',
                        color: AppColors.error,
                        onTap: () => context.push('/nearby-places'),
                      ),
                      _QuickAction(
                        icon: Icons.share_location_rounded,
                        label: 'Share\nLocation',
                        color: cs.primary,
                        onTap: () => context.push('/live-tracking'),
                      ),
                      _QuickAction(
                        icon: Icons.report_rounded,
                        label: 'Report\nIncident',
                        color: AppColors.warning,
                        onTap: () => context.push('/report-incident'),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // Emergency contacts section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: theme.textTheme.titleSmall,
                    ),
                    TextButton(
                      onPressed: () => context.push('/contacts'),
                      child: const Text('Manage'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                contactsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    'Error loading contacts',
                    style: theme.textTheme.bodyMedium,
                  ),
                  data: (contacts) {
                    if (contacts.isEmpty) {
                      return OutlinedButton.icon(
                        onPressed: () => context.push('/contact-form'),
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Add Emergency Contact'),
                      );
                    }
                    return SizedBox(
                      height: 88,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final c = contacts[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.isPrimary
                                        ? AppColors.error.withAlpha(25)
                                        : cs.primaryContainer.withAlpha(40),
                                    border: c.isPrimary
                                        ? Border.all(
                                            color: AppColors.error,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.name.isNotEmpty
                                          ? c.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: c.isPrimary
                                            ? AppColors.error
                                            : cs.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.name.split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: c.isPrimary
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
