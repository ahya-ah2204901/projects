import 'dart:math';

import 'package:accelaid/providers/student_provider.dart';
import 'package:accelaid/providers/title_provider.dart';
import 'package:accelaid/providers/user_provider.dart';
import 'package:accelaid/screens/widgets/discard_changes_dialog.dart';
import 'package:accelaid/screens/widgets/student_text_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/color_const.dart';
import '../models/student.dart';
import '../routes/app_router.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  bool _showErrors = false;

  final stIdController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();

  String? lastCompletedGradeLevelController;
  String? gradeLevelController;

  final gradeLevels = ["1", "2", "3", "4", "5", "6"];
  final tempCountries = [
    "Syria",
    "Turkey",
    "Iraq",
    "Jordan",
    "Lebanon",
    "Saudi Arabia",
    "Iran",
    "Other"
  ];

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  Future<void> _initializeStudentData() async {
    Student student = Student(
        stId: "",
        firstName: "",
        lastName: "",
        dob: DateTime.now(),
        hasStudyPlan: false,
        teacherEmail: "",
        lastCompletedGradeLevel: "",
        gradeLevel: "",
        progress: 0.0,
        studyPlan: "unavailablePlan");

    setState(() {
      stIdController.text = student.stId;
      firstNameController.text = student.firstName;
      lastNameController.text = student.lastName;
      dobController.text = "";
    });
    lastCompletedGradeLevelController = student.lastCompletedGradeLevel;
    gradeLevelController = student.gradeLevel;
  }

  @override
  void initState() {
    super.initState();
    _initializeStudentData();
  }

  @override
  Widget build(BuildContext context) {
    final stNotifier = ref.read(studentNotifierProvider.notifier);
    final userProvider = ref.watch(userNotifierProvider);

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
        title: const Text("Register New Student"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      StudentTextFormField(
                        controller: stIdController,
                        label: "Student ID",
                        autoValidate: _showErrors,
                        validator: (value) => value!.isEmpty
                            ? "Student ID cannot be empty"
                            : null,
                      ),
                      StudentTextFormField(
                        controller: firstNameController,
                        label: "First Name",
                        autoValidate: _showErrors,
                        validator: (value) => value!.isEmpty
                            ? "First Name cannot be empty"
                            : null,
                      ),
                      StudentTextFormField(
                        controller: lastNameController,
                        label: "Last Name",
                        autoValidate: _showErrors,
                        validator: (value) =>
                            value!.isEmpty ? "Last Name cannot be empty" : null,
                      ),
                      const Text("Date of Birth"),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: "(YYYY-MM-DD)",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.edit),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: null, // ??????
                            firstDate: DateTime(DateTime.now().year - 15),
                            lastDate: DateTime(DateTime.now().year - 5),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dobController.text =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "DoB cannot be empty";
                          } else if (DateTime.tryParse(value) == null) {
                            return "Invalid Date";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Last Completed Grade Level",
                          border: OutlineInputBorder(),
                        ),
                        value: lastCompletedGradeLevelController == ''
                            ? null
                            : lastCompletedGradeLevelController,
                        items: gradeLevels
                            .map((g) => DropdownMenuItem<String>(
                                value: g, child: Text(g)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            lastCompletedGradeLevelController = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Please Select a Grade Level"
                            : null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "New Grade Level",
                          border: OutlineInputBorder(),
                        ),
                        value: gradeLevelController == ''
                            ? null
                            : gradeLevelController,
                        items: gradeLevels
                            .map((g) => DropdownMenuItem<String>(
                                value: g, child: Text(g)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            gradeLevelController = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Please Select a Grade Level"
                            : null,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: darkblue,
                      elevation: 3,
                      fixedSize: const Size(145, 30),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    _validateForm();
                    if (_isValidForm) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("Confirm Changes"),
                                content: const Text(
                                    "Do you want to confirm the changes or continue editing?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: const Text("Continue Editing")),
                                  TextButton(
                                      onPressed: () {
                                        Student st = Student(
                                            stId: stIdController.text,
                                            firstName: firstNameController.text,
                                            lastName: lastNameController.text,
                                            dob: DateTime.parse(
                                                dobController.text),
                                            hasStudyPlan: false,
                                            progress: 0,
                                            teacherEmail: userProvider?.email ??
                                                "invalid teacher",
                                            gradeLevel: gradeLevelController!,
                                            lastCompletedGradeLevel:
                                                lastCompletedGradeLevelController!,
                                            studyPlan: "unavailablePlan");
                                        stNotifier.addStudent(st);
                                        context.pop();
                                        ref
                                            .read(
                                                titleNotifierProvider.notifier)
                                            .setTitle(
                                                'Grade $gradeLevelController Students');
                                        context.goNamed(
                                            AppRouter.gradeStudents.name,
                                            pathParameters: {
                                              'grade': st.gradeLevel
                                            });
                                      },
                                      child: const Text("Confirm"))
                                ],
                              ));
                    }
                  },
                  child: const Text(
                    "Add Student",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
