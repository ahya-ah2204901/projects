import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/models/competency.dart';
import 'package:accelaid/models/competency_progress.dart';
import 'package:accelaid/models/student.dart';
import 'package:accelaid/models/topic_progress.dart';
import 'package:accelaid/providers/comp_and_topic_providers.dart';
import 'package:accelaid/providers/comp_progress_provider.dart';
import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:accelaid/screens/widgets/discard_changes_dialog.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts.dart';
import '../models/topic.dart';

class GenerateStudyPlanScreen extends ConsumerStatefulWidget {
  final String stId;
  final String noOfWeeks;
  const GenerateStudyPlanScreen(
      {super.key, required this.stId, required this.noOfWeeks});

  @override
  ConsumerState<GenerateStudyPlanScreen> createState() =>
      _GenerateStudyPlanScreenState();
}

class _GenerateStudyPlanScreenState
    extends ConsumerState<GenerateStudyPlanScreen> {
  final Set<Competency> selectedCompetencies = {};

  final openAI = OpenAI.instance.build(
    token: OPENAI_API_K,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 50)),
    enableLog: true,
  );

  Future<void> generatePlan(List<Competency> competencies) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<String> allTopics = [];
      for (var competency in competencies) {
        final topicsProvider =
            ref.read(topicsByCompetencyProvider(competency.compId));
        final topics = topicsProvider.maybeWhen(
          data: (topics) => topics.map((t) => t.topic).toList(),
          orElse: () => [],
        );
        allTopics.addAll(topics as Iterable<String>);
      }

      allTopics = allTopics.toSet().toList();

      Student? student = ref
          .read(studentNotifierProvider.notifier)
          .getStudentById(widget.stId);
      final studentNotifier = ref.read(studentNotifierProvider.notifier);
      final compProgressNotifier =
          ref.read(compProgressNotifierProvider.notifier);

      String prompt =
          "Create a study plan for a grade ${student?.gradeLevel} student. "
          "They will study 1 hour daily to catch up on missed topics from grade ${int.parse(student!.gradeLevel) - 1}. "
          "The topics are: ${allTopics.join(', ')}. "
          "Make the plan span ${widget.noOfWeeks} weeks and allocate time based on topic difficulty."
          "Give some detail (e.g. intro to the topic, practice questions, etc)."
          "Return your response in the format of:"
          "Week 1: "
          "- topic xyz: intro, practice, etc"
          "- ..."
          "Week 2:"
          "- topic xyz: intro, practice, etc"
          "- ..."
          "Do not add any extra text or explanation to your response."
          "Make the 'week x' bold, and be not too brief by stating an intro to "
          "the topic, or practice questions on it, etc";

      final request = ChatCompleteText(
        messages: [
          {"role": "user", "content": prompt},
        ],
        model: ChatModelFromValue(model: 'gpt-4o-mini-2024-07-18'),
        maxToken: 16384,
        temperature: 0.2,
      );

      final response = await openAI.onChatCompletion(request: request);
      final strResponse =
          response?.choices.first.message?.content ?? "No response";

      print("Generated Study Plan: $strResponse");
      print("DOne");

      context.pop();
      print("Popped");
      student.studyPlan = strResponse;
      student.hasStudyPlan = true;
      studentNotifier.updateStudent(student);
      for (Competency comp in competencies) {
        final topicsProvider =
            ref.read(topicsByCompetencyProvider(comp.compId));
        List<TopicProgress> topicsProgress = [];
        final topicIds = topicsProvider.maybeWhen(
          data: (topics) => topics.map((t) => t.topicId).toList(),
          orElse: () => [],
        );
        for (String t in topicIds) {
          topicsProgress.add(TopicProgress(topicId: t, done: false));
        }
        compProgressNotifier.addCompProgress(CompetencyProgress(
            stId: student.stId,
            compId: comp.compId,
            done: false,
            topicProgress: topicsProgress));
      }

      context.pop();
      context.pop();

    } catch (error) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Student? student =
        ref.read(studentNotifierProvider.notifier).getStudentById(widget.stId);
    final prevGrade = (int.parse(student!.gradeLevel) - 1).toString();
    final competenciesOfGrade =
        ref.watch(competenciesByGradeProvider(prevGrade));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => const DiscardChangesDialog());
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: Text(
          "Generate Study Plan",
          style: TextStyle(
            fontSize: 23,
            color: darkblue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: competenciesOfGrade.when(
          data: (competencies) {
            if (competencies.isEmpty) {
              return const Center(child: Text("No competencies found."));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Grade Competencies for the Plan.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: competencies.length,
                    itemBuilder: (context, index) {
                      final competency = competencies[index];
                      final topicsOfComp = ref.watch(
                        topicsByCompetencyProvider(competency.compId),
                      );
                      return ExpansionTile(
                        title: Row(
                          children: [
                            Checkbox(
                              value: selectedCompetencies.contains(competency),
                              onChanged: (isSelected) {
                                setState(() {
                                  if (isSelected ?? false) {
                                    selectedCompetencies.add(competency);
                                  } else {
                                    selectedCompetencies.remove(competency);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                "${competency.compId.substring(2)} - ${competency.competency}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                      style: const TextStyle(fontSize: 12),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      generatePlan(selectedCompetencies.toList());
                      print("Selected Competencies: $selectedCompetencies");
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkblue,
                        elevation: 3,
                        fixedSize: const Size(380, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      "Generate Study Plan",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text("Error: $error")),
        ),
      ),
    );
  }
}
