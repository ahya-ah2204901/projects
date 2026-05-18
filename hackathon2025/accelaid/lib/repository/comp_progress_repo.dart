import 'package:accelaid/models/competency.dart';
import 'package:accelaid/models/competency_progress.dart';
import 'package:accelaid/models/study_plan_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompProgressRepo {
  final CollectionReference compProgressRef;

  CompProgressRepo({required this.compProgressRef});

  Stream<List<CompetencyProgress>> observeProgress() {
    return compProgressRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            CompetencyProgress.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<List<CompetencyProgress>> getCompProgressByStudent(String stId) async {
    try {
      final querySnapshot =
          await compProgressRef.where('stId', isEqualTo: stId).get();
      return querySnapshot.docs
          .map((doc) =>
              CompetencyProgress.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching competency progress for $stId: $e");
      return [];
    }
  }

  /// Add or update competency progress
  Future<void> addCompProgress(CompetencyProgress progress) async {
    try {
      // Use a composite key (stId + compId) as the document ID
      final docId = '${progress.stId}_${progress.compId}';
      await compProgressRef.doc(docId).set(progress.toMap());
    } catch (e) {
      print("Error adding competency progress: $e");
      rethrow;
    }
  }

  /// Update competency progress
  Future<void> updateCompProgress(CompetencyProgress progress) async {
    try {
      final docId = '${progress.stId}_${progress.compId}';
      final progressMap = progress.toMap();
      await compProgressRef.doc(docId).set(progressMap);
    } catch (e) {
      print("Error updating competency progress: $e");
      rethrow;
    }
  }
}