import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/student.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:accelaid/screens/widgets/progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final String stId;
  const StudentProfileScreen({super.key, required this.stId});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  @override
  Widget build(BuildContext context) {
    Student? student =
        ref.read(studentNotifierProvider.notifier).getStudentById(widget.stId);
    double perc = student!.progress;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            (context.canPop())
                ? context.pop()
                : context.goNamed(AppRouter.dashboard.name);
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: Text(
          "Student Profile",
          style: TextStyle(
            fontSize: 23,
            color: darkblue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 10.0, right: 10, left: 10, top: 0),
        child: Column(
          children: [
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                elevation: 30,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 50, right: 30, left: 30, bottom: 30),
                  child: SizedBox(
                    width: 290,
                    height: 290,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('STUDENT NAME',
                                style: labelTextStyle(c: lightblue)),
                            const Spacer(),
                            Text('ID# ', style: labelTextStyle(c: lightblue)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(50, 116, 142, 173),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                student.stId,
                                style: labelTextStyle(c: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Text('   ${student.firstName} ${student.lastName}',
                            style: dataTextStyle(c: darkblue)),
                        const SizedBox(
                          height: 38,
                        ),
                        Text('DATE OF BIRTH',
                            style: labelTextStyle(c: lightblue)),
                        Text('    ${student.dob.toString().substring(0, 10)}',
                            style:
                                dataTextStyle(c: darkblue, w: FontWeight.w500)),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Text('STUDENT GRADE LEVEL',
                              style: labelTextStyle(c: darkblue)),
                        ),
                        Row(
                          children: [
                            Text('  LAST COMPLETED :',
                                style: labelTextStyle(c: lightblue)),
                            Text('  ${student.lastCompletedGradeLevel}',
                                style: labelTextStyle(c: darkblue))
                          ],
                        ),
                        Row(
                          children: [
                            Text('  CURRENT GRADE  :',
                                style: labelTextStyle(c: lightblue)),
                            Text('  ${student.gradeLevel}',
                                style: labelTextStyle(c: darkblue)),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text('PROGRESS',
                                style: labelTextStyle(c: darkblue)),
                            Spacer(),
                            Text(
                                '%${(student.progress * 100).toStringAsFixed(1)}',
                                style: labelTextStyle(c: darkblue))
                          ],
                        ),
                        Flexible(child: ProgressBar(progress: perc))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: darkblue,
                    elevation: 3,
                    fixedSize: const Size(345, 80),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  print("STUDENT HAS PLAN: ${student.hasStudyPlan}");
                  context.pushNamed(AppRouter.studentStudyPlan.name,
                      pathParameters: {
                        'stId': student.stId,
                        'studyPlan': student.studyPlan
                      });
                },
                child: const Text(
                  "View Study Plan",
                  style: TextStyle(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
            ),
            (student.hasStudyPlan)
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkblue,
                        elevation: 3,
                        fixedSize: const Size(345, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      context.pushNamed(AppRouter.studentProgress.name,
                          pathParameters: {'stId': student.stId});
                    },
                    child: const Text(
                      "View Student Progress",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: lightblue,
                        elevation: 3,
                        fixedSize: const Size(345, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      snackbarError(context,
                          'Student does not have a Study Plan yet.', darkblue);
                    },
                    child: const Text(
                      "View Student Progress",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 10),
            (student.hasStudyPlan)
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkblue,
                        elevation: 3,
                        fixedSize: const Size(345, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      context.pushNamed(
                          AppRouter.generatePracticeQuestions.name,
                          pathParameters: {'stId': student.stId});
                    },
                    child: const Text(
                      "Generate Practice Questions",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: lightblue,
                        elevation: 3,
                        fixedSize: const Size(345, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      snackbarError(context,
                          'Student does not have a Study Plan yet.', darkblue);
                    },
                    child: const Text(
                      "Generate Practice Questions",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 10),
            (student.hasStudyPlan)
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkblue,
                        elevation: 3,
                        fixedSize: const Size(345, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      context.pushNamed(
                          AppRouter.generateProgressAssessment.name,
                          pathParameters: {'stId': student.stId});
                    },
                    child: const Text(
                      "Generate Progress Assessments",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: lightblue,
                        elevation: 3,
                        fixedSize: const Size(345, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      snackbarError(context,
                          'Student does not have a Study Plan yet.', darkblue);
                    },
                    child: const Text(
                      "Generate Progress Assessments",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
