import 'package:flutter/material.dart';

Future<String?> showOutcomeDialog(BuildContext context) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Mark as Done'),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Outcome (e.g. Connected, will close next week)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
