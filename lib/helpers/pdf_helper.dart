import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/activity_model.dart';

class PdfGenerator {
  static Future<File> generateUserActivityPDF({
    required Map<String, dynamic> userDetails,
    required List<ActivityModel> activityList,
    required Uint8List logoBytes,
    required String copyrightText,
    required String fileName,
  }) async {
    final PdfDocument document = PdfDocument();

    // Load logo from assets
    final PdfBitmap logoImage = PdfBitmap(logoBytes);

    // Fonts
    final PdfFont titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      16,
      style: PdfFontStyle.bold,
    );
    final PdfFont headerFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

    /// Draw header on each page
    void drawHeaderFooter(PdfPage page) {
      final pageSize = page.getClientSize();
      final graphics = page.graphics;

      // Logo
      graphics.drawImage(
        logoImage,
        Rect.fromLTWH(pageSize.width - 70, 10, 60, 60),
      );

      // Title and date
      graphics.drawString(
        'Time Tracking Report',
        titleFont,
        bounds: Rect.fromLTWH(0, 10, pageSize.width - 80, 20),
      );
      graphics.drawString(
        'Generated on: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}',
        normalFont,
        bounds: Rect.fromLTWH(0, 35, pageSize.width - 80, 15),
      );

      // Footer
      graphics.drawString(
        copyrightText,
        normalFont,
        bounds: Rect.fromLTWH(0, pageSize.height - 30, pageSize.width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    }

    // Page 1: User Details + Pie Chart
    final PdfPage firstPage = document.pages.add();
    drawHeaderFooter(firstPage);

    double yOffset = 80;

    final PdfGraphics graphics = firstPage.graphics;
    graphics.drawString(
      'User Details',
      headerFont,
      bounds: Rect.fromLTWH(10, yOffset, 300, 20),
    );
    yOffset += 20;

    userDetails.forEach((key, value) {
      graphics.drawString(
        '$key: $value',
        normalFont,
        bounds: Rect.fromLTWH(10, yOffset, 500, 20),
      );
      yOffset += 18;
    });

    yOffset += 30;
    graphics.drawString(
      'Activities Overview',
      headerFont,
      bounds: Rect.fromLTWH(10, yOffset, 300, 20),
    );
    yOffset += 50;

    // Draw Pie Chart
    if (activityList.isNotEmpty) {
      final double pieSize = 280;
      final Rect pieRect = Rect.fromLTWH(10, yOffset, pieSize, pieSize);
      double total = activityList.fold(
        0,
        (sum, item) => sum + item.durationMinutes,
      );
      double startAngle = 0;

      final List<PdfBrush> segmentBrushes = [
        PdfBrushes.red,
        PdfBrushes.green,
        PdfBrushes.blue,
        PdfBrushes.orange,
        PdfBrushes.purple,
        PdfBrushes.brown,
        PdfBrushes.pink,
        PdfBrushes.teal,
        PdfBrushes.yellow,
        PdfBrushes.gray,
        PdfBrushes.cyan,
        PdfBrushes.magenta,
        PdfBrushes.lime,
        PdfBrushes.indigo,
      ];

      for (int i = 0; i < activityList.length; i++) {
        final activity = activityList[i];
        final double sweepAngle = (activity.durationMinutes / total) * 360;
        final PdfBrush brush = segmentBrushes[i % segmentBrushes.length];

        graphics.drawPie(
          pieRect,
          startAngle,
          sweepAngle,
          brush: brush,
          pen: PdfPen(
            PdfColor(0, 0, 0),
            width: 0.33,
            dashStyle: PdfDashStyle.solid,
            lineCap: PdfLineCap.round,
            lineJoin: PdfLineJoin.round,
          ),
        );

        // Legend
        graphics.drawRectangle(
          brush: brush,
          bounds: Rect.fromLTWH(pieRect.right + 30, yOffset + (i * 20), 10, 10),
        );
        graphics.drawString(
          '${activity.activityType} (${_formatDuration(activity.durationMinutes)})',
          normalFont,
          bounds: Rect.fromLTWH(
            pieRect.right + 50,
            yOffset + (i * 20) - 3,
            200,
            20,
          ),
        );

        startAngle += sweepAngle;
      }
    }

    // Page 2 and onward: Table View
    const int rowsPerPage = 20;
    final int totalPages = (activityList.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final PdfPage page = document.pages.add();
      drawHeaderFooter(page);
      final PdfGrid grid = PdfGrid();

      grid.columns.add(count: 4);
      grid.headers.add(1);
      final PdfGridRow header = grid.headers[0];
      // header.cells[0].value = 'Index';
      header.cells[0].value = 'Date';
      header.cells[1].value = 'Activity Name';
      header.cells[2].value = 'Duration';
      header.cells[3].value = 'Description';

      final int start = pageIndex * rowsPerPage;
      final int end =
          (start + rowsPerPage > activityList.length)
              ? activityList.length
              : start + rowsPerPage;

      for (int i = start; i < end; i++) {
        final activity = activityList[i];
        final PdfGridRow row = grid.rows.add();
        // row.cells[0].value = (i + 1).toString();
        row.cells[0].value = DateFormat('yyyy-MM-dd').format(activity.date);
        row.cells[1].value = activity.activityType;
        row.cells[2].value = _formatDuration(activity.durationMinutes);
        row.cells[3].value = activity.notes ?? '';
      }

      grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, top: 2, right: 2, bottom: 2),
        font: normalFont,
      );

      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, 80, page.getClientSize().width, 500),
      );
    }

    // Save and return file
    final List<int> bytes = await document.save();
    document.dispose();

    final Directory? dir;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final File file = File('${dir?.path}/$fileName.pdf');
    return await file.writeAsBytes(bytes);
  }

  static String _formatDuration(int minutes) {
    final int hrs = minutes ~/ 60;
    final int mins = (minutes % 60).round();
    return '${hrs}h ${mins}m';
  }
}
