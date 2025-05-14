import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'toast_helper.dart';

class Downloader {
  static Future<void> downloadFile({required File file}) async {
    try {
      if (await _requestStoragePermission()) {
        // Get the Downloads directory
        Directory? downloadsDir;

        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }

        final fileName = file.path.split('/').last;
        final filePath = '${downloadsDir.path}/$fileName';

        await file.copy(filePath);

        ToastHelper.showSuccessToast("File saved to Downloads folder");
      } else {
        throw ("Storage permission denied");
      }
    } catch (e) {
      print(e);
      ToastHelper.showErrorToast("Download failed: $e");
    }
  }

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      PermissionStatus status;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }
      return status.isGranted;
    } else {
      return true;
    }
  }
}
