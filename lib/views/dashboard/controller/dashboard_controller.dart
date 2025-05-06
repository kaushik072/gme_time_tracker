import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../repositories/dashboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/toast_helper.dart';
import '../../../models/activity_model.dart';
import '../../../utils/auth_service.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();
  final scrollController = ScrollController();
  final sectionKeys = List.generate(3, (index) => GlobalKey());
  bool isProgrammaticScroll = false;

  final selectedTab = 0.obs;
  final isTracking = false.obs;
  final elapsedSeconds = 0.obs;
  final currentTrackingId = ''.obs;
  final trackingActivityType = ''.obs;
  final manualEntryActivityType = ''.obs;
  final allActivities = <ActivityModel>[].obs; // Store all activities locally
  final selectedActivityFilter = 'All Activities'.obs;
  final filteredActivities = <ActivityModel>[].obs;

  final originalFirstName = ''.obs;
  final originalLastName = ''.obs;
  final originalDegree = ''.obs;
  final originalPosition = ''.obs;

  Rx<UserModel?> user = Rx<UserModel?>(null);

  final activityTypeController = TextEditingController();
  final trackingNotesController = TextEditingController();
  final manualEntryNotesController = TextEditingController();
  final dateController = TextEditingController();
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkForInProgressTracking();
    _setupActivityListener();
    _setupScrollListener();
    _fetchUserData();

    // Listen for filter changes and update filtered activities
    ever(selectedActivityFilter, (_) => _filterActivities());
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = AuthService.userId;
      if (userId == null) {
        debugPrint('Error: User ID is null');
        return;
      }
      final data = _repository.getUserStream(userId);

      data.listen((userData) {
        if (userData != null) {
          user.value = userData;
        }
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void _setupActivityListener() {
    _repository
        .getActivities() // Remove the filter parameter since we'll filter locally
        .listen(
          (activityList) {
            debugPrint('Activity list: $activityList');
            allActivities.value = activityList;
            _filterActivities(); // Apply current filter to new data
          },
          onError: (error) {
            debugPrint('Error fetching activities: $error');
            ToastHelper.showErrorToast('Failed to load activities');
          },
        );
  }

  void _filterActivities() {
    if (selectedActivityFilter.value == 'All Activities') {
      filteredActivities.value = allActivities;
    } else {
      filteredActivities.value =
          allActivities
              .where(
                (activity) =>
                    activity.activityType == selectedActivityFilter.value,
              )
              .toList();
    }
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (isProgrammaticScroll) return;

      // Get the current scroll position
      final position = scrollController.position.pixels;
      final viewportHeight = scrollController.position.viewportDimension;

      // Find which section is most visible
      int mostVisibleIndex = selectedTab.value;
      double maxVisibility = 0;

      for (var i = 0; i < sectionKeys.length; i++) {
        final context = sectionKeys[i].currentContext;
        if (context != null) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final offset = box.localToGlobal(Offset.zero);
            final sectionHeight = box.size.height;

            // Calculate section's position relative to viewport
            final sectionTop = offset.dy;
            final sectionBottom = sectionTop + sectionHeight;

            // Calculate how much of the section is visible
            final visibleTop = sectionTop < 0 ? 0 : sectionTop;
            final visibleBottom =
                sectionBottom > viewportHeight ? viewportHeight : sectionBottom;
            final visibleHeight = visibleBottom - visibleTop;

            // Calculate visibility percentage
            final visibility = visibleHeight / sectionHeight;

            // Consider a section more visible if it's closer to the top of the viewport
            final topProximity = 1.0 - (sectionTop.abs() / viewportHeight);
            final adjustedVisibility =
                visibility * (0.7 + (0.3 * topProximity));

            if (adjustedVisibility > maxVisibility) {
              maxVisibility = adjustedVisibility;
              mostVisibleIndex = i;
            }
          }
        }
      }

      // Update selected tab if we found a more visible section
      if (maxVisibility > 0.3 && selectedTab.value != mostVisibleIndex) {
        selectedTab.value = mostVisibleIndex;
      }
    });
  }

  Future<void> _checkForInProgressTracking() async {
    try {
      debugPrint('Checking for in-progress tracking');
      final tracking = await _repository.getInProgressTracking();
      debugPrint('Tracking: $tracking');

      if (tracking != null) {
        debugPrint('Tracking ID: ${tracking['id']}');
        currentTrackingId.value = tracking['id'];
        trackingActivityType.value = tracking['activityType'];
        trackingNotesController.text = tracking['notes'] ?? '';
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
    if (trackingActivityType.value.isEmpty) {
      ToastHelper.showErrorToast('Please select an activity type');
      return;
    }

    try {
      await _repository.startTracking(
        activityType: trackingActivityType.value,
        notes: trackingNotesController.text,
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
      trackingActivityType.value = '';
      trackingNotesController.clear();
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

  Future<void> addManualEntry(BuildContext context, bool canBack) async {
    if (manualEntryActivityType.value.isEmpty ||
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
        activityType: manualEntryActivityType.value,
        date: DateTime.parse(dateController.text),
        durationMinutes: totalMinutes,
        notes: manualEntryNotesController.text,
      );
      ToastHelper.showSuccessToast('Activity logged successfully');
      if (canBack) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      ToastHelper.showErrorToast('Failed to log activity');
    } finally {
      clearManualEntryFields();
    }
  }

  void clearManualEntryFields() {
    manualEntryActivityType.value = '';
    dateController.clear();
    hoursController.clear();
    minutesController.clear();
    manualEntryNotesController.clear();
  }

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _repository.deleteActivity(activityId);
      ToastHelper.showSuccessToast('Activity deleted successfully');
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      ToastHelper.showErrorToast('Failed to delete activity');
    }
  }

  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  void scrollToSection(int index) {
    if (index < 0 || index >= sectionKeys.length) return;

    // Update the selected tab
    selectedTab.value = index;

    final context = sectionKeys[index].currentContext;
    if (context != null) {
      // Set flag to prevent scroll listener from updating tab
      isProgrammaticScroll = true;

      // Cancel any ongoing scroll animation
      scrollController.animateTo(
        scrollController.offset,
        duration: Duration.zero,
        curve: Curves.linear,
      );

      // Perform the new scroll
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      ).then((_) {
        // Reset flag after animation completes
        Future.delayed(const Duration(milliseconds: 100), () {
          isProgrammaticScroll = false;
        });

        // Ensure we're at the correct position after animation
        if (selectedTab.value == index) {
          Scrollable.ensureVisible(
            context,
            duration: Duration.zero,
            curve: Curves.linear,
            alignment: 0.0,
          );
        }
      });
    }
  }

  Rx<int> currentPage = 1.obs;

  int get getTotalPages => (filteredActivities.length / 10).ceil();

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (currentPage.value < getTotalPages) {
      currentPage.value++;
    }
  }

  Map<String, double> headerData = {
    "#": 60,
    "Date-Time": 200,
    "Activity": 260,
    "Duration": 180,
    "Notes": 200,
    "Status": 200,
    "Manual Entry": 150,
    "Action": 120,
  };

  List<Map<String, String>> getData({
    DateTimeRange? selectedDateTimeRange,
    int limit = 10,
  }) {
    List<Map<String, String>> data = [];
    List<ActivityModel> activitiesData = List.from(filteredActivities);

    activitiesData.sort((a, b) => b.date.compareTo(a.date));

    final startIndex = (currentPage.value - 1) * limit;
    final endIndex = startIndex + limit;

    final validEndIndex =
        endIndex > activitiesData.length ? activitiesData.length : endIndex;

    List<ActivityModel> paginatedActivities = activitiesData.sublist(
      startIndex,
      validEndIndex,
    );

    for (int i = 0; i < paginatedActivities.length; i++) {
      String date = DateFormat('E, MMM d').format(paginatedActivities[i].date);

      String time = DateFormat('h:mm a').format(paginatedActivities[i].date);

      String manualEntry = paginatedActivities[i].isManual ? 'Yes' : 'No';

      String activity = paginatedActivities[i].activityType;

      String duration = formatDuration(paginatedActivities[i].durationMinutes);

      String notes = "${paginatedActivities[i].notes}";

      String status =
          paginatedActivities[i].status == 'in_progress'
              ? 'In progress'
              : "Completed";

      String delete = paginatedActivities[i].id;

      data.add({
        "#": (((currentPage.value - 1) * limit) + (i + 1)).toString(),
        "Date-Time": "$date\n$time",
        "Activity": activity,
        "Duration": duration,
        "Notes": notes,
        "Status": status,
        "Manual Entry": manualEntry,
        "Action": delete,
      });
    }

    return data;
  }

  Future<bool> updateUser({
    required String firstName,
    required String lastName,
    String? degree,
    String? position,
  }) async {
    try {
      await _repository.updateUser(
        userId: user.value?.id ?? '',
        firstName: firstName,
        lastName: lastName,
        degree: degree,
        position: position,
      );
      ToastHelper.showSuccessToast('User updated successfully');
      return true;
    } catch (e) {
      ToastHelper.showErrorToast('Failed to update user');
      return false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    activityTypeController.dispose();
    trackingNotesController.dispose();
    manualEntryNotesController.dispose();
    dateController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    super.onClose();
  }
}
