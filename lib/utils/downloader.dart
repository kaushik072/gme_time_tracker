import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:gme_time_tracker/utils/toast_helper.dart';

class Downloader {
  static final MediaStore _mediaStore = MediaStore();

  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final sdk = await _mediaStore.getPlatformSDKInt();
      if (sdk <= 28) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    }
    return true;
  }

  static Future<void> saveFileToDownloads({required File file}) async {
    if (!await _requestPermissions()) {
      ToastHelper.showErrorToast("Please grant storage permission");
      return;
    }

    if (!await file.exists()) {
      ToastHelper.showErrorToast("Source file does not exist");
      return;
    }

    try {
      if (Platform.isAndroid) {
        await _saveFileToAndroidDownloads(file);
      } else if (Platform.isIOS) {
        await _saveFileToIOSDocuments(file);
      } else {
        ToastHelper.showErrorToast("Unsupported platform");
        return;
      }
      ToastHelper.showSuccessToast("File saved successfully");
    } catch (e) {
      ToastHelper.showErrorToast("Failed to save file");
    }
  }

  static Future<void> _saveFileToAndroidDownloads(File sourceFile) async {
    MediaStore.appFolder = "GME Time Tracker";

    String extension = sourceFile.path.split('.').last;
    String originalName = sourceFile.path.split('/').last.split('.').first;

    int candidateIndex = 0;
    while (true) {
      final doesExist = await _mediaStore.isFileExist(
        dirType: DirType.download,
        fileName:
            "$originalName${candidateIndex > 0 ? " ($candidateIndex)" : ""}.$extension",
        dirName: DirType.download.defaults,
      );

      if (doesExist) {
        candidateIndex++;
        continue;
      }

      String tempPath;

      if (candidateIndex == 0) {
        tempPath = sourceFile.path;
      } else {
        final tempDir = await getTemporaryDirectory();
        tempPath =
            '${tempDir.path}/$originalName${candidateIndex > 0 ? " ($candidateIndex)" : ""}.$extension';
        await sourceFile.copy(tempPath);
      }

      await _mediaStore.saveFile(
        dirType: DirType.download,
        tempFilePath: tempPath,
        dirName: DirType.download.defaults,
      );

      return;
    }
  }

  static Future<void> _saveFileToIOSDocuments(File sourceFile) async {
    final docsDir = await getApplicationDocumentsDirectory();

    String extension = sourceFile.path.split('.').last;
    String originalName = sourceFile.path.split('/').last.split('.').first;

    int candidateIndex = 0;

    while (true) {
      final targetPath =
          '${docsDir.path}/$originalName${candidateIndex > 0 ? " ($candidateIndex)" : ""}.$extension';
      final targetFile = File(targetPath);

      if (await targetFile.exists()) {
        candidateIndex++;
        continue;
      }

      await sourceFile.copy(targetPath);
      return;
    }
  }
}
