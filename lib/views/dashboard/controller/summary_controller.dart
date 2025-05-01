import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/activity_model.dart';
import '../../../utils/excel_helper.dart';
import 'dashboard_controller.dart';

class SummaryController extends GetxController {
  final selectedMonth = RxString(DateFormat('MMMM').format(DateTime.now()));
  final selectedYear = DateTime.now().year.obs;

  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Get activities from DashboardController
  List<ActivityModel> get activities =>
      Get.find<DashboardController>().allActivities;

  // Get total time for the selected month
  String get totalTime {
    final monthActivities = _getActivitiesForSelectedMonth();
    final totalMinutes = monthActivities.fold<int>(
      0,
      (sum, activity) => sum + (activity.durationMinutes),
    );
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  // Get activities distribution data for pie chart
  List<ActivityDistribution> getActivityDistribution() {
    final monthActivities = _getActivitiesForSelectedMonth();
    final Map<String, int> distribution = {};

    for (final activity in monthActivities) {
      distribution[activity.activityType] =
          (distribution[activity.activityType] ?? 0) + activity.durationMinutes;
    }

    return distribution.entries.map((entry) {
      final hours = entry.value ~/ 60;
      final minutes = entry.value % 60;
      return ActivityDistribution(
        activity: entry.key,
        duration: '${hours}h ${minutes}m',
        minutes: entry.value,
      );
    }).toList();
  }

  // Get daily activity data for bar chart
  List<DailyActivity> getDailyActivity() {
    final monthActivities = _getActivitiesForSelectedMonth();
    final Map<DateTime, int> dailyMinutes = {};

    for (final activity in monthActivities) {
      final date = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      dailyMinutes[date] = (dailyMinutes[date] ?? 0) + activity.durationMinutes;
    }

    return dailyMinutes.entries.map((entry) {
        final hours = entry.value / 60; // Convert to hours for the chart
        return DailyActivity(date: entry.key, hours: hours);
      }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<ActivityModel> _getActivitiesForSelectedMonth() {
    return activities.where((activity) {
      return activity.date.year == selectedYear.value &&
          activity.date.month == (months.indexOf(selectedMonth.value) + 1);
    }).toList();
  }

  void updateMonth(String month) {
    selectedMonth.value = month;
  }

  void updateYear(int year) {
    selectedYear.value = year;
  }

  Future<void> exportReport() async {
    final monthActivities = _getActivitiesForSelectedMonth();
    if (monthActivities.isEmpty) {
      Get.snackbar(
        'No Data',
        'There are no activities to export for the selected month.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await ExcelHelper.exportActivities(
        monthActivities,
        selectedMonth.value,
        selectedYear.value,
        'User Name', // TODO: Get actual user name
        'Position', // TODO: Get actual position
      );
      Get.snackbar(
        'Success',
        'Report exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export report',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class ActivityDistribution {
  final String activity;
  final String duration;
  final int minutes;

  ActivityDistribution({
    required this.activity,
    required this.duration,
    required this.minutes,
  });
}

class DailyActivity {
  final DateTime date;
  final double hours;

  DailyActivity({required this.date, required this.hours});
}
