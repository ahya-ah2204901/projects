import 'package:accelaid/models/color_const.dart';
import 'package:accelaid/providers/title_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GeneratedExamScreen extends ConsumerStatefulWidget {
  final String response;
  const GeneratedExamScreen({required this.response, super.key});

  @override
  ConsumerState<GeneratedExamScreen> createState() =>
      _GeneratedExamScreenState();
}

class _GeneratedExamScreenState extends ConsumerState<GeneratedExamScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Generated Exam",
            style: TextStyle(
              fontSize: 21,
              color: darkblue,
              fontWeight: FontWeight.w700,
            )),
        leading: IconButton(
          onPressed: () {
            context.pop();
            context.pop();
            ref.read(titleNotifierProvider.notifier).setTitle('');
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: FilePageBody(
              widget.response,
              'Competency Exam',
              14,
              const Icon(
                Icons.text_snippet_outlined,
                color: Colors.blueAccent,
                size: 30,
              ),
              "competency_exam"),
        ),
      ),
    );
  }
}
