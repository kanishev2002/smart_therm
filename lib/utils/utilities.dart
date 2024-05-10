import 'package:flutter/material.dart';

class Utilities {
  static void showError(
    BuildContext context, {
    required Widget content,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Error'),
          content: content,
          actions: [
            TextButton(
              onPressed: Navigator.of(ctx).pop,
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
