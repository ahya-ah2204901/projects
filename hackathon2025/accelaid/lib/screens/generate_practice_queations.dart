import 'package:accelaid/screens/widgets/discard_changes_dialog.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:numberpicker/numberpicker.dart';

import '../consts.dart';
import '../models/color_const.dart';
import '../models/competency_progress.dart';
import '../models/student.dart';
import '../providers/comp_and_topic_providers.dart';
import '../providers/comp_progress_provider.dart';
import '../providers/student_provider.dart';
import '../routes/app_router.dart';

class GeneratePracticeQuestions extends ConsumerStatefulWidget {
  final String stId;

  const GeneratePracticeQuestions({super.key, required this.stId});

  @override
  ConsumerState<GeneratePracticeQuestions> createState() =>
      _GeneratePracticeQuestionsState();
}

class _GeneratePracticeQuestionsState
    extends ConsumerState<GeneratePracticeQuestions> {
  final topicIdsSelected = [];
  final finalList = [];

  @override
  Widget build(BuildContext context) {
    Student? student =
        ref.read(studentNotifierProvider.notifier).getStudentById(widget.stId);
    final progressProvider = ref.watch(compProgressNotifierProvider);
    final progressNotifier = ref.read(compProgressNotifierProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DiscardChangesDialog(),
              );
            },
            icon: const Icon(CupertinoIcons.back),
          ),
          title: Text(
            "Generate Practice Questions",
            style: TextStyle(
              fontSize: 22,
              color: darkblue,
              fontWeight: FontWeight.w700,
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
                          final progress = progressList[index];
                          final topicsOfComp = ref.watch(
                            topicsByCompetencyProvider(progress.compId),
                          );

                          ValueNotifier<bool> isExpanded = ValueNotifier(false);

                          return ValueListenableBuilder<bool>(
                            valueListenable: isExpanded,
                            builder: (context, expanded, child) {
                              return ExpansionTile(
                                showTrailingIcon: false,
                                initiallyExpanded: true,
                                leading: Icon(
                                  expanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                                // trailing: Checkbox(
                                //   value: false,
                                //   // topicIdsSelected
                                //   //     .contains(progress.compId),
                                //   onChanged: (isSelected) {
                                //     print(
                                //         "Clicked. Exists: ${topicIdsSelected.contains(progress.compId)}");
                                //     setState(() {
                                //       // if (isSelected ?? false) {
                                //       //   competencyIdsSelected
                                //       //       .add(progress.compId);
                                //       // } else {
                                //       //   competencyIdsSelected
                                //       //       .remove(progress.compId);
                                //       // }
                                //     });
                                //     print(topicIdsSelected);
                                //   },
                                //   activeColor: Colors.grey,
                                //   side: const BorderSide(
                                //     color: Colors.grey,
                                //   ),
                                // ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final compByIdAsync = ref.watch(
                                              compByIdProvider(
                                                  progress.compId));

                                          return compByIdAsync.when(
                                            data: (competencyName) => Text(
                                              "${progress.compId.substring(2)} - $competencyName",
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
                                  topicsOfComp.when(
                                    data: (topics) {
                                      if (topics.isEmpty) {
                                        return const ListTile(
                                          title: Text("No topics available."),
                                        );
                                      }
                                      return Column(
                                        children: topics.map((topic) {
                                          return ListTile(
                                            title: Text(
                                              "${topic.topicId.substring(2)} - ${topic.topic}",
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            trailing: Checkbox(
                                              value: topicIdsSelected
                                                  .contains(topic.topicId),
                                              onChanged: (isSelected) {
                                                setState(() {
                                                  if (isSelected ?? false) {
                                                    topicIdsSelected
                                                        .add(topic.topicId);
                                                  } else {
                                                    topicIdsSelected
                                                        .remove(topic.topicId);
                                                  }
                                                });
                                              },
                                              activeColor: Colors.grey,
                                              side: const BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }).toList(),
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
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        int? numOfQuestions = await showDialog<int>(
                          context: context,
                          builder: (context) =>
                              _selectQuestionCountDialog(context),
                        );
                        if (numOfQuestions != null) {
                          finalList.clear();
                          for (String tId in topicIdsSelected) {
                            final topicAsync =
                                await ref.read(topicByIdProvider(tId).future);
                            finalList.add(topicAsync);
                          }
                          generateExamInParts(
                              finalList, student!.gradeLevel, numOfQuestions);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: darkblue,
                          elevation: 3,
                          fixedSize: const Size(340, 80),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        "Generate Practice Questions",
                        style: TextStyle(
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ));
  }

  Widget _selectQuestionCountDialog(BuildContext context) {
    int selectedValue = 2;

    return AlertDialog(
      title: const Text(
        "Please select the number of questions per topic.",
        textAlign: TextAlign.center,

      ),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumberPicker(
              value: selectedValue,
              minValue: 1,
              maxValue: 10,
              step: 1,
              axis: Axis.horizontal,
              itemHeight: 60,
              itemWidth: 60,
              selectedTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textStyle: const TextStyle(fontSize: 18, color: Colors.grey),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedValue),
          child: const Text("Confirm"),
        ),
      ],
    );
  }

  final openAI = OpenAI.instance.build(
    token: OPENAI_API_K,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 50)),
    enableLog: true,
  );

  Future<void> generateExamInParts(
      List<dynamic> topicsSelected, String grade, int numOfQuestions) async {
    List<String> fullExam = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (var topic in topicsSelected) {
        String prompt =
            "Generate $numOfQuestions questions the topic $topic for students in grade"
            " ${int.parse(grade) - 1}. "
            "Do not make any text bold. Do not tell me the correct answer."
            "Create $numOfQuestions (${numOfQuestions / 2} short answer, and ${numOfQuestions - (numOfQuestions / 2)} MCQ) question."
            "MCQs should have exactly 3 options (A, B, and C), only 1 being correct.";

        /// generating the request !
        final request = ChatCompleteText(
          messages: [
            {"role": "user", "content": prompt},
          ],
          model: ChatModelFromValue(
              model: 'gpt-4o-mini-2024-07-18'), // works best so far
          maxToken: 1000, // don't think any of the ones i've tested exceed that
          temperature: 0.2,
        );

        /// getting the response from api
        final response = await openAI.onChatCompletion(request: request);
        final strResponse =
            response?.choices.first.message?.content ?? "No response";

        final formattedResponse = strResponse.split('\n').map((line) {
          if (line.contains(r'\(') || line.contains(r'\)')) {
            return Math.tex(
              line.replaceAll(r'\(', '').replaceAll(r'\)', ''),
              textStyle: const TextStyle(fontSize: 16),
            ).toString();
          }
          return line;
        }).join('\n');
        fullExam.add("--> ${topic}\n\n$formattedResponse");
      }

      final completeExam = fullExam.join("\n\n\n");

      Navigator.pop(context);
      context.pushNamed(
        AppRouter.generatedPracticeQuestions.name,
        pathParameters: {'response': completeExam},
      );
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }
}
