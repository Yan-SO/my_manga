import 'package:flutter/material.dart';

Future<bool?> showCustomAlert(
  BuildContext context, {
  required String title,
  required String message,
  bool showConfirm = true,
  String confirmText = 'Sim',
  String cancelText = 'Não',
  bool showOk = false,
  String okText = 'Ok',
}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showOk)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(okText),
            ),
          if (showConfirm)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(confirmText),
            ),
          if (showConfirm)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(cancelText),
            ),
        ],
      );
    },
  );
}
