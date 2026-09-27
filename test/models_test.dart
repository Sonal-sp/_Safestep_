import 'package:flutter_test/flutter_test.dart';
import 'package:safestep/models/emergency_contact.dart';
import 'package:safestep/models/medical_history_entry.dart';
import 'package:safestep/models/medication.dart';
import 'package:safestep/models/sos_alert.dart';
import 'package:safestep/models/user_profile.dart';

void main() {
  group('Medication Model Tests', () {
    test('creates and converts to map properly', () {
      final med = Medication(
        id: 'med_001',
        userId: 'user_001',
        name: 'Paracetamol',
        dosage: '500mg',
        time: '08:00',
        frequency: 'Daily',
        scheduleDate: '2026-09-27',
      );

      final map = med.toFirestore();
      expect(map['name'], 'Paracetamol');
      expect(map['dosage'], '500mg');
      expect(map['time'], '08:00');
      expect(map['userId'], 'user_001');
      expect(map['scheduleDate'], '2026-09-27');
    });

    test('copyWith works correctly', () {
      final med = Medication(
        id: 'med_002',
        userId: 'user_001',
        name: 'Crocin',
        dosage: '650mg',
        time: '14:00',
        frequency: 'Daily',
      );

      final updated = med.copyWith(dosage: '1000mg', frequency: 'Weekly');
      expect(updated.id, 'med_002');
      expect(updated.name, 'Crocin');
      expect(updated.dosage, '1000mg');
      expect(updated.frequency, 'Weekly');
    });
  });

  group('EmergencyContact Model Tests', () {
    test('serializes to Firestore map properly', () {
      final contact = EmergencyContact(
        id: 'contact_01',
        userId: 'user_001',
        name: 'Sonali Parmar',
        phone: '+919876543210',
        relationship: 'Daughter',
        isPrimary: true,
      );

      final map = contact.toFirestore();
      expect(map['name'], 'Sonali Parmar');
      expect(map['phone'], '+919876543210');
      expect(map['relationship'], 'Daughter');
      expect(map['isPrimary'], true);
    });
  });

  group('MedicalHistoryEntry Model Tests', () {
    test('creates entry and formats correctly', () {
      final now = DateTime.now();
      final entry = MedicalHistoryEntry(
        id: 'hist_01',
        userId: 'user_001',
        title: 'Type 2 Diabetes',
        type: 'condition',
        notes: 'Diagnosed in 2020, taking Metformin',
        dateTime: now,
      );

      final map = entry.toFirestore();
      expect(map['title'], 'Type 2 Diabetes');
      expect(map['type'], 'condition');
      expect(entry.subtitle, isNotEmpty);
    });
  });

  group('SosAlert Model Tests', () {
    test('creates SOS alert record', () {
      final alert = SosAlert(
        id: 'sos_123',
        userId: 'user_001',
        timestamp: DateTime.now(),
        latitude: 19.0760,
        longitude: 72.8777,
        contactsCalled: 'Sonali, Namira',
        status: 'triggered',
        triggerSource: 'hardware_sensor',
      );

      final map = alert.toFirestore();
      expect(map['status'], 'triggered');
      expect(map['triggerSource'], 'hardware_sensor');
      expect(map['latitude'], 19.0760);
      expect(map['contactsCalled'], 'Sonali, Namira');
    });
  });

  group('UserProfile Model Tests', () {
    test('creates profile and supports copyWith', () {
      final profile = UserProfile(
        id: 'user_001',
        name: 'Sonal',
        age: 72,
        bloodType: 'O+',
        language: 'mr',
      );

      final updated = profile.copyWith(language: 'hi');
      expect(updated.name, 'Sonal');
      expect(updated.bloodType, 'O+');
      expect(updated.language, 'hi');
    });
  });
}
