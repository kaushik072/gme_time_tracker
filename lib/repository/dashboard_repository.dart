import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../utils/auth_service.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gmetimetracker',
  );

  //   final database = FirebaseDatabase.instanceFor(
  // final database = FirebaseDatabase.instanceFor(
  //   app: Firebase.app(),
  //   databaseURL: 'https://gme-time-tracker-nam5.firebaseio.com',
  // );

  Future<void> startTracking({
    required String activityType,
    String? notes,
  }) async {
    debugPrint('Starting tracking ${AuthService.userId}');
    try {
      await _firestore.collection('tracking').add({
        'userId': AuthService.userId,
        'activityType': activityType,
        'notes': notes,
        'startTime': DateTime.now(),
        'status': 'in_progress',
      });
    } catch (e) {
      debugPrint('Error starting tracking: $e');
    }
  }

  Future<void> stopTracking(String trackingId) async {
    await _firestore.collection('tracking').doc(trackingId).update({
      'endTime': DateTime.now(),
      'status': 'completed',
    });
  }

  Future<void> addManualEntry({
    required String activityType,
    required DateTime date,
    required int durationMinutes,
    String? notes,
  }) async {
    await _firestore.collection('tracking').add({
      'userId': AuthService.userId,
      'activityType': activityType,
      'date': date,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'status': 'completed',
      'isManual': true,
    });
  }

  Future<Map<String, dynamic>?> getInProgressTracking() async {
    try {
      debugPrint('Getting in-progress tracking : ${AuthService.userId}');
      final QuerySnapshot snapshot =
          await _firestore
              .collection('tracking')
              .where('userId', isEqualTo: AuthService.userId)
              .where('status', isEqualTo: 'in_progress')
              .orderBy('startTime', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      debugPrint('Error getting in-progress tracking: $e');
      return null;
    }
  }
}
