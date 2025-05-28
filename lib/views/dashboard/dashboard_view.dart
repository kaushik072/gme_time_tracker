import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gme_time_tracker/utils/constants_data.dart';
import 'package:gme_time_tracker/widgets/common_confirm_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
import '../profile/profile_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: DashboardController(),
      builder: (controller) {
        return ResponsiveLayout(
          webBody: _WebDashboardView(controller: controller),
          mobileBody: _MobileDashboardView(controller: controller),
        );
      },
    );
  }
}

class _WebDashboardView extends StatelessWidget {
  final DashboardController controller;
  const _WebDashboardView({required this.controller});

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
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: 24,
          ),
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

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 525,

                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: timerStartStopView(controller),
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Container(
                            height: 525,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ManualEntryForm(canBack: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

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
              const SizedBox(height: 50),

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
  final DashboardController controller;
  const _MobileDashboardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Obx(() {
          String userName =
              "${controller.user.value?.firstName ?? ""} ${controller.user.value?.lastName ?? ""}";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome,',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );
        }),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            child: Icon(Icons.more_vert_rounded, color: AppColors.primary),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'contact_us',
                    child: Row(
                      children: [
                        Icon(Icons.contact_support_outlined),
                        SizedBox(width: 8),
                        Text('Contact Us'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_account',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Account'),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) async {
              if (value == 'logout') {
                showDialog(
                  context: context,
                  builder:
                      (context) => CommonConfirmDialog(
                        title: 'Log Out',
                        content: 'Are you sure you want to logout?',
                        onConfirm: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            ToastHelper.showSuccessToast(
                              'Successfully logged out',
                            );
                            context.go('/login');
                          }
                        },
                        confirmText: 'Logout',
                      ),
                );
              } else if (value == 'delete_account') {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      insetPadding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => GoRouter.of(context).pop(),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CommonTextField(
                              controller: deleteAccountEmailController,
                              hintText: 'Enter your email',
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'\s+'),
                                ),
                              ],
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => CommonTextField(
                                obscureText: deleteAccountPasswordVisible.value,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    deleteAccountPasswordVisible.value =
                                        !deleteAccountPasswordVisible.value;
                                  },
                                  icon: Icon(
                                    deleteAccountPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                controller: deleteAccountPasswordController,
                                hintText: 'Enter your password',
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'\s+'),
                                  ),
                                ],
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CommonButton(
                              text: 'Delete Account',
                              onPressed: () async {
                                try {
                                  String email =
                                      deleteAccountEmailController.text.trim();

                                  if (email.isEmpty || !email.isEmail) {
                                    ToastHelper.showErrorToast(
                                      'Please enter a valid email address',
                                    );
                                    return;
                                  }

                                  String password =
                                      deleteAccountPasswordController.text
                                          .trim();

                                  if (password.isEmpty) {
                                    ToastHelper.showErrorToast(
                                      'Please enter your password',
                                    );
                                    return;
                                  }

                                  User? user =
                                      FirebaseAuth.instance.currentUser;

                                  if (user != null) {
                                    // Step 1: Re-authenticate
                                    AuthCredential credential =
                                        EmailAuthProvider.credential(
                                          email:
                                              deleteAccountEmailController.text
                                                  .trim(),
                                          password:
                                              deleteAccountPasswordController
                                                  .text
                                                  .trim(),
                                        );
                                    await user.reauthenticateWithCredential(
                                      credential,
                                    );

                                    // Step 2: Delete the account
                                    await user.delete();

                                    // context.pop();
                                    // await Future.delayed(const Duration(seconds: 1), () {
                                    //   if (context.mounted) {

                                    await FirebaseAuth.instance.signOut();

                                    ToastHelper.showSuccessToast(
                                      'Account deleted successfully.',
                                    );

                                    if (context.mounted) {
                                      context.go('/login');
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  ToastHelper.showErrorToast(
                                    e.message ?? 'Error deleting account',
                                  );
                                } catch (e) {
                                  ToastHelper.showErrorToast(
                                    'Error deleting account: $e',
                                  );
                                }
                              },
                              isPrimary: false,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                deleteAccountEmailController.clear();
                deleteAccountPasswordController.clear();
                deleteAccountPasswordVisible.value = false;
              } else if (value == 'contact_us') {
                try {
                  String? encodeQueryParameters(
                    Map<String, String> params,
                  ) => params.entries
                      .map(
                        (MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                      )
                      .join('&');

                  String email = "support@gmetimetracker.com";

                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Help & Support',
                    }),
                  );

                  await launchUrl(
                    emailLaunchUri,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  print(" Error: $e");
                }
              }
            },
          ),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Obx(() {
          switch (controller.selectedTab.value) {
            case 0:
              return _TrackingView();
            case 1:
              return _ActivityView();
            case 2:
              return SummaryView();
            case 3:
              return ProfileView();
            default:
              return _TrackingView();
          }
        }),
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
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
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      }),
    );
  }
}

