import 'package:accelaid/models/student.dart';
import 'package:accelaid/models/teacher.dart';
import 'package:accelaid/providers/repo_provider.dart';
import 'package:accelaid/providers/teacher_provider.dart';
import 'package:accelaid/providers/user_provider.dart';
import 'package:accelaid/repository/student_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentProvider extends AsyncNotifier<List<Student>> {
  StudentRepo? studentRepo;
  Teacher? teacher;

  @override
  build() async {
    studentRepo ??= await ref.watch(studentRepoProvider.future);
    teacher = await ref.watch(teacherNotifierProvider.future);

    studentRepo!.observeStudents().listen((student) {
      state = AsyncValue.data(student);
    }).onError((e) {
      print('Error building students provider: $e');
    });

    return [];
  }

  /// Get a student by ID
  Student? getStudentById(String id) {
    return state.value?.firstWhere((s) => s.stId == id);
  }

  /// Add  a student
  Future<void> addStudent(Student student) async {
    await studentRepo!.addStudent(student);
  }

  /// update a student
  Future<void> updateStudent(Student student) async {
    await studentRepo!.updateStudent(student);
  }

  /// Delete a student
  Future<void> deleteStudent(Student student) async {
    await studentRepo!.deleteStudent(student);
  }

  /// Search students by first name or ID
  Stream<List<Student>> searchStudents(String grade, String q) {
    return studentRepo!.searchStudents(grade, teacher!.email ?? '', q);
  }

  /// Retrieve students of a teacher
  Stream<List<Student>> getAllStudentsByTeacher() {
    return studentRepo!.getAllStudentsByTeacher(teacher!.email ?? '');
  }

  /// Retrieve students in the same grade
  Stream<List<Student>> getGradeStudents(String grade) {
    return studentRepo!.getGradeStudents(grade, teacher!.email ?? '');
  }

  /// get # of students in a grade
  Stream<int> getStCountByGrade(String grade, String teacherEmail) {
    return studentRepo!.getStCountByGrade(grade, teacher!.email ?? '');
  }

  /// Get avg. progress of students in a grade taught by the same teacher
  Stream<double> getProgAvgByGrade(String grade, String teacherEmail) {
    return studentRepo!.getProgAvgByGrade(grade, teacher!.email ?? '');
  }

  /// Get avg. progress of students in all grades taught by the same teacher
  Stream<double> getProgAvg(String teacherEmail) {
    return studentRepo!.getProgAvg(teacher!.email ?? '');
  }

  /// get # of students
  Stream<int> getStCount(String teacherEmail) {
    return studentRepo!.getStCount(teacher!.email ?? '');
  }

  Stream<List<Student>> sortAscending(
      Stream<List<Student>> students, String category) {
    Stream<List<Student>> studentsOrdered =
        studentRepo!.sortAscending(students, category);

    return studentsOrdered;
  }

  Stream<List<Student>> sortDescending(
      Stream<List<Student>> students, String category) {
    Stream<List<Student>> studentsOrdered =
        studentRepo!.sortDescending(students, category);

    return studentsOrdered;
  }
}

final studentNotifierProvider =
    AsyncNotifierProvider<StudentProvider, List<Student>>(
        () => StudentProvider());
