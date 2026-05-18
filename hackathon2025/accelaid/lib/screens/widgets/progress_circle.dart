import 'package:accelaid/models/color_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressCircle extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0
  final double size; // Size of the progress circle

  ProgressCircle({Key? key, required this.progress, this.size = 60.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10, top: 5),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0, // Full circle
                backgroundColor: lightblue,
                strokeWidth: 6.0,
              ),
            ),
            // Foreground Circle (Progress)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0), // The progress value
                valueColor: AlwaysStoppedAnimation(darkblue),
                backgroundColor: Colors.transparent,
                strokeWidth: 6.0,
              ),
            ),
            // Percentage Text in the center
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: size * 0.3, // Size of the percentage text
                fontWeight: FontWeight.bold,
                color: darkblue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
