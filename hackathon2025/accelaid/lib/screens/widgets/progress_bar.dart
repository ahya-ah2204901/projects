import 'package:accelaid/models/color_const.dart';
import 'package:flutter/cupertino.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0
  final double height;

  ProgressBar({Key? key, required this.progress, this.height = 8.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10, top: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Container(
              height: 11,
              color: lightblue,
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(color: darkblue),
            ),
          ],
        ),
      ),
    );
  }
}
