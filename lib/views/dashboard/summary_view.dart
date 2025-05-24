import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gme_time_tracker/models/user_model.dart';
import 'package:gme_time_tracker/widgets/common_input_field.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:widgets_to_image/widgets_to_image.dart';
import '../../helpers/pdf_helper.dart';
import '../../models/activity_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/downloader.dart';
import '../../widgets/download_options_dialog.dart';
import 'controller/dashboard_controller.dart';
import 'controller/summary_controller.dart';
import 'package:flutter/services.dart';

class SummaryView extends StatelessWidget {
  final controller = Get.put(SummaryController());
  final GlobalKey _widgetKey = GlobalKey();

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
                  onTap: () async {
                    String month = controller.selectedMonth.value.toString();
                    String year = controller.selectedYear.value.toString();

                    UserModel? user =
                        Get.find<DashboardController>().user.value;

                    final ByteData logoData = await rootBundle.load(
                      'assets/logo.png',
                    );
                    final Uint8List logoBytes = logoData.buffer.asUint8List();

                    final Map<String, dynamic> userDetails = {
                      'Name': user?.firstName ?? '',
                      'Email': user?.email ?? '',
                      'Position': user?.position ?? '',
                      'Degree': user?.degree ?? '',
                      'Institution': user?.institution ?? '',
                      'Specialty': user?.specialty ?? '',
                      'Month/Year': '$month $year',
                      'Total Hours': controller.totalTime.toString(),
                    };

                    // Get activities
                    List<ActivityModel> activities = controller.activities;

                    await PdfGenerator.generateUserActivityPDF(
                      fileName: 'GME_Hours_${month}_$year',
                      userDetails: userDetails,
                      activityList: activities,
                      logoBytes: logoBytes,
                      copyrightText: '© 2025 GME Time Tracker',
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
                        child: WidgetsToImage(
                          controller: controller.controller,

                          child: RepaintBoundary(
                            key: _widgetKey,
                            child: Screenshot(
                              controller: controller.screenshotController,
                              child: Center(
                                child: Obx(() {
                                  final data =
                                      controller.getActivityDistribution();

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
                                      DoughnutSeries<
                                        ActivityDistribution,
                                        String
                                      >(
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
                                                  ? ChartDataLabelPosition
                                                      .outside
                                                  : ChartDataLabelPosition
                                                      .inside,
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
                          ),
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
                              dateFormat: intl.DateFormat(
                                isMobile ? 'd' : 'MMM d',
                              ),
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

// Future<Uint8List> renderWidgetToImage({
//   required Widget widget,
//   required double width,
//   required double height,
//   double pixelRatio = 3.0,
// }) async {
//   final repaintBoundary = RenderRepaintBoundary();

//   final renderView = RenderView(
//     view: WidgetsBinding.instance.platformDispatcher.views.first,
//     child: RenderPositionedBox(
//       alignment: Alignment.center,
//       child: repaintBoundary,
//     ),
//     configuration: ViewConfiguration(
//       logicalConstraints: BoxConstraints.tight(Size(width, height)),
//       devicePixelRatio: pixelRatio,
//     ),
//   );

//   final pipelineOwner = PipelineOwner();
//   final buildOwner = BuildOwner(focusManager: FocusManager());

//   pipelineOwner.rootNode = renderView;
//   renderView.prepareInitialFrame();

//   final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
//     container: repaintBoundary,
//     child: MediaQuery(
//       data: MediaQueryData(size: Size(width, height)),
//       child: Directionality(textDirection: TextDirection.ltr, child: widget),
//     ),
//   ).attachToRenderTree(buildOwner);

//   buildOwner.buildScope(rootElement);
//   buildOwner.finalizeTree();

//   pipelineOwner.flushLayout();
//   pipelineOwner.flushCompositingBits();
//   pipelineOwner.flushPaint();

//   // Optional wait if your widget has animations or charts
//   await Future.delayed(const Duration(milliseconds: 5000));

//   pipelineOwner.flushLayout();
//   pipelineOwner.flushCompositingBits();
//   pipelineOwner.flushPaint();

//   final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
//   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//   return byteData!.buffer.asUint8List();
// }

Future<Uint8List> renderWidgetToImage({
  required Widget widget,
  required double width,
  required double height,
  double pixelRatio = 3.0,
}) async {
  final repaintBoundary = RenderRepaintBoundary();

  final renderView = RenderView(
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(Size(width, height)),
      devicePixelRatio: pixelRatio,
    ),
    view: WidgetsBinding.instance.platformDispatcher.views.first,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: repaintBoundary,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());
  pipelineOwner.rootNode = renderView;

  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: Size(width, height)),
        child: widget,
      ),
    ),
  ).attachToRenderTree(buildOwner);

  // Perform build, layout, and paint
  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  // Let the microtasks complete
  await Future.delayed(Duration(milliseconds: 20));
  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<Uint8List?> captureWidgetAsImage(
  GlobalKey key, {
  double pixelRatio = 3.0,
}) async {
  try {
    RenderRepaintBoundary? boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    debugPrint('Error capturing image: $e');
    return null;
  }
}
