import 'package:accelaid/models/color_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneratedPracticeQuestionsScreen extends StatelessWidget {
  final String response;

  const GeneratedPracticeQuestionsScreen({required this.response, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generated Pratice Questions",
            style: TextStyle(
              fontSize: 21,
              color: darkblue,
              fontWeight: FontWeight.w700,
            )),
        leading: IconButton(
          onPressed: () {
            context.pop();
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: FilePageBody(
              response,
              'Practice Question',
              14,
              const Icon(
                Icons.text_snippet_outlined,
                color: Colors.blueAccent,
                size: 30,
              ),
              "practice_questions"),
        ),
      ),
    );
  }
}
