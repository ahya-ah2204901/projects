import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/providers/title_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GenerateCompExamScreen extends ConsumerStatefulWidget {
  const GenerateCompExamScreen({super.key});

  @override
  ConsumerState<GenerateCompExamScreen> createState() =>
      _GradeLevelScreenState();
}

class _GradeLevelScreenState extends ConsumerState<GenerateCompExamScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/layout/gen_comp_exam_bg.png",
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 15.0, top: 45, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Generate Competency',
                      style: TextStyle(color: Colors.black87, fontSize: 25)),
                  Text(
                    'Exam',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 56,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 200),
            SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (BuildContext context, int index) {
                    String grade = '${6 - index}';
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 25.0, bottom: 10, right: 30, left: 30),
                      child: SizedBox(
                        height: 90,
                        child: ElevatedButton(
                          onPressed: () async {
                            ref
                                .read(titleNotifierProvider.notifier)
                                .setTitle('Generate Competency Exam');
                            context.pushNamed(
                                AppRouter.generateExamForGrade.name,
                                pathParameters: {'grade': grade});
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 3,
                              fixedSize: const Size(345, 80),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(70))),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),

                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [darkblue, Colors.blue.shade900],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.assignment,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      10), // Add some spacing between the circle and text
                              Text(
                                'Grade $grade Competency Exam',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: darkblue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ],
        ),
      ],
    );
  }
}
