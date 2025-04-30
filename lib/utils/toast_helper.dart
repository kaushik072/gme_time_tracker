import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static ToastificationStyle toastStyle = ToastificationStyle.fillColored;
  static Duration autoCloseDuration = const Duration(seconds: 3);
  static Alignment alignment =
      kIsWeb ? Alignment.topRight : Alignment.bottomCenter;

  static void showSuccessToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.success,
      style: toastStyle,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  static void showErrorToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.error,
      style: toastStyle,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  static void showInfoToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.info,
      style: toastStyle,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }

  static void showWarningToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.warning,
      style: toastStyle,
      autoCloseDuration: autoCloseDuration,
      alignment: alignment,
    );
  }
}
