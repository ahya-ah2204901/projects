import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/student.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/providers/title_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GradeLevelScreenOG extends ConsumerStatefulWidget {
  const GradeLevelScreenOG({super.key});

  @override
  ConsumerState<GradeLevelScreenOG> createState() => _GradeLevelScreenState();
}

class _GradeLevelScreenState extends ConsumerState<GradeLevelScreenOG> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          String grade = '${index + 1}';
          return Padding(
            padding: const EdgeInsets.only(
                top: 25.0, bottom: 10, right: 30, left: 30),
            child: SizedBox(
              height: 90,
              child: ElevatedButton(
                onPressed: () async {
                  context.pushNamed(AppRouter.gradeStudents.name,
                      pathParameters: {'grade': grade});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightblue,
                  elevation: 3,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Grade $grade',
                  style: TextStyle(
                    fontSize: 25,
                    color: darkblue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
