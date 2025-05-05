import 'dart:io';
import 'package:excel/excel.dart';
import 'package:gme_time_tracker/utils/downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/activity_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ExcelHelper {
  static Future<void> exportActivities(
    List<ActivityModel> activities,
    String month,
    int year,
    String userName,
    String position,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['GME Core Faculty Hours Tracking'];

    // Add header styling
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Add headers
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('GME Core Faculty Hours Tracking')
      ..cellStyle = headerStyle;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('Position: $position')
      ..cellStyle = headerStyle;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
      ..value = TextCellValue('Month: $month')
      ..cellStyle = headerStyle;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
      ..value = TextCellValue('Name: $userName')
      ..cellStyle = headerStyle;

    // Add column headers
    final columnHeaders = [
      'Date of Activity',
      '# of Hours',
      'Category',
      'Detailed Description',
    ];
    for (var i = 0; i < columnHeaders.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4))
        ..value = TextCellValue(columnHeaders[i])
        ..cellStyle = headerStyle;
    }

    // Add data
    var rowIndex = 5;
    for (final activity in activities) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(DateFormat('MM/dd/yy').format(activity.date));

      final hours = activity.durationMinutes / 60;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(hours.toStringAsFixed(1));

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(activity.activityType);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(activity.notes ?? '');

      rowIndex++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 15.0);
    sheet.setColumnWidth(1, 12.0);
    sheet.setColumnWidth(2, 30.0);
    sheet.setColumnWidth(3, 50.0);

    final fileName = 'GME_Hours_${month}_$year.xlsx';
    final bytes = excel.encode();

    if (bytes != null) {
      if (kIsWeb) {
        // For web platform
        final blob = html.Blob([
          bytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', fileName)
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile platform
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Downloader.downloadFile(file: file);
      }
    }
  }
}