Future<void> _showManualEntryBottomSheet(BuildContext context) async {
  final controller = Get.find<DashboardController>();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [ManualEntryForm(canBack: true)],
            ),
          ),
        ),
  ).whenComplete(() {
    controller.clearManualEntryFields();
  });
}

timerStartStopView(DashboardController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 20),
      Center(
        child: Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, color: AppColors.primary, size: 48),
              const SizedBox(width: 16),
              Text(
                controller.formatTime(controller.elapsedSeconds.value),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }),
      ),
      const SizedBox(height: 24),
      Obx(() {
        return IgnorePointer(
          ignoring: controller.isTracking.value,
          child: CommonDropdownButton<String>(
            labelText: 'Activity Type',
            hintText: 'Select Activity Type',
            value:
                controller.trackingActivityType.value.isEmpty
                    ? null
                    : controller.trackingActivityType.value,
            items:
                ConstantsData.instance.activityTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged:
                controller.isTracking.value
                    ? (_) {}
                    : (String? value) =>
                        controller.trackingActivityType.value = value ?? '',
          ),
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
          isLoading: controller.isStartTrackingLoading.value,
          text: controller.isTracking.value ? 'Stop Timer' : 'Start Timer',
          onPressed:
              controller.isTracking.value
                  ? controller.stopTracking
                  : controller.startTracking,
          isPrimary: !controller.isTracking.value,
          width: double.infinity,
        );
      }),
    ],
  );
}

class _TrackingView extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 450, child: timerStartStopView(controller)),
        const SizedBox(height: 24),
        CommonButton(
          text: "Add Manual Entry",
          onPressed: () {
            _showManualEntryBottomSheet(context);
          },
          isPrimary: true,
          width: double.infinity,
        ),
      ],
    );
  }
}

class _ActivityView extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 20,
          spacing: 20,
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
              width: 240,
              child: Obx(() {
                return CommonDropdownButton<String>(
                  value: controller.selectedActivityFilter.value,
                  items:
                      [
                        'All Activities',
                        ...ConstantsData.instance.activityTypes,
                      ].map((String value) {
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.025),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: AppColors.border),
          ),
          child: Obx(() {
            List<Map<String, dynamic>> data = controller.getData();

            ScrollController scrollController = ScrollController();

            if (data.isEmpty) {
              return Container(
                alignment: Alignment.center,
                height: 300,
                child: Text(
                  'No data found!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }
            if (data.isNotEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(AppColors.primary),
                      thickness: WidgetStateProperty.all(2),
                      radius: const Radius.circular(20),
                      trackVisibility: WidgetStateProperty.all(true),
                      trackColor: WidgetStateProperty.all(
                        AppColors.primary.withOpacity(0.1),
                      ),
                      thumbVisibility: WidgetStateProperty.all(true),
                      interactive: true,
                      trackBorderColor: WidgetStateProperty.all(
                        AppColors.primary.withOpacity(0.1),
                      ),
                      crossAxisMargin: 3,
                      mainAxisMargin: 3,
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      thickness: 5,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 20),
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            child: DataView(
                              controller: controller,
                              data: data,
                              headerData: controller.headerData,
                              constraints: constraints,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (controller.filteredActivities.length > 10)
                    PaginationView(controller: controller),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ),
      ],
    );
  }
}

class PaginationView extends StatelessWidget {
  final DashboardController controller;

  const PaginationView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Page ${controller.currentPage.value} of ${controller.getTotalPages}',
        ),
        SizedBox(width: 5),
        IconButton(
          onPressed: () => controller.previousPage(),
          icon: Icon(Icons.arrow_back_ios),
        ),
        IconButton(
          onPressed: () => controller.nextPage(),
          icon: Icon(Icons.arrow_forward_ios),
        ),
        SizedBox(width: 15),
      ],
    );
  }
}

