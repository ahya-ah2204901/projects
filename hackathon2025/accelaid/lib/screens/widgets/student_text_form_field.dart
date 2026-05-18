import 'package:flutter/material.dart';

class StudentTextFormField extends StatelessWidget {
  final String label;
  final bool autoValidate;
  final FormFieldValidator<String>? validator;
  final TextEditingController controller;

  const StudentTextFormField(
      {super.key,
        this.label = "",
        required this.controller,
        this.autoValidate = false,
        required this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          autovalidateMode: autoValidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
       
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.edit),
          ),
          validator: validator,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
