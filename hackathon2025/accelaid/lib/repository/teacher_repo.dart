import 'package:accelaid/models/teacher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherRepo {
  final CollectionReference teacherRef;

  TeacherRepo({required this.teacherRef});

  /// Observe a single teacher by ID
  // Future<Teacher?> observeTeacherById(String id) {
  //   return teacherRef.doc(id).snapshots().map(
  //     (snapshot) => snapshot.exists ? Teacher.fromMap(snapshot.data() as Map<String, dynamic>) : null,
  //   );
  // }


  /// Get a student by ID
  Future<Teacher> getTeacherByEmail(String email) async {
    final snapshot = await teacherRef.doc(email).get();
    return Teacher.fromMap(snapshot.data() as Map<String, dynamic>);
  }
}
