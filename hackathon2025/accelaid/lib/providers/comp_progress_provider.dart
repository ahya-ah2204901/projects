import 'dart:async';
import 'package:accelaid/models/competency_progress.dart';
import 'package:accelaid/providers/repo_provider.dart';
import 'package:accelaid/repository/comp_progress_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompProgressProvider extends AsyncNotifier<List<CompetencyProgress>> {
  late final CompProgressRepo compProgressRepo;
  @override
  Future<List<CompetencyProgress>> build() async {
    compProgressRepo = await ref.watch(compProgressRepoProvider.future);

    compProgressRepo.observeProgress().listen((pr) {
      state = AsyncValue.data(pr);
    }).onError((e) {
      print('Error building progress provider: $e');
    });

    return [];
  }

  Future<List<CompetencyProgress>> fetchCompProgressByStudent(String stId) async {
    try {
      final progressList = await compProgressRepo.getCompProgressByStudent(stId);
      return progressList; // Return the fetched progress list
    } catch (error) {
      print("Error fetching competency progress: $error");
      rethrow; // Propagate the error
    }
  }

  // Add a new competency progress entry
  Future<void> addCompProgress(CompetencyProgress progress) async {
    try {
      await compProgressRepo.addCompProgress(progress);
      print("Competency progress added successfully: ${progress.compId}");
    } catch (error) {
      print("Error adding competency progress: $error");
      rethrow; // Propagate the error
    }
  }

  Future<void> updateCompProgress(CompetencyProgress progress) async {
    try {
      await compProgressRepo.updateCompProgress(progress);
      print("Competency progress updated successfully: ${progress.done}");
    } catch (error) {
      print("Error updating competency progress: $error");
      rethrow; // Propagate the error
    }
  }

}
final compProgressNotifierProvider =
AsyncNotifierProvider<CompProgressProvider, List<CompetencyProgress>>(
        () => CompProgressProvider());
