import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalHistoryEntry {
  final String id;
  final String userId;
  final String title;
  final String medications;
  final String notes;
  final DateTime dateTime;
  final String type; // condition, prescription, report

  const MedicalHistoryEntry({
    required this.id,
    required this.userId,
    required this.title,
    this.medications = '',
    required this.notes,
    required this.dateTime,
    this.type = 'condition',
  });

  factory MedicalHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;

    DateTime parsedDate = DateTime.now();
    if (data['dateTime'] is Timestamp) {
      parsedDate = (data['dateTime'] as Timestamp).toDate();
    } else if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date'] as String) ?? DateTime.now();
    } else if (data['dateTime'] is String) {
      parsedDate = DateTime.tryParse(data['dateTime'] as String) ?? DateTime.now();
    }

    return MedicalHistoryEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? data['condition'] as String? ?? '',
      medications: data['medications'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      dateTime: parsedDate,
      type: data['type'] as String? ?? 'condition',
    );
  }

  String get subtitle => "${medications.isNotEmpty ? '$medications • ' : ''}$notes";

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'medications': medications,
        'notes': notes,
        'dateTime': Timestamp.fromDate(dateTime),
        'date': Timestamp.fromDate(dateTime), // Legacy support
        'type': type,
      };
}
