import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../services/notification_service.dart';
import '../../../models/medication.dart';
import '../../../models/medication_log.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/constants/app_colors.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final medsAsync = ref.watch(medicationsProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final statuses = ref.watch(medicineStatusesProvider(dateStr));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: () async {
              await context.push('/medicine-form');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _DateSelector(
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: medsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading medications',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                data: (meds) {
                  // Filter by selected date
                  final filteredMeds = meds
                      .where((m) => m.scheduleDate == dateStr)
                      .toList();

                  // Sort upcoming medicines first, then by time
                  filteredMeds.sort((a, b) {
                    final statusA = statuses[a.id] ?? MedicationStatus.upcoming;
                    final statusB = statuses[b.id] ?? MedicationStatus.upcoming;

                    if (statusA == MedicationStatus.upcoming &&
                        statusB != MedicationStatus.upcoming) {
                      return -1;
                    }
                    if (statusA != MedicationStatus.upcoming &&
                        statusB == MedicationStatus.upcoming) {
                      return 1;
                    }

                    return a.time.compareTo(b.time);
                  });

                  if (filteredMeds.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_rounded,
                            size: 64,
                            color: cs.onSurfaceVariant.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No medications scheduled',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => context.push('/medicine-form'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Medicine'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(medicationsProvider.future),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      itemCount: filteredMeds.length,
                      itemBuilder: (context, index) {
                        final med = filteredMeds[index];
                        final status =
                            statuses[med.id] ?? MedicationStatus.upcoming;

                        return Dismissible(
                          key: Key(med.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) async {
                            try {
                              await ref
                                  .read(firebaseServiceProvider)
                                  .deleteMedication(med.id);
                              SnackbarUtils.show(
                                'Medicine deleted successfully',
                              );
                            } catch (e) {
                              SnackbarUtils.showFirestoreError(e);
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _statusBgColor(status),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          _statusIcon(status),
                                          color: _statusTextColor(status),
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              med.name,
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${med.dosage} • ${med.time} • ${med.frequency}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusBgColor(status),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          status.name[0].toUpperCase() +
                                              status.name.substring(1),
                                          style: TextStyle(
                                            color: _statusTextColor(status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (status != MedicationStatus.taken &&
                                      status != MedicationStatus.skipped) ...[
                                    const SizedBox(height: 12),
                                    Divider(
                                      height: 1,
                                      color: cs.outlineVariant,
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () =>
                                              _logMedication(med, 'skipped'),
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: cs.onSurfaceVariant,
                                          ),
                                          label: Text(
                                            'Skip',
                                            style: TextStyle(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton.icon(
                                          onPressed: () =>
                                              _logMedication(med, 'taken'),
                                          icon: const Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                          ),
                                          label: const Text('Mark Taken'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  33,
                                                  179,
                                                  92,
                                                ),
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(130, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBgColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return AppColors.medicineTaken;
      case MedicationStatus.missed:
        return AppColors.medicineMissed;
      case MedicationStatus.upcoming:
        return AppColors.medicineUpcoming;
      case MedicationStatus.skipped:
        return AppColors.medicineSkipped;
    }
  }

  Color _statusTextColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return AppColors.medicineTakenText;
      case MedicationStatus.missed:
        return AppColors.medicineMissedText;
      case MedicationStatus.upcoming:
        return AppColors.medicineUpcomingText;
      case MedicationStatus.skipped:
        return AppColors.medicineSkippedText;
    }
  }

  IconData _statusIcon(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return Icons.check_circle_rounded;
      case MedicationStatus.missed:
        return Icons.error_rounded;
      case MedicationStatus.upcoming:
        return Icons.schedule_rounded;
      case MedicationStatus.skipped:
        return Icons.skip_next_rounded;
    }
  }

  Future<void> _logMedication(Medication med, String status) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final now = _selectedDate;
      final log = MedicationLog(
        id: const Uuid().v4(),
        medicationId: med.id,
        userId: user.uid,
        status: status,
        timestamp: now,
        date: DateFormat('yyyy-MM-dd').format(now),
      );

      await ref.read(firebaseServiceProvider).addMedicationLog(log);
      if (status == 'taken') {
        await NotificationService().cancelMedicineReminder(med.id);
      }
      if (status == 'taken') {
        SnackbarUtils.show('Medication marked as taken ✅');
      } else {
        SnackbarUtils.show('Medication skipped');
      }
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? null
                    : Border.all(color: cs.outlineVariant),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cs.primary.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
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
