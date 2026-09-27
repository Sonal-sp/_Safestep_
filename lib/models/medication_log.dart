import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Medication log for Firestore "medication_logs" collection.
class MedicationLog {
  final String id;
  final String medicationId;
  final String userId;
  final String status; // 'taken' | 'skipped'
  final DateTime timestamp;
  final String date; // YYYY-MM-DD for easy querying

  const MedicationLog({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.status,
    required this.timestamp,
    required this.date,
  });

  factory MedicationLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    return MedicationLog(
      id: doc.id,
      medicationId: data['medicationId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      status: data['status'] as String? ?? 'taken',
      timestamp: ts,
      date: data['date'] as String? ?? DateFormat('yyyy-MM-dd').format(ts),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'medicationId': medicationId,
        'userId': userId,
        'status': status,
        'timestamp': Timestamp.fromDate(timestamp),
        'date': date,
      };
}
