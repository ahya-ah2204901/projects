import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/repositories/alert_repo.dart';
import 'package:workerapp/repositories/reading_repo.dart';
import 'package:workerapp/repositories/sensor_repo.dart';
import 'package:workerapp/repositories/user_repo.dart';

/// firebase -------------------------------------------------------------------

final userRepoProvider = FutureProvider<UserRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var userRef = db.collection('users');
  print('userRef initialized: $userRef');
  return UserRepo(userRef: userRef);
});

final sensorRepoProvider = FutureProvider<SensorRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var sensorRef = db.collection('sensors');
  print('sensorRef initialized: $sensorRef');
  return SensorRepo(sensorRef: sensorRef);
});

final readingRepoProvider = FutureProvider<ReadingRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var readingRef = db.collection('readings');
  print('readingRef initialized: $readingRef');
  return ReadingRepo(readingRef: readingRef);
});

final alertRepoProvider = FutureProvider<AlertRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var alertRef = db.collection('alerts');
  print('alertRef initialized: $alertRef');
  return AlertRepo(alertRef: alertRef);
});
