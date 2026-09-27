import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/shell_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = ref.watch(profileProvider).valueOrNull;
    final displayName = profile?.name ?? 'User';
    final safetyScore = ref.watch(safetyScoreProvider);

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GREETING & DATE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            style: theme.textTheme.displayMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: cs.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(_now),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 28),

                // 2. SAFETY SCORE CARD
                _SafetyScoreCard(score: safetyScore),
                const SizedBox(height: 24),

                // 3. QUICK ACTIONS
                Text('Quick Actions', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _QuickActionsRow(),
                const SizedBox(height: 28),

                // 4. AI INSIGHTS CARD
                _AiInsightsCard(),
                const SizedBox(height: 28),

                // 5. MEDICINE SUMMARY
                _MedicineSummaryCard(),
                const SizedBox(height: 28),

                // 6. RECENT ACTIVITY
                _RecentActivitySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = _now.hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}

class _SafetyScoreCard extends StatelessWidget {
  const _SafetyScoreCard({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = AppColors.safetySafe;
      scoreLabel = 'Excellent';
    } else if (score >= 50) {
      scoreColor = AppColors.safetyModerate;
      scoreLabel = 'Moderate';
    } else {
      scoreColor = AppColors.safetyRisky;
      scoreLabel = 'Needs Attention';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score circle
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withAlpha(40),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scoreLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Based on medication adherence',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.medication_rounded,
            label: 'Medicines',
            color: cs.primary,
            onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 1,
          ),
          _QuickActionChip(
            icon: Icons.contacts_rounded,
            label: 'Contacts',
            color: AppColors.secondary,
            onTap: () => context.push('/contacts'),
          ),
          _QuickActionChip(
            icon: Icons.local_hospital_rounded,
            label: 'Nearby',
            color: AppColors.error,
            onTap: () => context.push('/nearby-places'),
          ),
          _QuickActionChip(
            icon: Icons.share_location_rounded,
            label: 'Track',
            color: AppColors.warning,
            onTap: () => context.push('/live-tracking'),
          ),
          _QuickActionChip(
            icon: Icons.report_rounded,
            label: 'Report',
            color: AppColors.textSecondary,
            onTap: () => context.push('/report-incident'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
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
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/insights'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withAlpha(180)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Health Insights', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'View personalized safety analysis',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: cs.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final statuses = ref.watch(medicineStatusesProvider(todayStr));

    final taken = statuses.values
        .where((s) => s == MedicationStatus.taken)
        .length;
    final missed = statuses.values
        .where((s) => s == MedicationStatus.missed)
        .length;
    final upcoming = statuses.values
        .where((s) => s == MedicationStatus.upcoming)
        .length;
    final total = statuses.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Medicines", style: theme.textTheme.titleSmall),
              Text('$taken/$total taken', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          if (total == 0)
            Text('No medications scheduled', style: theme.textTheme.bodyMedium)
          else ...[
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total > 0 ? taken / total : 0,
                minHeight: 8,
                backgroundColor: cs.outline.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MedStatBadge(
                  label: 'Taken',
                  count: taken,
                  color: AppColors.medicineTakenText,
                  bgColor: AppColors.medicineTaken,
                ),
                _MedStatBadge(
                  label: 'Missed',
                  count: missed,
                  color: AppColors.medicineMissedText,
                  bgColor: AppColors.medicineMissed,
                ),
                _MedStatBadge(
                  label: 'Upcoming',
                  count: upcoming,
                  color: AppColors.medicineUpcomingText,
                  bgColor: AppColors.medicineUpcoming,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MedStatBadge extends StatelessWidget {
  const _MedStatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sosAlerts = ref.watch(sosAlertsProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: () =>
                  ref.read(selectedTabIndexProvider.notifier).state = 3,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (sosAlerts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No recent alerts. Everything looks great!',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        else
          Builder(
            builder: (context) {
              return Column(
                children: sosAlerts
                    .take(3)
                    .map(
                      (alert) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.emergency_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SOS Alert',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'MMM d, hh:mm a',
                                    ).format(alert.timestamp),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: alert.status == 'resolved'
                                    ? AppColors.medicineTaken
                                    : AppColors.medicineMissed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                alert.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: alert.status == 'resolved'
                                      ? AppColors.medicineTakenText
                                      : AppColors.medicineMissedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }
}
