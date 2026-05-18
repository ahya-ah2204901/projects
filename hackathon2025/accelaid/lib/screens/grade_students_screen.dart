import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/student.dart';
import 'package:accelaid/providers/grade_student_search_provider.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/providers/title_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:accelaid/screens/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GradeStudentScreen extends ConsumerStatefulWidget {
  final String grade;
  const GradeStudentScreen({super.key, required this.grade});

  @override
  ConsumerState<GradeStudentScreen> createState() =>
      _GradeStudentsScreenState();
}

class _GradeStudentsScreenState extends ConsumerState<GradeStudentScreen> {
  @override
  Widget build(BuildContext context) {
    final studentProvider = ref.watch(studentNotifierProvider);
    final studentNotifier = ref.read(studentNotifierProvider.notifier);
    final searchProvider = ref.watch(gradeStudentSearchNotifierProvider);
    final searchNotifier =
        ref.read(gradeStudentSearchNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 226, 226),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () {
            (context.canPop())
                ? context.pop()
                : context.goNamed(AppRouter.gradelevels.name);
            ref.read(titleNotifierProvider.notifier).setTitle('');
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: studentProvider.when(
        data: (students) {
          final isSearchEmpty = searchProvider.isEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30))),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Students of',
                      style: TextStyle(color: Colors.black87, fontSize: 25),
                    ),
                    Text(
                      'Grade ${widget.grade}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 46,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 231, 231, 231),
                          borderRadius: BorderRadius.circular(15)),
                      child: TextFormField(
                        initialValue: searchProvider,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black87,
                            ),
                            hintText: "Search Students",
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: 15, height: 2)),
                        onChanged: (query) {
                          searchNotifier.setSearch(query);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.5, // Adjust this height as needed
                      child: (isSearchEmpty)
                          ? StreamBuilder<List<Student>>(
                              stream: studentNotifier
                                  .getGradeStudents(widget.grade),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                final filteredStudents = snapshot.data ?? [];
                                return studentCardList(filteredStudents);
                              },
                            )
                          : StreamBuilder<List<Student>>(
                              stream: studentNotifier.searchStudents(
                                  widget.grade, searchProvider),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                final filteredStudents = snapshot.data ?? [];
                                return studentCardList(filteredStudents);
                              },
                            ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  Widget studentCardList(List<Student> filteredStudents) {
    return ListView.builder(
        itemCount: filteredStudents.length,
        itemBuilder: (BuildContext context, int index) {
          final student = filteredStudents[index];
          return GestureDetector(
            onTap: () {
              context.pushNamed(AppRouter.studentProfile.name,
                  pathParameters: {'stId': student.stId});
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        '${student.firstName} ${student.lastName}',
                        style: dataTextStyle(c: darkblue),
                      ),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8.0, right: 5, left: 0),
                        child: Text('PROGRESS',
                            style: labelTextStyle(c: darkblue)),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 285,
                            height: 12,
                            child: ProgressBar(progress: student.progress),
                          ),
                          Text(
                              '%${(student.progress * 100).toStringAsFixed(0)}',
                              style: labelTextStyle(c: darkblue))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
