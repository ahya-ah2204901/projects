import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/competency.dart';
import '../models/topic.dart';

class CompRepo {
  final CollectionReference compRef;
  final CollectionReference topicRef;

  CompRepo({required this.compRef, required this.topicRef}) {
    initializeCompetenciesAndTopics();
  }

  /// reads from competencies and topics from json file
  Future<void> initializeCompetenciesAndTopics() async {
    try {
      // check if competencies already exist
      final compSnapshot = await compRef.get();
      if (compSnapshot.docs.isNotEmpty) {
        print("Competencies already exist in Firestore.");
        return;
      }

      final String jsonString =
          await rootBundle.loadString('assets/data/competencies.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      for (var compData in jsonData) {
        final competency = Competency.fromMap(compData);
        final List<dynamic> topicsData = compData['topics'] ?? [];
        await compRef.doc(competency.compId).set(competency.toMap());

        for (var topicData in topicsData) {
          final topic = Topic.fromMap(topicData, competency.compId);
          await topicRef.doc(topic.topicId).set(topic.toMap());
        }
      }
      print("Competencies and topics successfully initialized in Firestore.");
    } catch (e) {
      print("Error initializing competencies and topics: $e");
    }
  }

  Future<List<Competency>> getCompetenciesByGrade(String grade) async {
    try {
      final querySnapshot =
          await compRef.where('gradeLevel', isEqualTo: grade).get();
      return querySnapshot.docs
          .map((doc) => Competency.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching competencies by grade: $e");
      return [];
    }
  }

  Future<String> getCompById(compId) async {
    final snapshot = await compRef.doc(compId).get();
    return Competency.fromMap(snapshot.data() as Map<String, dynamic>)
        .competency;
  }

  Future<Competency> getCompetencyObjById(String compId) async {
    try {
      final snapshot = await compRef.doc(compId).get();
      if (snapshot.exists) {
        return Competency.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception("Competency with ID $compId not found");
      }
    } catch (e) {
      throw Exception("Error fetching competency: $e");
    }
  }

  Future<String> getTopicById(topicId) async {
    final snapshot = await topicRef.doc(topicId).get();
    return Topic.fromMapWithId(snapshot.data() as Map<String, dynamic>).topic;
  }
}
