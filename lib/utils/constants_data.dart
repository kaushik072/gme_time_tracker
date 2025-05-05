import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConstantsData extends GetxController {
  static ConstantsData get instance => Get.find<ConstantsData>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'gmetimetracker',
  );

  // Observable lists for dynamic data
  final positions = <String>[].obs;
  final degrees = <String>[].obs;
  final activityTypes = <String>[].obs;

  // Initialize method to be called at app startup
  Future<void> init() async {
    try {
      // Fetch all constants from Firebase
      final constantsDoc =
          await _firestore.collection('constants').doc('app_constants').get();

      if (constantsDoc.exists) {
        final data = constantsDoc.data() as Map<String, dynamic>;

        // Update observable lists
        positions.value = List<String>.from(data['positions'] ?? []);
        degrees.value = List<String>.from(data['degrees'] ?? []);
        activityTypes.value = List<String>.from(data['activityTypes'] ?? []);
      }
    } catch (e) {
      print('Error initializing constants: $e');
    }
  }

  // Helper methods to get dropdown items
  List<DropdownMenuItem<String>> getPositionItems() {
    return positions
        .map(
          (position) => DropdownMenuItem(
            value: position.toLowerCase(),
            child: Text(position),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<String>> getDegreeItems() {
    return degrees
        .map(
          (degree) => DropdownMenuItem(
            value: degree.toLowerCase(),
            child: Text(degree),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<String>> getActivityTypeItems() {
    return activityTypes
        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
        .toList();
  }
}
