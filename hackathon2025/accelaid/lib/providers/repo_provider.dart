import 'package:accelaid/repository/comp_progress_repo.dart';
import 'package:accelaid/repository/comp_repo.dart';
import 'package:accelaid/repository/student_repo.dart';
import 'package:accelaid/repository/teacher_repo.dart';
import 'package:accelaid/repository/topic_repo.dart';
import 'package:accelaid/repository/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersRepoProvider = Provider<UserRepo>((ref) {
  var db = FirebaseFirestore.instance;
  var userRef = db.collection('users');
  return UserRepo(usersRef: userRef);
});

final studentRepoProvider = FutureProvider<StudentRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var studentRef = db.collection('students');
  return StudentRepo(studentRef: studentRef);
});

final teacherRepoProvider = FutureProvider<TeacherRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var teacherRef = db.collection('teachers');
  return TeacherRepo(teacherRef: teacherRef);
});

final compRepoProvider = FutureProvider<CompRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var compRef = db.collection('competencies');
  var topicRef = db.collection('topics');
  return CompRepo(compRef: compRef, topicRef: topicRef);
});

final topicRepoProvider = FutureProvider<TopicRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var topicRef = db.collection('topics');
  return TopicRepo(topicRef: topicRef);
});

final compProgressRepoProvider = FutureProvider<CompProgressRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var compProgressRef = db.collection('progress');
  return CompProgressRepo(compProgressRef: compProgressRef);
});
