import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/models/user_model.dart';
import 'package:gme_time_tracker/utils/downloader.dart';
import 'package:gme_time_tracker/widgets/common_input_field.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../helpers/pdf_helper.dart';
import '../../models/activity_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/download_options_dialog.dart';
import 'controller/dashboard_controller.dart';
import 'controller/summary_controller.dart';
import 'package:flutter/services.dart';

class SummaryView extends StatelessWidget {
  final controller = Get.put(SummaryController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          spacing: 10,
          children: [
            const Text(
              'Monthly Activity Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            // Month Dropdown
            Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 20,
              spacing: 10,
              children: [
                SizedBox(
                  width: 130,
                  child: Obx(() {
                    return CommonDropdownButton<String>(
                      value: controller.selectedMonth.value,
                      items:
                          controller.months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.updateMonth(newValue);
                        }
                      },
                    );
                  }),
                ),
                SizedBox(
                  width: 110,
                  child: Obx(() {
                    final currentYear = DateTime.now().year;
                    return CommonDropdownButton<int>(
                      value: controller.selectedYear.value,
                      items:
                          List<int>.generate(5, (i) => currentYear - i).map((
                            int year,
                          ) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          controller.updateYear(newValue);
                        }
                      },
                    );
                  }),
                ),
                InkWell(
                  onTap: () {
                    print("fdf");

                    showDialog(
                      context: context,
                      builder: (context) {
                        return DownloadOptionsDialog(
                          onExcelSelected: () {
                            controller.exportReport();
                          },
                          onPdfSelected: () async {
                            String month =
                                controller.selectedMonth.value.toString();
                            String year =
                                controller.selectedYear.value.toString();

                            UserModel? user =
                                Get.find<DashboardController>().user.value;

                            // Load logo
                            final ByteData logoData = await rootBundle.load(
                              'assets/logo.png',
                            );
                            final Uint8List logoBytes =
                                logoData.buffer.asUint8List();

                            // Prepare user details
                            final Map<String, dynamic> userDetails = {
                              'Name': user?.firstName ?? '',
                              'Email': user?.email ?? '',
                            };

                            // Get activities
                            List<ActivityModel> activities =
                                controller.activities;

                            // Calculate total hours and average
                            // double totalHours = activities.fold(
                            //     0,
                            //     (sum, activity) =>
                            //         sum + (activity.durationMinutes / 60));
                            // double averageHoursPerDay = activities.isNotEmpty
                            //     ? totalHours / activities.length
                            //     : 0;

                            // // Prepare summary data
                            // final Map<String, dynamic> summaryData = {
                            //   'Total Hours': totalHours.toStringAsFixed(2),
                            //   'Month': '$month $year',
                            //   'Average Hours/Day':
                            //       averageHoursPerDay.toStringAsFixed(2),
                            //   'Total Activities': activities.length.toString(),
                            // };

                            // // Convert activities to entries format
                            // final List<Map<String, dynamic>> entries =
                            //     activities
                            //         .map((activity) => {
                            //               'Date': DateFormat('MMM dd, yyyy')
                            //                   .format(activity.date),
                            //               'Hours':
                            //                   (activity.durationMinutes / 60)
                            //                       .toStringAsFixed(2),
                            //               'Activity Type':
                            //                   activity.activityType,
                            //               'Notes': activity.notes ?? '',
                            //               'Status': activity.status,
                            //             })
                            //         .toList();

                            File file =
                                await PdfGenerator.generateUserActivityPDF(
                                  fileName: 'GME_Hours_${month}_$year',
                                  userDetails: userDetails,
                                  activityList: activities,
                                  logoBytes: logoBytes,
                                  copyrightText: '© 2025 GME Time Tracker',
                                );

                            print(file);

                            await Downloader.downloadFile(file: file);
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.download, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Obx(() {
          return Text(
            'Total Time: ${controller.totalTime}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          );
        }),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive dimensions
            final isMobile = constraints.maxWidth < 600;
            final chartWidth =
                isMobile
                    ? constraints.maxWidth.toDouble()
                    : (constraints.maxWidth > 800
                        ? (constraints.maxWidth - 48) / 2
                        : constraints.maxWidth - 48.0);

            final chartHeight = isMobile ? 400.0 : 400.0;

            return Wrap(
              spacing: isMobile ? 16.0 : 24.0,
              runSpacing: isMobile ? 16.0 : 24.0,
              children: [
                Container(
                  width: chartWidth,
                  height: chartHeight,
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity Distribution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Center(
                          child: Obx(() {
                            final data = controller.getActivityDistribution();

                            if (data.isEmpty) {
                              return const Text('No data available');
                            }

                            return SfCircularChart(
                              legend: Legend(
                                // height: "35%",
                                // width: "65%",
                                iconHeight: 25,
                                iconBorderWidth: 25,
                                overflowMode:
                                    isMobile
                                        ? LegendItemOverflowMode.wrap
                                        : LegendItemOverflowMode.scroll,
                                isVisible: true,
                                position:
                                    isMobile
                                        ? LegendPosition.bottom
                                        : LegendPosition.right,
                                orientation:
                                    isMobile
                                        ? LegendItemOrientation.vertical
                                        : LegendItemOrientation.vertical,
                              ),
                              series: <CircularSeries>[
                                DoughnutSeries<ActivityDistribution, String>(
                                  dataSource: data,
                                  xValueMapper:
                                      (ActivityDistribution data, _) =>
                                          data.activity,
                                  yValueMapper:
                                      (ActivityDistribution data, _) =>
                                          data.minutes,
                                  dataLabelMapper:
                                      (ActivityDistribution data, _) =>
                                          data.duration,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        isMobile
                                            ? ChartDataLabelPosition.outside
                                            : ChartDataLabelPosition.inside,
                                    textStyle: TextStyle(
                                      fontSize: isMobile ? 10 : 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                // Daily Activity Chart
                Container(
                  width: chartWidth,
                  height: chartHeight,
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Activity (Hours)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Obx(() {
                          final data = controller.getDailyActivity();
                          return SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                              dateFormat: DateFormat(isMobile ? 'd' : 'MMM d'),
                              intervalType: DateTimeIntervalType.days,
                              majorGridLines: const MajorGridLines(width: 0),
                              labelRotation: isMobile ? 45 : 0,
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(text: 'Hours'),
                              majorGridLines: const MajorGridLines(width: 0.5),
                              labelStyle: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                              ),
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<DailyActivity, DateTime>(
                                dataSource: data,
                                xValueMapper:
                                    (DailyActivity data, _) => data.date,
                                yValueMapper:
                                    (DailyActivity data, _) => data.hours,
                                color: AppColors.primary,
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
