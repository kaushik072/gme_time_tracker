import 'package:flutter/material.dart';

class DownloadOptionsDialog extends StatelessWidget {
  final VoidCallback onExcelSelected;
  final VoidCallback onPdfSelected;

  const DownloadOptionsDialog({
    Key? key,
    required this.onExcelSelected,
    required this.onPdfSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Excel'),
            onTap: () {
              Navigator.pop(context);
              onExcelSelected();
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF'),
            onTap: () {
              Navigator.pop(context);
              onPdfSelected();
            },
          ),
        ],
      ),
    );
  }
}
