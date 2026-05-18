import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/teacher.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/providers/teacher_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:accelaid/screens/widgets/progress_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashBoardScreen extends ConsumerStatefulWidget {
  const DashBoardScreen({super.key});

  @override
  ConsumerState<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  @override
  Widget build(BuildContext context) {
    final teacherProvider = ref.watch(teacherNotifierProvider);
    final studentProvider = ref.watch(studentNotifierProvider);
    return teacherProvider.when(
      data: (teacher) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/layout/dash_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  SizedBox(
                    height: 80,
                    width: 80,
                    child:
                        Image.asset('assets/images/layout/accelaid_icon.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 9.0, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Hello, ',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w300),
                            ),
                            Text(
                              '${teacher!.firstName}!',
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          'Welcome to AccelAid.',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: grey,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 40,
              bottom: 70,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: const Color.fromARGB(255, 224, 224, 224),
                child: SizedBox(
                  width: 330,
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: GestureDetector(
                      onTap: () {
                        context.goNamed(AppRouter.gradelevels.name);
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 25, bottom: 25, left: 25, right: 13),
                          child: StreamBuilder<double>(
                            stream: ref
                                .read(studentNotifierProvider.notifier)
                                .getProgAvg(teacher.email),
                            builder: (context, snapshot) {
                              double avgProgress = snapshot.data ?? 0.0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DASHBOARD',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${(avgProgress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize:
                                                  26, // Size of the percentage text
                                              fontWeight: FontWeight.bold,
                                              color: darkblue,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          StreamBuilder<int>(
                                            stream: ref
                                                .read(studentNotifierProvider
                                                    .notifier)
                                                .getStCount(teacher.email),
                                            builder: (context, snapshot) {
                                              int studentTotal =
                                                  snapshot.data ?? 0;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Average',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54),
                                                  ),
                                                  Text(
                                                                                            'STUDENT PROGRESS',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: darkblue,
                                                        letterSpacing: 0.7),
                                                  ),
                                                  SizedBox(height: 4),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, left: 10, top: 5),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    height: 80,
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: 1.0,
                                                      backgroundColor:
                                                          lightblue,
                                                      strokeWidth: 6.0,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 80,
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: avgProgress.clamp(
                                                          0.0, 1.0),
                                                      valueColor:
                                                          AlwaysStoppedAnimation(
                                                              darkblue),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      strokeWidth: 6.0,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.bar_chart_rounded,
                                                    color: darkblue,
                                                    size: 45,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Icon(Icons.people_alt_rounded,
                                          color: darkblue, size: 30),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      StreamBuilder<int>(
                                        stream: ref
                                            .read(studentNotifierProvider
                                                .notifier)
                                            .getStCount(teacher.email),
                                        builder: (context, snapshot) {
                                          int studentTotal = snapshot.data ?? 0;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total Students',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$studentTotal',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => ListTile(
        title: Text('Error: $error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
