import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/toast_helper.dart';
import 'package:get/get.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/web_header.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_input_field.dart';
import 'controller/dashboard_controller.dart';
import 'package:intl/intl.dart';
import 'summary_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      webBody: _WebDashboardView(),
      mobileBody: _MobileDashboardView(),
    );
  }
}

class _WebDashboardView extends StatelessWidget {
  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: WebHeader(
          isDashboard: true,
          selectedTab: controller.selectedTab.value,
          onTabChanged: (index) {
            controller.selectedTab.value = index;
            controller.scrollToSection(index);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Tracking Section
                Container(
                  key: controller.sectionKeys[0],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: 'Time Tracking',
                        description:
                            'Track your time spent on various activities in real-time',
                      ),
                      _TrackingView(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Activity Section
                Container(
                  key: controller.sectionKeys[1],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: 'Activity Tracking',
                        description:
                            'View and manage your logged activities and time entries',
                      ),
                      _ActivityView(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Summary Section
                Container(
                  key: controller.sectionKeys[2],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: 'Monthly Summary',
                        description:
                            'Review your activity summary and export reports',
                      ),
                      SummaryView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? description;

  const _SectionTitle({required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MobileDashboardView extends StatelessWidget {
  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                ToastHelper.showSuccessToast('Successfully logged out');
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        switch (controller.selectedTab.value) {
          case 0:
            return _TrackingView();
          case 1:
            return _ActivityView();
          case 2:
            return SummaryView();
          default:
            return _TrackingView();
        }
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedTab.value == 1) {
          return FloatingActionButton(
            onPressed: () => _showManualEntryBottomSheet(context),
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedTab.value,
          onTap: (index) => controller.selectedTab.value = index,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Tracking'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Summary',
            ),
          ],
        );
      }),
    );
  }

  void _showManualEntryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: _ManualEntryForm(),
          ),
    );
  }
}

class _TrackingView extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.spaceEvenly,
          children: [
            Container(
              height: 450,
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 650),
              margin: EdgeInsets.all(15),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Obx(() {
                      return Text(
                        controller.formatTime(controller.elapsedSeconds.value),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    return CommonDropdownButton<String>(
                      labelText: 'Activity Type',
                      hintText: 'Select Activity Type',
                      value:
                          controller.trackingActivityType.value.isEmpty
                              ? null
                              : controller.trackingActivityType.value,
                      items:
                          controller.activityTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged:
                          controller.isTracking.value
                              ? (_) {}
                              : (String? value) =>
                                  controller.trackingActivityType.value =
                                      value ?? '',
                    );
                  }),
                  const SizedBox(height: 16),
                  CommonTextField(
                    controller: controller.trackingNotesController,
                    labelText: 'Notes (Optional)',
                    hintText: 'Enter optional notes about this activity',
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    readOnly: controller.isTracking.value,
                  ),
                  const SizedBox(height: 24),
                  Spacer(),
                  Obx(() {
                    return CommonButton(
                      text:
                          controller.isTracking.value
                              ? 'Stop Timer'
                              : 'Start Timer',
                      onPressed:
                          controller.isTracking.value
                              ? controller.stopTracking
                              : controller.startTracking,
                      isPrimary: !controller.isTracking.value,
                      width: double.infinity,
                    );
                  }),
                ],
              ),
            ),
            Container(
              height: 450,
              margin: EdgeInsets.all(15),
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 650),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _ManualEntryForm(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityView extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(
                width: 250,
                child: Obx(() {
                  return CommonDropdownButton<String>(
                    value: controller.selectedActivityFilter.value,
                    items:
                        ['All Activities', ...controller.activityTypes].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedActivityFilter.value = newValue;
                      }
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Activity',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 48), // For actions
                    ],
                  ),
                ),
                const Divider(height: 1),
                Obx(() {
                  if (controller.filteredActivities.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No activities recorded yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredActivities.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final activity = controller.filteredActivities[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'E, MMM d',
                                    ).format(activity.date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(activity.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (activity.isManual)
                                    const Text(
                                      'Manual Entry',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(activity.activityType),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                activity.status == 'in_progress'
                                    ? 'In progress'
                                    : controller.formatDuration(
                                      activity.durationMinutes,
                                    ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                activity.notes ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed:
                                    () =>
                                        controller.deleteActivity(activity.id),
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualEntryForm extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() {
                return CommonDropdownButton<String>(
                  labelText: 'Activity Type',
                  hintText: 'Select Activity Type',
                  value:
                      controller.manualEntryActivityType.value.isEmpty
                          ? null
                          : controller.manualEntryActivityType.value,
                  items:
                      controller.activityTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) =>
                          controller.manualEntryActivityType.value =
                              value ?? '',
                );
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonTextField(
                controller: controller.dateController,
                labelText: 'Date',
                hintText: 'Select Date',
                onTap: () => controller.selectDate(context),
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: controller.hoursController,
                labelText: 'Hours',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonTextField(
                controller: controller.minutesController,
                labelText: 'Minutes',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: controller.manualEntryNotesController,
          labelText: 'Notes (Optional)',
          hintText: 'Enter optional notes about this activity',
          keyboardType: TextInputType.multiline,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Spacer(),
        CommonButton(
          text: 'Add Log Entry',
          onPressed: () {
            controller.addManualEntry();
            // Navigator.pop(context);
          },
          isPrimary: true,
          width: double.infinity,
        ),
      ],
    );
  }
}