class ManualEntryForm extends StatelessWidget {
  final bool canBack;

  ManualEntryForm({super.key, this.canBack = false});

  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return CommonDropdownButton<String>(
            labelText: 'Activity Type',
            hintText: 'Select Activity Type',
            value:
                controller.manualEntryActivityType.value.isEmpty
                    ? null
                    : controller.manualEntryActivityType.value,
            items:
                ConstantsData.instance.activityTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged:
                (value) =>
                    controller.manualEntryActivityType.value = value ?? '',
          );
        }),
        SizedBox(height: 16),
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
                hintText: 'HH',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonTextField(
                controller: controller.minutesController,
                labelText: 'Minutes',
                hintText: 'MM',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
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
        Obx(() {
          return CommonButton(
            isLoading: controller.isAddManualEntryLoading.value,
            text: 'Add Log Entry',
            onPressed: () {
              controller.addManualEntry(context, canBack);
            },
            isPrimary: true,
            width: double.infinity,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class DataHeader extends StatelessWidget {
  final Map<String, double> headerData;

  const DataHeader({super.key, required this.headerData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            headerData.entries
                .map(
                  (e) => SizedBox(
                    width: e.value.toDouble(),
                    child: HeaderTile(title: e.key),
                  ),
                )
                .expand((element) => [element, const SizedBox(width: 10)])
                .toList()
              ..removeLast(),
      ),
    );
  }
}

class HeaderTile extends StatelessWidget {
  const HeaderTile({super.key, required this.title, this.alignment});

  final String title;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.center,
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: (alignment != null) ? 10 : 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DataView extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, double> headerData;
  final List<Map<String, dynamic>> data;
  final DashboardController controller;

  const DataView({
    super.key,
    required this.constraints,
    required this.headerData,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    double width = headerData.values.fold(
      0,
      (value, element) => value + element + 10,
    );

    double adjustedWidth = 0;

    if (width < constraints.maxWidth) {
      double diff = constraints.maxWidth - width;

      adjustedWidth = diff / headerData.length;

      headerData.forEach((key, value) {
        headerData[key] = value + adjustedWidth;
      });
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: constraints.maxWidth < width ? width : constraints.maxWidth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DataHeader(headerData: headerData),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) {
              return Divider(height: 20, color: Colors.grey.withOpacity(0.25));
            },
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              Map<String, dynamic>? rowData = data.elementAtOrNull(index);
              if (rowData == null) return const SizedBox.shrink();

              return SizedBox(
                height: 40,
                child: Row(
                  children:
                      headerData.entries
                          .map(
                            (e) => SizedBox(
                              width: e.value.toDouble(),
                              child:
                                  e.key == "Action"
                                      ? IconButton(
                                        onPressed: () async {
                                          await controller.deleteActivity(
                                            rowData[e.key],
                                            context,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      )
                                      : Text(
                                        rowData[e.key] is DateTime
                                            ? DateFormat(
                                              'MMM dd, yyyy HH:mm',
                                            ).format(rowData[e.key] as DateTime)
                                            : rowData[e.key]?.toString() ?? "-",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(height: 1.5),
                                      ),
                            ),
                          )
                          .expand(
                            (element) => [
                              element,
                              SizedBox(
                                width: 10,
                                // child: VerticalDivider(
                                //   color: Colors.grey.withOpacity(0.25),
                                // ),
                              ),
                            ],
                          )
                          .toList()
                        ..removeLast(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
