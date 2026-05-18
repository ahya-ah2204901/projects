import 'package:flutter/material.dart';

void snackbarError(context, String errormessage) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errormessage),
        backgroundColor: const Color.fromARGB(255, 8, 21, 65),
        behavior: SnackBarBehavior.floating,
      ),
    );
