import 'package:accelaid/models/student.dart';
import 'package:accelaid/models/teacher.dart';
import 'package:accelaid/providers/repo_provider.dart';
import 'package:accelaid/providers/user_provider.dart';
import 'package:accelaid/repository/student_repo.dart';
import 'package:accelaid/repository/teacher_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherProvider extends AsyncNotifier<Teacher?> {
  @override
  Future<Teacher?> build() async {
    final User? teacher = ref.watch(userNotifierProvider);
    final teacherEmail = teacher?.email;
    if (teacherEmail == null) return null;
    return getTeacherById(teacherEmail);
  }

  Future<Teacher?> getTeacherById(String id) async {
    final teacherRepo = await ref.watch(teacherRepoProvider.future);
    return teacherRepo.getTeacherByEmail(id);
  }

  AsyncValue<Teacher?> getTeacher() {
    return state;
  }
}

// Provider definition
final teacherNotifierProvider =
    AsyncNotifierProvider<TeacherProvider, Teacher?>(() => TeacherProvider());

// Provider to hold the teacher ID
final teacherIdProvider = StateProvider<String?>((ref) => null);
