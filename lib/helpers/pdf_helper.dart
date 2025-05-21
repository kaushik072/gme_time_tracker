import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as Math;

import '../models/activity_model.dart';

class PdfGenerator {
  // Add helper method to merge activities
  static List<ActivityModel> _getMergedActivitiesForChart(
    List<ActivityModel> activities,
  ) {
    // Create a map to store merged activities
    final Map<String, ActivityModel> mergedMap = {};

    // Merge activities with same activityType
    for (var activity in activities) {
      if (mergedMap.containsKey(activity.activityType)) {
        // If activity type exists, add duration to existing entry
        final existingActivity = mergedMap[activity.activityType]!;
        mergedMap[activity.activityType] = ActivityModel(
          id: existingActivity.id,
          userId: existingActivity.userId,
          activityType: existingActivity.activityType,
          durationMinutes:
              existingActivity.durationMinutes + activity.durationMinutes,
          date: existingActivity.date, // Keep the first date
          notes: existingActivity.notes, // Keep the first notes
          isManual: existingActivity.isManual,
          status: existingActivity.status,
          createdAt: existingActivity.createdAt,
        );
      } else {
        // If activity type doesn't exist, add new entry
        mergedMap[activity.activityType] = activity;
      }
    }

    // Convert map values to list and sort by duration (descending)
    return mergedMap.values.toList()
      ..sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
  }

  static Future<dynamic> generateUserActivityPDF({
    required Map<String, dynamic> userDetails,
    required List<ActivityModel> activityList,
    required Uint8List logoBytes,
    required String copyrightText,
    required String fileName,
  }) async {
    // Create merged list for chart view
    final List<ActivityModel> mergedActivitiesForChart =
        _getMergedActivitiesForChart(activityList);

    final PdfDocument document = PdfDocument();

    // Load logo from assets
    final PdfBitmap logoImage = PdfBitmap(logoBytes);

    // Color palette
    final PdfColor sectionBgColor = PdfColor(245, 247, 250);
    final PdfColor sectionTitleColor = PdfColor(44, 62, 80);
    final PdfColor tableHeaderColor = PdfColor(76, 175, 80);
    final PdfColor tableRowAltColor = PdfColor(232, 245, 233);
    final PdfColor donutBgColor = PdfColor(255, 255, 255);

    // Fonts
    final PdfFont sectionTitleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      16,
      style: PdfFontStyle.bold,
    );
    final PdfFont fieldLabelFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final PdfFont fieldValueFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont legendFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final PdfFont durationFont = PdfStandardFont(PdfFontFamily.helvetica, 8);

