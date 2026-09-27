import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>(
  (ref) => FirebaseService(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final profileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(firebaseServiceProvider).profileStream(user.uid).map((data) {
    if (data == null) return null;
    return UserProfile(
      id: data['id'] as String? ?? user.uid,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      bloodType: data['bloodType'] as String? ?? '',
      language: data['language'] as String? ?? 'en',
    );
  });
});
