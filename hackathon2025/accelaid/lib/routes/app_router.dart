import 'package:accelaid/screens/add_student_screen.dart';
import 'package:accelaid/screens/dashboard.dart';
import 'package:accelaid/screens/generate_comp_exam_screen.dart';
import 'package:accelaid/screens/generate_exam_for_grade.dart';
import 'package:accelaid/screens/generate_practice_queations.dart';
import 'package:accelaid/screens/generate_progress_assessment.dart';
import 'package:accelaid/screens/generate_study_plan_screen.dart';
import 'package:accelaid/screens/generated_exam_screen.dart';
import 'package:accelaid/screens/generated_practice_questions.dart';
import 'package:accelaid/screens/grade_level_screen.dart';
import 'package:accelaid/screens/grade_student_screen.dart';
import 'package:accelaid/screens/grade_students_screen.dart';
import 'package:accelaid/screens/all_students_screen.dart';
import 'package:accelaid/screens/student_profile_screen.dart';
import 'package:accelaid/screens/student_progress.dart';
import 'package:accelaid/screens/student_study_plan_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/generated_progress_assessment_screen.dart';
import '../screens/login_screen.dart';
import '../screens/shell_screen.dart';

class AppRouter {
  static const login = (name: 'login', path: '/');
  static const dashboard = (name: 'dashboard', path: '/dashboard');
  static const gradelevels = (name: 'gradelevel', path: '/gradelevel');
  static const addStudent = (name: 'addstudent', path: '/addstudent');
  static const allStudents = (name: 'allStudents', path: '/allStudents');
  static const generateCompExam =
      (name: 'generateCompExam', path: '/generateCompExam');
  static const generateExamForGrade =
      (name: 'generateExamForGrade', path: '/generateExamForGrade/:grade');
  static const generatedExam =
      (name: 'generatedExam', path: '/generatedExam/:response');
  static const gradeStudents =
      (name: 'gradeStudent', path: '/gradeStudent/:grade');
  static const studentProgress =
      (name: 'studentProgress', path: '/studentProgress/:stId');
  static const studentProfile =
      (name: 'studentProfile', path: '/studentProfile/:stId');
  static const studentStudyPlan =
      (name: 'studentStudyPlan', path: '/studentStudyPlan/:stId/:studyPlan');
  static const generateStudyPlan =
      (name: 'generateStudyPlan', path: '/generateStudyPlan/:stId/:noOfWeeks');
  static const generateProgressAssessment = (
    name: 'generateProgressAssessment',
    path: '/generateProgressAssessment/:stId'
  );
  static const generatePracticeQuestions = (
    name: 'generatePracticeQuestions',
    path: '/generatePracticeQuestions/:stId'
  );
  static const generatedProgressAssessment = (
    name: 'generatedProgressAssessment',
    path: '/generatedProgressAssessment/:response'
  );
  static const generatedPracticeQuestions = (
    name: 'generatedPracticeQuestions',
    path: '/generatedPracticeQuestions/:response'
  );

  static final router = GoRouter(initialLocation: login.path, routes: [
    GoRoute(
        path: login.path,
        name: login.name,
        builder: (context, state) => const LoginScreen()),
    ShellRoute(
        builder: (context, state, child) => ShellScreen(body: child),
        routes: [
          GoRoute(
              path: dashboard.path,
              name: dashboard.name,
              builder: (context, state) => const DashBoardScreen()),
          GoRoute(
              path: allStudents.path,
              name: allStudents.name,
              builder: (context, state) => const AllStudentsScreen()),
          GoRoute(
              path: generateCompExam.path,
              name: generateCompExam.name,
              builder: (context, state) => const GenerateCompExamScreen()),
          GoRoute(
            path: gradelevels.path,
            name: gradelevels.name,
            builder: (context, state) => const GradeLevelScreen(),
          )
        ]),
    GoRoute(
        path: gradeStudents.path,
        name: gradeStudents.name,
        builder: (context, state) {
          final String grade = state.pathParameters['grade']!;
          return GradeStudentScreen(grade: grade);
        }),
    GoRoute(
        path: studentStudyPlan.path,
        name: studentStudyPlan.name,
        builder: (context, state) {
          final String stId = state.pathParameters['stId']!;
          final String studyPlan = state.pathParameters['studyPlan'] ?? '';
          return StudentStudyPlanScreen(
            stId: stId,
            studyPlan: studyPlan,
          );
        }),
    GoRoute(
      path: studentProfile.path,
      name: studentProfile.name,
      builder: (context, state) {
        final String stId = state.pathParameters['stId']!;
        return StudentProfileScreen(stId: stId);
      },
    ),
    GoRoute(
        path: generateStudyPlan.path,
        name: generateStudyPlan.name,
        builder: (context, state) {
          final String stId = state.pathParameters['stId']!;
          final String noOfWeeks = state.pathParameters['noOfWeeks']!;
          return GenerateStudyPlanScreen(stId: stId, noOfWeeks: noOfWeeks);
        }),
    GoRoute(
      path: addStudent.path,
      name: addStudent.name,
      builder: (context, state) => const AddStudentScreen(),
    ),
    GoRoute(
        path: generateExamForGrade.path,
        name: generateExamForGrade.name,
        builder: (context, state) {
          final String gr = state.pathParameters['grade']!;
          return GenerateExamForGrade(grade: gr);
        }),
    GoRoute(
        path: studentProgress.path,
        name: studentProgress.name,
        builder: (context, state) {
          final String stId = state.pathParameters['stId']!;
          return StudentProgressScreen(stId: stId);
        }),
    GoRoute(
        path: generateProgressAssessment.path,
        name: generateProgressAssessment.name,
        builder: (context, state) {
          final String stId = state.pathParameters['stId']!;
          return GenerateProgressAssessmentScreen(stId: stId);
        }),
    GoRoute(
        path: generatedExam.path,
        name: generatedExam.name,
        builder: (context, state) {
          final String res = state.pathParameters['response']!;
          return GeneratedExamScreen(response: res);
        }),
    GoRoute(
        path: generatePracticeQuestions.path,
        name: generatePracticeQuestions.name,
        builder: (context, state) {
          final String stId = state.pathParameters['stId']!;
          return GeneratePracticeQuestions(stId: stId);
        }),
    GoRoute(
        path: generatedProgressAssessment.path,
        name: generatedProgressAssessment.name,
        builder: (context, state) {
          final String res = state.pathParameters['response']!;
          return GeneratedProgressAssessmentScreen(response: res);
        }),
    GoRoute(
        //this
        path: generatedPracticeQuestions.path,
        name: generatedPracticeQuestions.name,
        builder: (context, state) {
          final String res = state.pathParameters['response']!;
          return GeneratedPracticeQuestionsScreen(response: res);
        }),
  ]);
}
