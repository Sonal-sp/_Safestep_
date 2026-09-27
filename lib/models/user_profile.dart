import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile stored in Firestore "profiles" collection.
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bloodType;
  final String language;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bloodType,
    required this.language,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      bloodType: data['bloodType'] as String? ?? '',
      language: data['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'age': age,
        'bloodType': bloodType,
        'language': language,
      };

  UserProfile copyWith({
    String? name,
    int? age,
    String? bloodType,
    String? language,
  }) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        age: age ?? this.age,
        bloodType: bloodType ?? this.bloodType,
        language: language ?? this.language,
      );
}
