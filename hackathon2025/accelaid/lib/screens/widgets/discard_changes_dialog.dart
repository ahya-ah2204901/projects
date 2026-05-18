import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unsaved Changes"),
      content: const Text(
          "Your changes are not saved. Discard the changes or continue editing?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text("Continue Editing")),
            TextButton(
                onPressed: () {
                  print("DISCARDING!");
                  context.pop();
                  context.pop();
                }, // could depend on where it's used
                child: Text(
                  "Discard",
                  style: TextStyle(color: Colors.red[900]),
                )),
          ],
        ),
      ],
    );
  }
}
