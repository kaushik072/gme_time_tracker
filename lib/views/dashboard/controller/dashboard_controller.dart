import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../repository/dashboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/toast_helper.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  final selectedTab = 0.obs;
  final isTracking = false.obs;
  final elapsedSeconds = 0.obs;
  final currentTrackingId = ''.obs;
  final activityType = ''.obs;

  final activityTypeController = TextEditingController();
  final notesController = TextEditingController();
  final dateController = TextEditingController();
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();

  final activityTypes = [
    'Clinical Teaching',
    'Didactic Teaching',
    'Curriculum Development',
    'Assessment & Evaluation',
    'Mentorship & Advising',
    'Program Administration',
    'Faculty Development',
    'Scholarly Activity',
  ];

  @override
  void onInit() {
    _checkForInProgressTracking();
    debugPrint('onInit');
    super.onInit();
  }

  Future<void> _checkForInProgressTracking() async {
    try {
      debugPrint('Checking for in-progress tracking');
      final tracking = await _repository.getInProgressTracking();
      debugPrint('Tracking: $tracking');

      if (tracking != null) {
        debugPrint('Tracking ID: ${tracking['id']}');
        currentTrackingId.value = tracking['id'];
        activityType.value = tracking['activityType'];
        notesController.text = tracking['notes'] ?? '';
        isTracking.value = true;

        // Calculate elapsed time
        final startTime = tracking['startTime'] as Timestamp;
        final difference = DateTime.now().difference(startTime.toDate());
        elapsedSeconds.value = difference.inSeconds;
        // Start timer
        _startTimer();
      }
    } catch (e) {
      debugPrint('Error checking in-progress tracking: $e');
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (isTracking.value) {
        elapsedSeconds.value++;
        _startTimer();
      }
    });
  }

  Future<void> startTracking() async {
    if (activityType.value.isEmpty) {
      ToastHelper.showErrorToast('Please select an activity type');
      return;
    }

    try {
      await _repository.startTracking(
        activityType: activityType.value,
        notes: notesController.text,
      );

      _checkForInProgressTracking();
      ToastHelper.showSuccessToast('Timer started successfully');
    } catch (e) {
      ToastHelper.showErrorToast('Failed to start timer');
    }
  }

  Future<void> stopTracking() async {
    debugPrint('Stopping tracking ${currentTrackingId.value}');
    if (currentTrackingId.isEmpty) return;

    try {
      await _repository.stopTracking(currentTrackingId.value);

      isTracking.value = false;
      elapsedSeconds.value = 0;
      currentTrackingId.value = '';
      activityType.value = '';
      notesController.clear();
      ToastHelper.showSuccessToast('Timer stopped successfully');
    } catch (e) {
      ToastHelper.showErrorToast('Failed to stop timer');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> addManualEntry() async {
    if (activityType.value.isEmpty ||
        dateController.text.isEmpty ||
        (hoursController.text.isEmpty && minutesController.text.isEmpty)) {
      ToastHelper.showErrorToast('Please fill in all required fields');
      return;
    }

    final hours = int.tryParse(hoursController.text) ?? 0;
    final minutes = int.tryParse(minutesController.text) ?? 0;
    final totalMinutes = (hours * 60) + minutes;

    if (totalMinutes == 0) {
      ToastHelper.showErrorToast('Please enter a valid duration');
      return;
    }

    try {
      await _repository.addManualEntry(
        activityType: activityType.value,
        date: DateTime.parse(dateController.text),
        durationMinutes: totalMinutes,
        notes: notesController.text,
      );

      activityType.value = '';
      dateController.clear();
      hoursController.clear();
      minutesController.clear();
      notesController.clear();
      ToastHelper.showSuccessToast('Activity logged successfully');
    } catch (e) {
      ToastHelper.showErrorToast('Failed to log activity');
    }
  }

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    activityTypeController.dispose();
    notesController.dispose();
    dateController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    super.onClose();
  }
}
