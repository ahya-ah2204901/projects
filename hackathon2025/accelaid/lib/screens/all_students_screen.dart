import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/student.dart';
import 'package:accelaid/providers/grade_student_search_provider.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:accelaid/screens/widgets/progress_bar.dart';
import 'package:accelaid/screens/widgets/sort_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AllStudentsScreen extends ConsumerStatefulWidget {
  const AllStudentsScreen({super.key});

  @override
  ConsumerState<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends ConsumerState<AllStudentsScreen> {
  String _selectedCategory = 'grade';
  bool isAscending = true;
  @override
  Widget build(BuildContext context) {
    final studentProvider = ref.watch(studentNotifierProvider);
    final studentNotifier = ref.read(studentNotifierProvider.notifier);
    final searchProvider = ref.watch(gradeStudentSearchNotifierProvider);
    final searchNotifier =
        ref.read(gradeStudentSearchNotifierProvider.notifier);

    Stream<List<Student>> getStreamBasedOnSort(bool isSearchEmpty) {
      if (isSearchEmpty && isAscending) {
        var list = studentNotifier.getAllStudentsByTeacher();
        return studentNotifier.sortAscending(list, _selectedCategory);
      } else if (isSearchEmpty && !(isAscending)) {
        var list = studentNotifier.getAllStudentsByTeacher();
        return studentNotifier.sortDescending(list, _selectedCategory);
      } else if (!(isSearchEmpty) && isAscending) {
        var list = studentNotifier.searchStudents('0', searchProvider);
        return studentNotifier.sortAscending(list, _selectedCategory);
      } else if (!(isSearchEmpty) && !(isAscending)) {
        var list = studentNotifier.searchStudents('0', searchProvider);
        return studentNotifier.sortDescending(list, _selectedCategory);
      }
      return studentNotifier.getAllStudentsByTeacher();
    }

    return studentProvider.when(
        data: ((students) {
          final isSearchEmpty = searchProvider.isEmpty;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 9.0),
                        child: Container(
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
                                    color: Colors.grey,
                                    fontSize: 15,
                                    height: 2)),
                            onChanged: (query) {
                              searchNotifier.setSearch(query);
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      color: grey,
                      onPressed: () async {
                        List<String> categories = ['Grade', 'Progress', 'Name'];
                        String? selectedCategory = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SortDialog(
                              categories: categories,
                              selectedCategory: _selectedCategory,
                            );
                          },
                        );

                        if (selectedCategory != null) {
                          setState(() {
                            _selectedCategory = selectedCategory;
                          });
                        }
                      },
                    ),
                    isAscending
                        ? Tooltip(
                            message: 'Set to descending',
                            child: IconButton(
                                icon: const Icon(Icons.arrow_upward_rounded),
                                color: grey,
                                onPressed: () {
                                  setState(() {
                                    isAscending = false;
                                  });
                                  //sort it to be descending
                                }),
                          )
                        : Tooltip(
                            message: 'Set to ascending',
                            child: IconButton(
                                icon: const Icon(Icons.arrow_downward_rounded),
                                color: grey,
                                onPressed: () {
                                  setState(() {
                                    if (isSearchEmpty) {
                                    } else {}
                                    isAscending = true;
                                  });
                                }),
                          )
                  ],
                ),
                Expanded(
                    child: //(isSearchEmpty)
                        StreamBuilder<List<Student>>(
                  stream: getStreamBasedOnSort(
                      isSearchEmpty), //studentNotifier.getAllStudentsByTeacher(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final filteredStudents = snapshot.data ?? [];
                    return studentCardList(filteredStudents);
                  },
                )),
              ],
            ),
          );
        }),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')));
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
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text("GRADE  ${student.gradeLevel}",
                            style: labelTextStyle(c: lightblue, f: 16)),
                      ),
                      Text('PROGRESS', style: labelTextStyle(c: darkblue)),
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
