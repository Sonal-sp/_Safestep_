import 'package:cloud_firestore/cloud_firestore.dart';

/// Medication model for Firestore "medications" collection.
class Medication {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String time;
  final String frequency;
  final String? scheduleDate; // Form picker date
  final DateTime? createdAt;

  const Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    this.scheduleDate,
    this.createdAt,
  });

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      time: data['time'] as String? ?? '08:00',
      frequency: data['frequency'] as String? ?? 'daily',
      scheduleDate: data['scheduleDate'],
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'dosage': dosage,
    'time': time,
    'frequency': frequency,
    if (scheduleDate != null) 'scheduleDate': scheduleDate,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
  };

  Medication copyWith({
    String? name,
    String? dosage,
    String? time,
    String? frequency,
    String? scheduleDate,
    DateTime? createdAt,
  }) => Medication(
    id: id,
    userId: userId,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    time: time ?? this.time,
    frequency: frequency ?? this.frequency,
    scheduleDate: scheduleDate ?? this.scheduleDate,
    createdAt: createdAt ?? this.createdAt,
  );
}
