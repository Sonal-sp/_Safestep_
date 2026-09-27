import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safestep/core/utils/snackbar_utils.dart';

import '../models/emergency_contact.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../models/medical_history_entry.dart';
import '../models/sos_alert.dart';
import '../models/incident_report.dart';
import '../models/location_session.dart';
import 'package:intl/intl.dart';

/// Firebase CRUD and auth operations.
class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email already in use. Try a different one.';
          break;
        case 'weak-password':
          message = 'Password too weak. Use 6+ characters.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'operation-not-allowed':
          message = 'Sign-up disabled. Check Firebase Console.';
          break;
        default:
          message = 'Signup error: ${e.code} - ${e.message}';
      }
      throw Exception(message);
    }
  }

  Future<void> signOut() => _auth.signOut();

  // ============ PROFILES ============
  Future<void> createOrUpdateProfile(dynamic profile) async {
    try {
      await _firestore
          .collection('profiles')
          .doc(profile.id)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<Map<String, dynamic>?> profileStream(String userId) => _firestore
      .collection('profiles')
      .doc(userId)
      .snapshots()
      .map(
        (doc) => doc.exists
            ? {'id': doc.id, ...?doc.data() }
            : null,
      );

  // ============ MEDICATIONS ============
  Future<void> addMedication(Medication m) async {
    try {
      await _firestore.collection('medications').doc(m.id).set(m.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> updateMedication(Medication m) async {
    try {
      await _firestore
          .collection('medications')
          .doc(m.id)
          .update(m.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _firestore.collection('medications').doc(id).delete();
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<List<Medication>> medicationsStream(String userId) => _firestore
      .collection('medications')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Medication.fromFirestore(d)).toList());

  // ============ MEDICATION LOGS ============
  Future<void> addMedicationLog(MedicationLog log) async {
    try {
      await _firestore
          .collection('medication_logs')
          .doc(log.id)
          .set(log.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<List<MedicationLog>> getLogsForMedication(String medicationId) async {
    try {
      final snap = await _firestore
          .collection('medication_logs')
          .where('medicationId', isEqualTo: medicationId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snap.docs.map((d) => MedicationLog.fromFirestore(d)).toList();
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
      return [];
    }
  }

  Future<MedicationLog?> getLatestLogForMedicationOnDate(
    String medicationId,
    DateTime date,
  ) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      final snap = await _firestore
          .collection('medication_logs')
          .where('medicationId', isEqualTo: medicationId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThan: Timestamp.fromDate(end))
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      return snap.docs.isEmpty
          ? null
          : MedicationLog.fromFirestore(snap.docs.first);
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
      return null;
    }
  }

  Future<List<MedicationLog>> getLogsForUserInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snap = await _firestore
          .collection('medication_logs')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThan: Timestamp.fromDate(end))
          .get();
      
      return snap.docs.map((d) => MedicationLog.fromFirestore(d)).toList();
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
      return [];
    }
  }

  Stream<List<MedicationLog>> medicationLogsStream(
    String userId,
    DateTime start,
    DateTime end,
  ) => _firestore
      .collection('medication_logs')
      .where('userId', isEqualTo: userId)
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('timestamp', isLessThan: Timestamp.fromDate(end))
      .snapshots()
      .map((snap) {
        
        return snap.docs.map((d) => MedicationLog.fromFirestore(d)).toList();
      });

  Stream<List<MedicationLog>> medicationLogsByDateStream(
    String userId,
    String date,
  ) => _firestore
      .collection('medication_logs')
      .where('userId', isEqualTo: userId)
      .where('date', isEqualTo: date)
      .snapshots()
      .map((snap) {
        
        return snap.docs.map((d) => MedicationLog.fromFirestore(d)).toList();
      });

  /// Check if medication was logged as taken today
  Future<bool> isMedicationTakenToday(
    String medicationId, {
    String? userId,
  }) async {
    final uid = userId ?? this.userId;
    if (uid == null) return false;

    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final snap = await _firestore
          .collection('medication_logs')
          .where('userId', isEqualTo: uid)
          .where('medicationId', isEqualTo: medicationId)
          .where('date', isEqualTo: todayStr)
          .where('status', isEqualTo: 'taken')
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking taken status: $e');
      return false;
    }
  }

  // ============ MEDICAL HISTORY ============
  Future<void> addMedicalHistory(MedicalHistoryEntry e) async {
    try {
      await _firestore
          .collection('medical_history')
          .doc(e.id)
          .set(e.toFirestore());
    } catch (err) {
      SnackbarUtils.showFirestoreError(err);
    }
  }

  Future<void> updateMedicalHistory(MedicalHistoryEntry e) async {
    try {
      await _firestore
          .collection('medical_history')
          .doc(e.id)
          .update(e.toFirestore());
    } catch (err) {
      SnackbarUtils.showFirestoreError(err);
    }
  }

  Future<void> deleteMedicalHistory(String id) async {
    try {
      await _firestore.collection('medical_history').doc(id).delete();
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<List<MedicalHistoryEntry>> medicalHistoryStream(String userId) =>
      _firestore
          .collection('medical_history')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
            final entries = snap.docs
                .map((d) => MedicalHistoryEntry.fromFirestore(d))
                .toList();
            entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
            return entries;
          });

  // ============ EMERGENCY CONTACTS ============
  Future<void> addContact(EmergencyContact c) async {
    try {
      await _firestore
          .collection('emergency_contacts')
          .doc(c.id)
          .set(c.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> updateContact(EmergencyContact c) async {
    try {
      await _firestore
          .collection('emergency_contacts')
          .doc(c.id)
          .update(c.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _firestore.collection('emergency_contacts').doc(id).delete();
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> setPrimaryContact(String userId, String contactId) async {
    try {
      final batch = _firestore.batch();
      final contacts = await _firestore
          .collection('emergency_contacts')
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in contacts.docs) {
        batch.update(doc.reference, {'isPrimary': doc.id == contactId});
      }
      await batch.commit();
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<List<EmergencyContact>> contactsStream(String userId) => _firestore
      .collection('emergency_contacts')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) {
        
        return snap.docs.map((d) => EmergencyContact.fromFirestore(d)).toList();
      });

  // ============ SOS ALERTS ============
  Future<void> addSosAlert(SosAlert alert) async {
    try {
      await _firestore
          .collection('sos_alerts')
          .doc(alert.id)
          .set(alert.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> resolveSosAlert(String alertId) async {
    try {
      await _firestore.collection('sos_alerts').doc(alertId).update({
        'status': 'resolved',
      });
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<List<SosAlert>> sosAlertsStream(String userId) => _firestore
      .collection('sos_alerts')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) {
        
        return snap.docs.map((d) => SosAlert.fromFirestore(d)).toList();
      });

  // ============ INCIDENT REPORTS ============
  Future<void> addIncidentReport(IncidentReport report) async {
    try {
      await _firestore
          .collection('incident_reports')
          .doc(report.id)
          .set(report.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<List<IncidentReport>> incidentReportsStream() => _firestore
      .collection('incident_reports')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) {
        
        return snap.docs.map((d) => IncidentReport.fromFirestore(d)).toList();
      });

  Stream<List<IncidentReport>> nearbyIncidentsStream(
    double lat,
    double lng, {
    double radiusKm = 5.0,
  }) {
    // Simple bounding box filter (approximate)
    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / 111.0;

    return _firestore
        .collection('incident_reports')
        .where('latitude', isGreaterThan: lat - latDelta)
        .where('latitude', isLessThan: lat + latDelta)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((d) => IncidentReport.fromFirestore(d))
              .where(
                (r) =>
                    r.longitude >= lng - lngDelta &&
                    r.longitude <= lng + lngDelta,
              )
              .toList();
        });
  }

  // ============ LOCATION SESSIONS ============
  Future<void> createLocationSession(LocationSession session) async {
    try {
      await _firestore
          .collection('location_sessions')
          .doc(session.id)
          .set(session.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> updateLocationSession(LocationSession session) async {
    try {
      await _firestore
          .collection('location_sessions')
          .doc(session.id)
          .update(session.toFirestore());
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Future<void> endLocationSession(String sessionId) async {
    try {
      await _firestore.collection('location_sessions').doc(sessionId).update({
        'status': 'completed',
        'endTime': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      SnackbarUtils.showFirestoreError(e);
    }
  }

  Stream<LocationSession?> activeLocationSession(String userId) => _firestore
      .collection('location_sessions')
      .where('userId', isEqualTo: userId)
      .where('status', isEqualTo: 'active')
      .limit(1)
      .snapshots()
      .map(
        (snap) => snap.docs.isEmpty
            ? null
            : LocationSession.fromFirestore(snap.docs.first),
      );

  Stream<LocationSession?> locationSessionByLink(String shareLink) => _firestore
      .collection('location_sessions')
      .where('shareLink', isEqualTo: shareLink)
      .limit(1)
      .snapshots()
      .map(
        (snap) => snap.docs.isEmpty
            ? null
            : LocationSession.fromFirestore(snap.docs.first),
      );
}
