import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/widgets/common_input_field.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import 'controller/summary_controller.dart';

class SummaryView extends StatelessWidget {
  final controller = Get.put(SummaryController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Activity Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    // Month Dropdown
                    SizedBox(
                      width: 120,
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
                    const SizedBox(width: 16),
                    // Year Dropdown
                    SizedBox(
                      width: 120,
                      child: Obx(() {
                        final currentYear = DateTime.now().year;
                        return CommonDropdownButton<int>(
                          value: controller.selectedYear.value,
                          items:
                              List<int>.generate(5, (i) => currentYear - i).map(
                                (int year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                },
                              ).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              controller.updateYear(newValue);
                            }
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    // Export PDF Button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          controller.exportReport();
                        },
                        icon: const Icon(
                          Icons.download,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Export PDF',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  // Activity Distribution Chart
                  Container(
                    width:
                        constraints.maxWidth > 800
                            ? 500
                            : constraints.maxWidth - 48,
                    height: 400,
                    padding: const EdgeInsets.all(16),
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
                          child: Obx(() {
                            final data = controller.getActivityDistribution();
                            return SfCircularChart(
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.right,
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
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Daily Activity Chart
                  Container(
                    width:
                        constraints.maxWidth > 800
                            ? 600
                            : constraints.maxWidth - 48,
                    height: 400,
                    padding: const EdgeInsets.all(16),
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
                                dateFormat: DateFormat('MMM d'),
                                intervalType: DateTimeIntervalType.days,
                                majorGridLines: const MajorGridLines(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                title: AxisTitle(text: 'Hours'),
                                majorGridLines: const MajorGridLines(
                                  width: 0.5,
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
      ),
    );
  }
}
