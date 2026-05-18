import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmDeletionDialog extends ConsumerStatefulWidget {
  final VoidCallback onDelete;
  const ConfirmDeletionDialog({super.key, required this.onDelete});

  @override
  ConsumerState<ConfirmDeletionDialog> createState() =>
      _ConfirmDeletionDialogState();
}

class _ConfirmDeletionDialogState extends ConsumerState<ConfirmDeletionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text(
        "Are you sure you want to delete?",
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
                onPressed: () {
                  widget.onDelete();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red[900]),
                ))
          ],
        ),
      ],
    );
  }
}
