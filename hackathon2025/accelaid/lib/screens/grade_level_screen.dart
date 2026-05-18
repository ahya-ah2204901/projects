import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/providers/grade_student_search_provider.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/providers/teacher_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:accelaid/screens/widgets/progress_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GradeLevelScreen extends ConsumerStatefulWidget {
  const GradeLevelScreen({super.key});

  @override
  ConsumerState<GradeLevelScreen> createState() => _GradeLevelScreenState();
}

class _GradeLevelScreenState extends ConsumerState<GradeLevelScreen> {
  @override
  Widget build(BuildContext context) {
    final teacherprovider = ref.watch(teacherNotifierProvider);

    return
  Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/layout/grade_level_bg3.png",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 90, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grade Level of',
                        style: TextStyle(color: Colors.black87, fontSize: 25)),
                    Text(
                      'Students',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 46,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 270),
              SizedBox(
                height: 270,
                child: teacherprovider.when(
                  data: (teacher) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        int gradeNum = 6 - index;
                        return StreamBuilder<double>(
                          stream: ref
                              .read(studentNotifierProvider.notifier)
                              .getProgAvgByGrade(
                                "$gradeNum",
                                teacher!.email,
                              ),
                          builder: (context, snapshot) {
                            double progressPerGrade = snapshot.data ?? 0.0;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                      AppRouter.gradeStudents.name,
                                      pathParameters: {'grade': "$gradeNum"});
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(2, 4),
                                      )
                                    ],
                                  ),
                                  child: StreamBuilder<int>(
                                    stream: ref
                                        .read(studentNotifierProvider.notifier)
                                        .getStCountByGrade(
                                          "$gradeNum",
                                          teacher.email,
                                        ),
                                    builder: (context, snapshot) {
                                      int countPerGrade = snapshot.data ?? 0;
                                      return Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ProgressCircle(
                                                  progress: progressPerGrade,
                                                  size: 105),
                                              const SizedBox(height: 40),
                                              Text(
                                                'GRADE $gradeNum',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                '$countPerGrade Students',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.9,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        ],

    );
  }
}
