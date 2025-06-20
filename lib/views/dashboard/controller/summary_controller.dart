import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/activity_model.dart';
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

  String userName = Get.find<DashboardController>().user.value?.firstName ?? "";
  String position = Get.find<DashboardController>().user.value?.position ?? "";

  // Get total time for the selected month
  String get totalTime {
    final monthActivities = getActivitiesForSelectedMonth();
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
    final monthActivities = getActivitiesForSelectedMonth();
    final Map<String, int> distribution = {};

    for (final activity in monthActivities) {
      print(activity.activityType);
      print(activity.durationMinutes);
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
    final monthActivities = getActivitiesForSelectedMonth();
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

  List<ActivityModel> getActivitiesForSelectedMonth() {
    final activity =
        activities.where((activity) {
          return activity.date.year == selectedYear.value &&
              activity.date.month == (months.indexOf(selectedMonth.value) + 1);
        }).toList();

    for (final activity in activities) {
      if (!activity.isManual) {
        final now = DateTime.now();
        final duration = now.difference(activity.startTime!);
        activity.durationMinutes = duration.inMinutes;
      }
    }

    return activity;
  }

  void updateMonth(String month) {
    selectedMonth.value = month;
  }

  void updateYear(int year) {
    selectedYear.value = year;
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
