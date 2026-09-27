import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/emergency_contact.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../models/medical_history_entry.dart';
import '../models/sos_alert.dart';
import '../models/incident_report.dart';
import '../models/location_session.dart';
import 'auth_provider.dart';

enum MedicationStatus { upcoming, taken, missed, skipped }

final medicationsProvider = StreamProvider<List<Medication>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).medicationsStream(uid);
});

final medicationLogsProvider =
    StreamProvider.family<List<MedicationLog>, String>((ref, dateStr) {
      final uid = ref.watch(currentUserProvider)?.uid;
      if (uid == null) return Stream.value([]);
      return ref
          .watch(firebaseServiceProvider)
          .medicationLogsByDateStream(uid, dateStr);
    });

final contactsProvider = StreamProvider<List<EmergencyContact>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).contactsStream(uid);
});

final medicalHistoryProvider = StreamProvider<List<MedicalHistoryEntry>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).medicalHistoryStream(uid);
});

final sosAlertsProvider = StreamProvider<List<SosAlert>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).sosAlertsStream(uid);
});

final incidentReportsProvider = StreamProvider<List<IncidentReport>>((ref) {
  return ref.watch(firebaseServiceProvider).incidentReportsStream();
});

final activeLocationSessionProvider = StreamProvider<LocationSession?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(firebaseServiceProvider).activeLocationSession(uid);
});

final realTimeClockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 30),
    (_) => DateTime.now(),
  ).startWith(DateTime.now());
});

extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

/// Provides medication logs for today using the 'date' field.
/// Legacy provider for today - can be used by other screens
final medicationLogsTodayProvider = StreamProvider<List<MedicationLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);

  final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return ref
      .watch(firebaseServiceProvider)
      .medicationLogsByDateStream(uid, dateStr);
});

final medicineStatusesProvider =
    Provider.family<Map<String, MedicationStatus>, String>((ref, dateStr) {
      final medsAsync = ref.watch(medicationsProvider);
      final logsAsync = ref.watch(medicationLogsProvider(dateStr));

      // ⏱ real-time clock (updates every 30 sec)
      final now = ref.watch(realTimeClockProvider).value ?? DateTime.now();

      return medsAsync.when(
        data: (meds) {
          return logsAsync.when(
            data: (logs) {
              final todayStr = DateFormat('yyyy-MM-dd').format(now);

              Map<String, MedicationStatus> statuses = {};

              for (final med in meds) {
                // ✅ only consider selected date
                if (med.scheduleDate != dateStr) continue;

                // 🔍 check if user already logged
                final logList = logs
                    .where((l) => l.medicationId == med.id)
                    .toList();

                if (logList.isNotEmpty) {
                  final status = logList.first.status;

                  if (status == 'taken') {
                    statuses[med.id] = MedicationStatus.taken;
                  } else if (status == 'skipped') {
                    statuses[med.id] = MedicationStatus.skipped;
                  } else {
                    statuses[med.id] = MedicationStatus.upcoming;
                  }
                } else {
                  // ❗ NO LOG → AUTO DECISION

                  if (dateStr.compareTo(todayStr) < 0) {
                    // 🔴 PAST DATE
                    statuses[med.id] = MedicationStatus.missed;
                  } else if (dateStr.compareTo(todayStr) > 0) {
                    // 🔵 FUTURE DATE
                    statuses[med.id] = MedicationStatus.upcoming;
                  } else {
                    // 🟢 TODAY → TIME CHECK

                    DateTime? medTime;

                    try {
                      medTime = DateFormat('HH:mm').parse(med.time);
                    } catch (_) {
                      try {
                        medTime = DateFormat('hh:mm a').parse(med.time);
                      } catch (_) {
                        medTime = null;
                      }
                    }

                    if (medTime != null) {
                      final nowMinutes = now.hour * 60 + now.minute;
                      final medMinutes = medTime.hour * 60 + medTime.minute;

                      // Debug: now $nowMinutes, med $medMinutes

                      if (nowMinutes >= medMinutes) {
                        statuses[med.id] = MedicationStatus.missed; // 🔥 FIXED
                      } else {
                        statuses[med.id] = MedicationStatus.upcoming;
                      }
                    } else {
                      // Debug: time parse failed: ${med.time}
                      statuses[med.id] = MedicationStatus.upcoming;
                    }
                  }
                }
              }

              return statuses;
            },
            loading: () => {},
            error: (_, _) => {},
          );
        },
        loading: () => {},
        error: (_, _) => {},
      );
    });

/// Safety score based on medication adherence and SOS history
/// Safety score using today's statuses (for profile/dashboard)
final safetyScoreProvider = Provider<int>((ref) {
  final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final statuses = ref.watch(medicineStatusesProvider(dateStr));
  if (statuses.isEmpty) return 100;

  final total = statuses.length;
  final taken = statuses.values
      .where((s) => s == MedicationStatus.taken)
      .length;
  final upcoming = statuses.values
      .where((s) => s == MedicationStatus.upcoming)
      .length;

  // Score = (taken + upcoming) / total * 100
  final activeCount = taken + upcoming;
  return ((activeCount / total) * 100).round().clamp(0, 100);
});
