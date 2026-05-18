import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleSelection extends ConsumerStatefulWidget {
  final void Function(String role) onRoleChanged;
  final TextEditingController supervisorEmailController;

  const RoleSelection({
    super.key,
    required this.onRoleChanged,
    required this.supervisorEmailController,
  });

  @override
  ConsumerState<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends ConsumerState<RoleSelection> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT ROLE:",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text("Worker"),
          value: "Worker",
          groupValue: selectedRole,
          onChanged: (String? value) {
            setState(() => selectedRole = value);
            widget.onRoleChanged(value!);
          },
        ),
        RadioListTile<String>(
          title: const Text("Supervisor"),
          value: "Supervisor",
          groupValue: selectedRole,
          onChanged: (String? value) {
            setState(() => selectedRole = value);
            widget.onRoleChanged(value!);
          },
        ),

        const SizedBox(height: 12),

        if (selectedRole == "Worker") ...[
          const Text(
            "Supervisor Email",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: widget.supervisorEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Enter supervisor email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
