import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/routes/app_router.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts.dart';
import '../providers/comp_and_topic_providers.dart';

class GenerateExamForGrade extends ConsumerStatefulWidget {
  final String grade;

  const GenerateExamForGrade({required this.grade, super.key});

  @override
  ConsumerState<GenerateExamForGrade> createState() =>
      _GenerateExamForGradeState();
}

class _GenerateExamForGradeState extends ConsumerState<GenerateExamForGrade> {
  final openAI = OpenAI.instance.build(
    token: OPENAI_API_K,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 50)),
    enableLog: true,
  );

  Future<void> generateExamInParts(List<dynamic> competencies) async {
    List<String> fullExam = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (var competency in competencies) {
        final topicsProvider =
            ref.read(topicsByCompetencyProvider(competency.compId));
        final topics = topicsProvider.maybeWhen(
          data: (topics) => topics.map((t) => t.topic).toList(),
          orElse: () => [],
        );

        String prompt =
            "Generate a total of ${topics.length} multiple-choice questions for the competency "
            "'${competency.competency}' for students in grade ${widget.grade}. "
            "Each question should have exactly 3 options (A, B, and C), only 1 being correct. "
            "Do not make any text bold. Do not tell me the correct answer."
            "Create a question for each of these topics: ${topics.join(', ')}.";

        /// generate the request
        final request = ChatCompleteText(
          messages: [
            {"role": "user", "content": prompt},
          ],
          model: ChatModelFromValue(
              model: 'gpt-4o-mini-2024-07-18'), // works best so far
          maxToken: 1000, // don't think any of the ones i've tested exceed that
          temperature: 0.2,
        );

        /// get the response !
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
        fullExam.add("--> ${competency.competency}\n\n$formattedResponse");
      }

      final completeExam = fullExam.join("\n\n\n");

      Navigator.pop(context);
      context.pushNamed(
        AppRouter.generatedExam.name,
        pathParameters: {'response': completeExam},
      );
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final competenciesOfGrade =
        ref.watch(competenciesByGradeProvider(widget.grade));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Generate Exam for Grade ${widget.grade}",
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
                Text(
                  "There are ${competencies.length} competencies.",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Questions will be generated to assess all of the competencies.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // ExPandable list of competencies
                Expanded(
                  child: ListView.builder(
                    itemCount: competencies.length,
                    itemBuilder: (context, index) {
                      final competency = competencies[index];
                      final topicsOfComp = ref.watch(
                        topicsByCompetencyProvider(competency.compId),
                      );
                      return ExpansionTile(
                        title: Text(
                          "${competency.compId.substring(2)} - ${competency.competency}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
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
                                      style: const TextStyle(
                                        fontSize: 12,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      competenciesOfGrade.whenData((competencies) {
                        generateExamInParts(competencies);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkblue,
                        elevation: 3,
                        fixedSize: const Size(370, 80),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      "Generate Exam",
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
