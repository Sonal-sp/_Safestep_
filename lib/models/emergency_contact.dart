import 'package:cloud_firestore/cloud_firestore.dart';

/// Emergency contact for Firestore "emergency_contacts" collection.
class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;

  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.isPrimary,
  });

  factory EmergencyContact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      relationship: data['relationship'] as String? ?? '',
      isPrimary: data['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'isPrimary': isPrimary,
      };
}
