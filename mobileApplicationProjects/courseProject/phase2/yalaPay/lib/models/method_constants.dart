import 'dart:ui';
import 'package:flutter/material.dart';

Color accentColor = const Color.fromARGB(255, 240, 173, 114);
Color primaryColor = const Color.fromARGB(255, 8, 21, 65);
Color loweropacityprimaryColor = const Color.fromARGB(223, 8, 21, 65);

Color secondaryColor = const Color.fromARGB(255, 70, 141, 222);
Color blankColor = const Color.fromARGB(255, 247, 244, 221);

void snackbarError(context, String errormessage) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errormessage),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
