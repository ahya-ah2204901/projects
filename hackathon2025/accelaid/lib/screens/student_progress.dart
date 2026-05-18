import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/competency.dart';
import 'package:accelaid/models/competency_progress.dart';
import 'package:accelaid/models/student.dart';
import 'package:accelaid/providers/comp_and_topic_providers.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/topic_progress.dart';
import '../providers/comp_progress_provider.dart';

class StudentProgressScreen extends ConsumerStatefulWidget {
  final String stId;

  const StudentProgressScreen({super.key, required this.stId});

  @override
  ConsumerState<StudentProgressScreen> createState() => _StudentProgressState();
}

class _StudentProgressState extends ConsumerState<StudentProgressScreen> {
  @override
  Widget build(BuildContext context) {
    Student? student =
        ref.read(studentNotifierProvider.notifier).getStudentById(widget.stId);
    final progressNotifier = ref.read(compProgressNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Progress",
          style: TextStyle(
            fontSize: 23,
            color: darkblue,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<CompetencyProgress>>(
          future: progressNotifier.fetchCompProgressByStudent(widget.stId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No progress data."));
            } else {
              final progressList = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "COMPETENCIES FROM STUDENT'S PLAN",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: darkblue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: progressList.length,
                      itemBuilder: (context, index) {
                        final compProgress = progressList[index];
                        print(
                            "New: ${compProgress.topicProgress.map((t) => t.done)}");
                        // final topicsOfComp = ref.watch(
                        //   topicsByCompetencyProvider(progress.compId),
                        // );
                        final topicsProgressOfComp = compProgress.topicProgress;

                        ValueNotifier<bool> isExpanded = ValueNotifier(false);

                        return ValueListenableBuilder<bool>(
                          valueListenable: isExpanded,
                          builder: (context, expanded, child) {
                            return ExpansionTile(
                              initiallyExpanded: true,
                              leading: Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              trailing: Checkbox(
                                value: compProgress.done,
                                onChanged: (isSelected) {
                                  setState(() {
                                    if (isSelected ?? false) {
                                      compProgress.done = true;
                                      for (TopicProgress t
                                          in topicsProgressOfComp) {
                                        t.done = true;
                                      }
                                    } else {
                                      compProgress.done = false;
                                      for (TopicProgress t
                                          in topicsProgressOfComp) {
                                        t.done = false;
                                      }
                                    }
                                  });
                                  progressNotifier
                                      .updateCompProgress(compProgress);
                                  print("done updating");

                                  double newProgress = ref
                                      .read(
                                          compProgressNotifierProvider.notifier)
                                      .fetchCompProgressByStudent(student!.stId)
                                      .then((progressList) {
                                    if (progressList.isEmpty) {
                                      return 0.0;
                                    }
                                    int total = 0;
                                    for (CompetencyProgress p in progressList) {
                                      total = total + p.topicProgress.length;
                                    }
                                    int completed = 0;
                                    for (CompetencyProgress p in progressList) {
                                      for (var t in p.topicProgress) {
                                        t.done
                                            ? completed = completed + 1
                                            : completed = completed;
                                      }
                                    }
                                    return completed / total;
                                  }).then((newProgress) {
                                    student.progress = newProgress;

                                    ref
                                        .read(studentNotifierProvider.notifier)
                                        .updateStudent(student);
                                    print("Updated Progress: $newProgress");
                                  }).catchError((error) {
                                    print("Error calculating progress: $error");
                                  }) as double;
                                  student!.progress = newProgress;
                                  print(student.progress);
                                  ref
                                      .read(studentNotifierProvider.notifier)
                                      .updateStudent(student);
                                },
                                activeColor: Colors.teal,
                                side: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        final compByIdAsync = ref.watch(
                                            compByIdProvider(
                                                compProgress.compId));

                                        return compByIdAsync.when(
                                          data: (competencyName) => Text(
                                            "${compProgress.compId.substring(2)} - $competencyName",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          loading: () =>
                                              const CircularProgressIndicator(),
                                          error: (error, stackTrace) => Text(
                                            "Error: $error",
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              onExpansionChanged: (expandedState) {
                                isExpanded.value = expandedState;
                              },
                              children: [
                                if (topicsProgressOfComp.isEmpty)
                                  const ListTile(
                                    title: Text("No topics available."),
                                  )
                                else
                                  Column(
                                    children: topicsProgressOfComp
                                        .map((topicProgress) {
                                      final topicByIdAsync = ref.watch(
                                          topicByIdProvider(
                                              topicProgress.topicId));
                                      return topicByIdAsync.when(
                                        data: (topic) {
                                          return ListTile(
                                            title: Text(
                                              "${topicProgress.topicId.substring(2)} - $topic, ${topicProgress.done}",
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            trailing: Checkbox(
                                              value: topicProgress.done,
                                              onChanged: (isSelected) {
                                                setState(() {
                                                  if (isSelected ?? false) {
                                                    topicProgress.done = true;
                                                  } else {
                                                    topicProgress.done = false;
                                                  }
                                                });
                                                compProgress.updateDoneStatus();
                                                progressNotifier
                                                    .updateCompProgress(
                                                        compProgress);
                                                print("done updating");
                                                print(compProgress.topicProgress
                                                    .map((t) => t.done));

                                                // FIX LATER
                                                double newProgress = ref
                                                    .read(
                                                    compProgressNotifierProvider.notifier)
                                                    .fetchCompProgressByStudent(student!.stId)
                                                    .then((progressList) {
                                                  if (progressList.isEmpty) {
                                                    return 0.0;
                                                  }
                                                  int total = 0;
                                                  for (CompetencyProgress p in progressList) {
                                                    total = total + p.topicProgress.length;
                                                  }
                                                  int completed = 0;
                                                  for (CompetencyProgress p in progressList) {
                                                    for (var t in p.topicProgress) {
                                                      t.done
                                                          ? completed = completed + 1
                                                          : completed = completed;
                                                    }
                                                  }
                                                  return completed / total;
                                                }).then((newProgress) {
                                                  student.progress = newProgress;

                                                  ref
                                                      .read(studentNotifierProvider.notifier)
                                                      .updateStudent(student);
                                                  print("Updated Progress: $newProgress");
                                                }).catchError((error) {
                                                  print("Error calculating progress: $error");
                                                }) as double;
                                                student!.progress = newProgress;
                                                print(student.progress);
                                                ref
                                                    .read(studentNotifierProvider.notifier)
                                                    .updateStudent(student);
                                              },
                                              activeColor: Colors.green,
                                              side: const BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        },
                                        loading: () => const ListTile(
                                          title: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        error: (error, stackTrace) => ListTile(
                                          title: Text('Error: $error'),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// import 'package:accelaid/models/color_const.dart';
// import 'package:accelaid/models/competency.dart';
// import 'package:accelaid/models/competency_progress.dart';
// import 'package:accelaid/models/student.dart';
// import 'package:accelaid/providers/comp_and_topic_providers.dart';
// import 'package:accelaid/providers/student_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../providers/comp_progress_provider.dart';
//
// class StudentProgressScreen extends ConsumerStatefulWidget {
//   final String stId;
//
//   const StudentProgressScreen({super.key, required this.stId});
//
//   @override
//   ConsumerState<StudentProgressScreen> createState() => _StudentProgressState();
// }
//
// class _StudentProgressState extends ConsumerState<StudentProgressScreen> {
//   @override
//   Widget build(BuildContext context) {
//     Student? student =
//         ref.read(studentNotifierProvider.notifier).getStudentById(widget.stId);
//     final progressNotifier = ref.read(compProgressNotifierProvider.notifier);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Student Progress",
//           style: TextStyle(
//             fontSize: 23,
//             color: darkblue,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: FutureBuilder<List<CompetencyProgress>>(
//           future: progressNotifier.fetchCompProgressByStudent(widget.stId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text("Error: ${snapshot.error}"));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text("No progress data."));
//             } else {
//               final progressList = snapshot.data!;
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     "COMPETENCIES FROM STUDENT'S PLAN",
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w800,
//                       color: darkblue,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: progressList.length,
//                       itemBuilder: (context, index) {
//                         final progress = progressList[index];
//                         final topicsOfComp = ref.watch(
//                           topicsByCompetencyProvider(progress.compId),
//                         );
//
//                         ValueNotifier<bool> isExpanded = ValueNotifier(false);
//
//                         return ValueListenableBuilder<bool>(
//                           valueListenable: isExpanded,
//                           builder: (context, expanded, child) {
//                             return ExpansionTile(
//                               initiallyExpanded: true,
//                               leading: Icon(
//                                 expanded
//                                     ? Icons.keyboard_arrow_up
//                                     : Icons.keyboard_arrow_down,
//                                 color: Colors.grey,
//                               ),
//                               trailing: Checkbox(
//                                 value: progress.done,
//                                 onChanged: (isSelected) {
//                                   setState(() {
//                                     if (isSelected ?? false) {
//                                       progress.done = true;
//                                     } else {
//                                       progress.done = false;
//                                     }
//                                   });
//                                   progressNotifier.updateCompProgress(progress);
//                                   print("done updating");
//
//                                   double newProgress = ref
//                                       .read(
//                                           compProgressNotifierProvider.notifier)
//                                       .fetchCompProgressByStudent(student!.stId)
//                                       .then((progressList) {
//                                     if (progressList.isEmpty) {
//                                       return 0.0; // Handle empty progress case
//                                     }
//                                     final total = progressList.length;
//                                     final completed = progressList
//                                         .where((progress) => progress.done)
//                                         .length;
//
//                                     return completed / total;
//                                   }).then((newProgress) {
//                                     student!.progress = newProgress;
//
//                                     ref
//                                         .read(studentNotifierProvider.notifier)
//                                         .updateStudent(student);
//                                     print("Updated Progress: $newProgress");
//                                   }).catchError((error) {
//                                     print("Error calculating progress: $error");
//                                   }) as double;
//                                   student!.progress = newProgress;
//                                   print(student.progress);
//                                   ref
//                                       .read(studentNotifierProvider.notifier)
//                                       .updateStudent(student);
//                                 },
//                                 activeColor: Colors.green,
//                                 side: const BorderSide(
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               title: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Consumer(
//                                       builder: (context, ref, child) {
//                                         final compByIdAsync = ref.watch(
//                                             compByIdProvider(progress.compId));
//
//                                         return compByIdAsync.when(
//                                           data: (competencyName) => Text(
//                                             "${progress.compId.substring(2)} - $competencyName",
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           loading: () =>
//                                               const CircularProgressIndicator(),
//                                           error: (error, stackTrace) => Text(
//                                             "Error: $error",
//                                             style: const TextStyle(
//                                                 color: Colors.red),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               onExpansionChanged: (expandedState) {
//                                 isExpanded.value = expandedState;
//                               },
//                               children: [
//                                 topicsOfComp.when(
//                                   data: (topics) {
//                                     if (topics.isEmpty) {
//                                       return const ListTile(
//                                         title: Text("No topics available."),
//                                       );
//                                     }
//                                     return Column(
//                                       children: topics.map((topic) {
//                                         return ListTile(
//                                           title: Text(
//                                             "${topic.topicId.substring(2)} - ${topic.topic}",
//                                             style:
//                                                 const TextStyle(fontSize: 12),
//                                           ),
//                                         );
//                                       }).toList(),
//                                     );
//                                   },
//                                   loading: () => const ListTile(
//                                     title: Center(
//                                       child: CircularProgressIndicator(),
//                                     ),
//                                   ),
//                                   error: (error, stackTrace) => ListTile(
//                                     title: Text('Error: $error'),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
