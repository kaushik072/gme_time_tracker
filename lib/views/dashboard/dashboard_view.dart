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
          onTabChanged: (index) => controller.selectedTab.value = index,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (controller.selectedTab.value) {
            0 => _TrackingView(),
            1 => _ActivityView(),
            2 => const Center(child: Text('Summary Coming Soon')),
            _ => _TrackingView(),
          },
        ),
      ),
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
            return const Center(child: Text('Summary Coming Soon'));
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
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
            const SizedBox(height: 24),
            CommonDropdownButton<String>(
              labelText: 'Activity Type',
              hintText: 'Select Activity Type',
              value:
                  controller.activityType.value.isEmpty
                      ? null
                      : controller.activityType.value,
              items:
                  controller.activityTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) => controller.activityType.value = value ?? '',
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: controller.notesController,
              labelText: 'Notes (Optional)',
              hintText: 'Enter optional notes about this activity',
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Obx(() {
              return CommonButton(
                text:
                    controller.isTracking.value ? 'Stop Timer' : 'Start Timer',
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
    );
  }
}

class _ActivityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('Activity list will be shown here')),
    );
  }
}

class _ManualEntryForm extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonDropdownButton<String>(
            labelText: 'Activity Type',
            hintText: 'Select Activity Type',
            value:
                controller.activityType.value.isEmpty
                    ? null
                    : controller.activityType.value,
            items:
                controller.activityTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (value) => controller.activityType.value = value ?? '',
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: controller.dateController,
            labelText: 'Date',
            hintText: 'Select Date',
            onTap: () => controller.selectDate(context),
            readOnly: true,
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
            controller: controller.notesController,
            labelText: 'Notes (Optional)',
            hintText: 'Enter optional notes about this activity',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          CommonButton(
            text: 'Add Log Entry',
            onPressed: () {
              controller.addManualEntry();
              Navigator.pop(context);
            },
            isPrimary: true,
            width: double.infinity,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
