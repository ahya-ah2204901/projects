import 'package:accelaid/providers/repo_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/competency.dart';
import '../models/topic.dart';

/// grade --> COMPETENCIES
final competenciesByGradeProvider =
    FutureProvider.family<List<Competency>, String>((ref, grade) async {
  final compRepoAsync = await ref.watch(compRepoProvider.future);
  return await compRepoAsync.getCompetenciesByGrade(grade);
});

/// compId --> competency
final compByIdProvider =
    FutureProvider.family<String, String>((ref, compId) async {
  final compRepoAsync = await ref.watch(compRepoProvider.future);
  return await compRepoAsync.getCompById(compId);
});

/// compId --> COMPETENCY
final competencyObjByIdProvider =
    FutureProvider.family<Competency, String>((ref, compId) async {
  final compRepoAsync = await ref.watch(compRepoProvider.future);
  return await compRepoAsync.getCompetencyObjById(compId);
});

/// compId --> TOPICS
final topicsByCompetencyProvider =
    FutureProvider.family<List<Topic>, String>((ref, compId) async {
  final topicRepoAsync = await ref.watch(topicRepoProvider.future);
  return await topicRepoAsync.getTopicsByCompetency(compId);
});

/// topicId --> topic
final topicByIdProvider =
    FutureProvider.family<String, String>((ref, topicId) async {
  final compRepoAsync = await ref.watch(compRepoProvider.future);
  return await compRepoAsync.getTopicById(topicId);
});