    final PdfFont donutCenterFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      20,
      style: PdfFontStyle.bold,
    );
    final PdfFont donutLabelFont = PdfStandardFont(PdfFontFamily.helvetica, 14);

    // Section padding/margin
    const double sectionMargin = 32;
    const double sectionPadding = 20;

    /// Draw header on each page
    void drawHeaderFooter(PdfPage page) {
      final pageSize = page.getClientSize();
      final graphics = page.graphics;

      // Header background
      graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(180, 180, 180)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width, 75),
      );

      // Centered title and date
      double headerBoxHeight = 75;
      double titleFontSize = 22;
      double logoHeight = 40;
      double titleY = (headerBoxHeight / 2) - titleFontSize;
      double dateY = titleY + 30;
      double logoY = (headerBoxHeight - logoHeight) / 2;

      graphics.drawString(
        'Time Tracking Report',
        PdfStandardFont(PdfFontFamily.helvetica, 22, style: PdfFontStyle.bold),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, titleY, pageSize.width - 115, 30),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
      graphics.drawString(
        'Generated on: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, dateY, pageSize.width - 115, 20),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
      graphics.drawImage(
        logoImage,
        Rect.fromLTWH(pageSize.width - 70, logoY, 40, 40),
      );

      // Footer
      graphics.drawString(
        copyrightText,
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(0, pageSize.height - 30, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    }

    // Page 1: User Details + Donut Chart
    final PdfPage firstPage = document.pages.add();
    drawHeaderFooter(firstPage);

    final pageSize = firstPage.getClientSize();
    double yOffset = 75 + sectionMargin;

    final PdfGraphics graphics = firstPage.graphics;

    // --- User Details Section Card ---
    final double userDetailsPadding = sectionPadding;
    final double userDetailsMargin = sectionMargin;
    final double userDetailsLabelWidth = 80;
    final double userDetailsValueWidth = 140;
    final double userDetailsRowHeight = 22;
    final int userDetailsRows = 4;
    final int userDetailsColumns = 2;
    final double userDetailsTitleHeight = 28;
    final double userDetailsContentHeight =
        userDetailsRows * userDetailsRowHeight;
    final double userDetailsCardHeight =
        userDetailsTitleHeight +
        userDetailsContentHeight +
        userDetailsPadding * 2;

    final double cardX = userDetailsMargin;
    final double cardY = yOffset;
    final double cardWidth = pageSize.width - 2 * userDetailsMargin;
    final double cardHeight = userDetailsCardHeight;

    graphics.drawRectangle(
      brush: PdfSolidBrush(sectionBgColor),
      bounds: Rect.fromLTWH(cardX, cardY, cardWidth, cardHeight),
      pen: PdfPen(PdfColor(220, 220, 220)),
    );

    // Section Title inside card
    graphics.drawString(
      'User Details',
      sectionTitleFont,
      brush: PdfSolidBrush(sectionTitleColor),
      bounds: Rect.fromLTWH(
        cardX + userDetailsPadding,
        cardY + userDetailsPadding,
        200,
        userDetailsTitleHeight,
      ),
    );

    // User Details Fields in two columns, styled
    final leftFields = ['Name', 'Degree', 'Institution', 'Specialty'];
    final rightFields = ['Email', 'Position', 'Month/Year', ''];
    double leftColX = cardX + userDetailsPadding;
    double rightColX = cardX + cardWidth / 2 + userDetailsPadding / 2;
    double firstRowY = cardY + userDetailsPadding + userDetailsTitleHeight;
    final PdfFont smallFieldLabelFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11, // 1pt smaller
      style: PdfFontStyle.bold,
    );
    final PdfFont smallFieldValueFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11, // 1pt smaller
    );
    for (int i = 0; i < userDetailsRows; i++) {
      // Left column
      if (i < leftFields.length && leftFields[i].isNotEmpty) {
        final field = leftFields[i];
        final value = userDetails[field] ?? '';
        graphics.drawString(
          '$field:',
          smallFieldLabelFont,
          bounds: Rect.fromLTWH(
            leftColX,
            firstRowY + i * userDetailsRowHeight,
            userDetailsLabelWidth,
            userDetailsRowHeight,
          ),
        );
        graphics.drawString(
          value,
          smallFieldValueFont,
          bounds: Rect.fromLTWH(
            leftColX + userDetailsLabelWidth + 5,
            firstRowY + i * userDetailsRowHeight,
            userDetailsValueWidth,
            userDetailsRowHeight,
          ),
        );
      }
      // Right column
      if (i < rightFields.length && rightFields[i].isNotEmpty) {
        final field = rightFields[i];
        final value = userDetails[field] ?? '';
        graphics.drawString(
          '$field:',
          smallFieldLabelFont,
          bounds: Rect.fromLTWH(
            rightColX,
            firstRowY + i * userDetailsRowHeight,
            userDetailsLabelWidth,
            userDetailsRowHeight,
          ),
        );
        graphics.drawString(
          value,
          smallFieldValueFont,
          bounds: Rect.fromLTWH(
            rightColX + userDetailsLabelWidth + 5,
            firstRowY + i * userDetailsRowHeight,
            userDetailsValueWidth,
            userDetailsRowHeight,
          ),
        );
      }
    }
    yOffset = cardY + cardHeight + sectionMargin;

    // --- Activities Overview Section Title ---
    graphics.drawString(
      'Activities Overview',
      sectionTitleFont,
      brush: PdfSolidBrush(sectionTitleColor),
      bounds: Rect.fromLTWH(cardX, yOffset, 300, 22),
    );
    yOffset += 30;

    // --- Donut Chart and Legend Section ---
    if (mergedActivitiesForChart.isNotEmpty) {
      // Layout constants
      final double chartSectionWidth = cardWidth;
      final double baseDonutSize = 180;
      final double donutSize =
          baseDonutSize * 1.4; // 40% bigger (20% more than before)
      final double baseLegendBoxSize = 10;
      final double legendBoxSize = baseLegendBoxSize * 0.8; // 20% smaller
      final double baseLegendSpacingX = 160;
      final double legendSpacingX = baseLegendSpacingX * 0.8; // 20% smaller
      final double baseLegendSpacingY = 22;
      final double legendSpacingY = baseLegendSpacingY * 0.8; // 20% smaller
      int legendColumns = mergedActivitiesForChart.length > 10 ? 3 : 2;
      int legendRows = (mergedActivitiesForChart.length / legendColumns).ceil();

      // Calculate section height based on chart and legend
      final double chartTopPadding = 20;
      final double legendTopPadding =
          18 * 1.3; // 30% more space between chart and legend
      final double chartSectionHeight =
          chartTopPadding +
          donutSize +
          legendTopPadding +
          legendRows * legendSpacingY +
          20;

      final double chartSectionY = yOffset;
      final double chartSectionX = cardX;

      // Draw section background
      graphics.drawRectangle(
        brush: PdfSolidBrush(donutBgColor),
        bounds: Rect.fromLTWH(
          chartSectionX,
          chartSectionY,
          chartSectionWidth,
          chartSectionHeight,
        ),
        pen: PdfPen(PdfColor(220, 220, 220)),
      );

      // Donut chart (centered horizontally)
      final double donutX = chartSectionX + (chartSectionWidth - donutSize) / 2;
      final double donutY = chartSectionY + chartTopPadding;
      final Rect donutRect = Rect.fromLTWH(
        donutX,
        donutY,
        donutSize,
        donutSize,
      );

      double total = mergedActivitiesForChart.fold(
        0,
        (sum, item) => sum + item.durationMinutes,
      );
      double startAngle = 0;

      final List<PdfColor> donutColors = [
        PdfColor(76, 175, 80),
        PdfColor(33, 150, 243),
        PdfColor(255, 193, 7),
        PdfColor(244, 67, 54),
        PdfColor(156, 39, 176),
        PdfColor(255, 87, 34),
        PdfColor(0, 188, 212),
        PdfColor(205, 220, 57),
        PdfColor(121, 85, 72),
        PdfColor(63, 81, 181),
      ];

      // Draw donut segments with reduced gap and add durationText inside each segment
      for (int i = 0; i < mergedActivitiesForChart.length; i++) {
        final activity = mergedActivitiesForChart[i];
        final double sweepAngle = (activity.durationMinutes / total) * 360;
        final PdfBrush brush = PdfSolidBrush(
          donutColors[i % donutColors.length],
        );

        // Draw donut segment
        graphics.drawPie(
          donutRect,
          startAngle,
          sweepAngle,
          brush: brush,
          pen: PdfPen(PdfColor(255, 255, 255), width: 2),
        );

        // Draw durationText inside the segment (centered along the arc)
        final double midAngle =
            (startAngle + sweepAngle / 2) * (3.1415926535 / 180);
        final double arcRadius = donutSize / 2 * 0.75; // 75% out from center
        final double textX =
            donutX + donutSize / 2 + arcRadius * Math.cos(midAngle) - 20;
        final double textY =
            donutY + donutSize / 2 + arcRadius * Math.sin(midAngle) - 8;
        String durationText = _formatDuration(activity.durationMinutes);
        graphics.drawString(
          durationText,
          durationFont,
          brush: PdfSolidBrush(sectionTitleColor),
          bounds: Rect.fromLTWH(textX, textY, 40, 16),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
        );

        startAngle += sweepAngle;
      }

      // Draw white circle in center for donut effect
      final double centerCircleSize = donutSize * 0.60;
      final double centerCircleX = donutX + (donutSize - centerCircleSize) / 2;
      final double centerCircleY = donutY + (donutSize - centerCircleSize) / 2;
      graphics.drawEllipse(
        Rect.fromLTWH(
          centerCircleX,
          centerCircleY,
          centerCircleSize,
          centerCircleSize,
        ),
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        pen: PdfPen(PdfColor(255, 255, 255)),
      );

      // Draw total label and value in center
      graphics.drawString(
        'Total Hours',
        donutLabelFont,
        brush: PdfSolidBrush(sectionTitleColor),
        bounds: Rect.fromLTWH(
          centerCircleX,
          centerCircleY + centerCircleSize / 4,
          centerCircleSize,
          20,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      graphics.drawString(
        _formatDuration(total.toInt()),
        donutCenterFont,
        brush: PdfSolidBrush(sectionTitleColor),
        bounds: Rect.fromLTWH(
          centerCircleX,
          centerCircleY + centerCircleSize / 2 - 5,
          centerCircleSize,
          30,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );

      // --- Legend below chart, centered in grid ---
      final double legendGridWidth = legendColumns * legendSpacingX;
      // Ensure legend grid never starts outside the section box
      final double legendStartX =
          chartSectionX +
          Math.max((chartSectionWidth - legendGridWidth) / 2, 0);
      final double legendStartY = donutY + donutSize + legendTopPadding;

      for (int i = 0; i < mergedActivitiesForChart.length; i++) {
        final activity = mergedActivitiesForChart[i];
        final PdfBrush brush = PdfSolidBrush(
          donutColors[i % donutColors.length],
        );
        int col = i % legendColumns;
        int row = i ~/ legendColumns;
        final double legendItemX = legendStartX + col * legendSpacingX;
        final double legendItemY = legendStartY + row * legendSpacingY;

        // Color box
        graphics.drawRectangle(
          brush: brush,
          bounds: Rect.fromLTWH(
            legendItemX,
            legendItemY,
            legendBoxSize,
            legendBoxSize,
          ),
        );
        // Activity label
        graphics.drawString(
          activity.activityType,
          legendFont,
          bounds: Rect.fromLTWH(
            legendItemX + legendBoxSize + 6,
            legendItemY - 2,
            120,
            12,
          ),
        );
      }

      yOffset = chartSectionY + chartSectionHeight + sectionMargin;
    }

    // --- Table View Section ---
    // Always start table view on a new page
    final PdfPage tablePage = document.pages.add();
    drawHeaderFooter(tablePage);
    double tableYOffset = 75 + sectionMargin + 30;

    tablePage.graphics.drawString(
      'Activity Log',
      sectionTitleFont,
      brush: PdfSolidBrush(sectionTitleColor),
      bounds: Rect.fromLTWH(cardX, tableYOffset, 300, 22),
    );
    tableYOffset += 30;

    const int rowsPerPage = 15; // Show 15 entries per page
    final int totalPages = (activityList.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final PdfPage page = (pageIndex == 0) ? tablePage : document.pages.add();
      if (pageIndex != 0) {
        drawHeaderFooter(page);
        tableYOffset = 75 + sectionMargin + 30;
      }

      PdfGrid grid = PdfGrid();
      grid.columns.add(count: 4);
      grid.headers.add(1);
      PdfGridRow header = grid.headers[0];
      header.cells[0].value = 'Date';
      header.cells[1].value = 'Activity Name';
      header.cells[2].value = 'Duration';
      header.cells[3].value = 'Description';

      int start = pageIndex * rowsPerPage;
      int end =
          (start + rowsPerPage > activityList.length)
              ? activityList.length
              : (start + rowsPerPage);

      for (int i = start; i < end; i++) {
        final activity = activityList[i];
        PdfGridRow row = grid.rows.add();
        row.cells[0].value = DateFormat('yyyy-MM-dd').format(activity.date);
        row.cells[1].value = activity.activityType;
        row.cells[2].value = _formatDuration(activity.durationMinutes);
        row.cells[3].value = (activity.notes ?? '');
      }

      // Apply a professional table style (using PdfGridBuiltInStyle.listTable4Accent5)
      grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
      grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 6, top: 4, right: 6, bottom: 4),
        font: normalFont,
      );
      // (Optional) customize header style if desired, e.g.:
      header.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
      header.style.textBrush = PdfBrushes.white;
      for (int i = 0; i < header.cells.count; i++) {
        header.cells[i].style.cellPadding = PdfPaddings(
          bottom: 5,
          left: 5,
          right: 5,
          top: 5,
        );
      }

      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
          cardX,
          tableYOffset,
          page.getClientSize().width - 2 * cardX,
          500,
        ),
      );
    }

    // Save and return file
    final List<int> bytes = await document.save();
    document.dispose();

    if (kIsWeb) {
      // For web platform
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();
      html.Url.revokeObjectUrl(url);
      return null; // Return null for web since we're triggering download directly
    } else {
      final Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final File file = File('${dir?.path}/$fileName.pdf');
      return await file.writeAsBytes(bytes);
    }
  }

  static String _formatDuration(int minutes) {
    final int hrs = minutes ~/ 60;
    final int mins = (minutes % 60).round();
    return '${hrs}h ${mins}m';
  }
}
