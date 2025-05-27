import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonConfirmDialog extends StatelessWidget {
  const CommonConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.confirmText,
  });

  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: Text(content, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: GoRouter.of(context).pop,
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
