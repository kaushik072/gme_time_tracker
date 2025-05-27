import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'toast_helper.dart';

class Downloader {
  static Future<void> downloadFile({required File file}) async {
    try {
      // Request permission
      if (!await _requestStoragePermission()) {
        throw "Storage permission denied";
      }

      // Determine download path
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        // Save to the public Downloads directory on Android
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        // Save to Documents directory, and make it visible to Files app
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw "Downloads directory not found";
      }

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final fileName = file.path.split('/').last;
      final filePath = '${downloadsDir.path}/$fileName';
      await file.copy(filePath);

      ToastHelper.showSuccessToast("File downloaded successfully");
    } catch (e) {
      ToastHelper.showErrorToast("Download failed: $e");
    }
  }

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        final status = await Permission.photos.request(); // Scoped storage
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // No need for storage permission on iOS
      return true;
    }
    return false;
  }
}
