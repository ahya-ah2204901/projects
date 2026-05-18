import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:workerapp/models/alert.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';
import 'package:workerapp/models/user.dart';
//import 'package:yala_pay/models/cheque.dart';
//import 'package:yala_pay/repositories/image_repo.dart';

class AlertRepo {
  final CollectionReference alertRef;

  AlertRepo({required this.alertRef});

  /// reads from cheque json file
  Future<void> initializeAlerts() async {
    if (alertRef == null) {
      print('Error: alertRef is null');
      return;
    }

    final snapshot = await alertRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/alerts.json');
        var alertJsonList = jsonDecode(data);
        for (var alertMap in alertJsonList) {
          Alert alert = Alert.fromMap(alertMap);
          //String? uri = await uploadImageFromAssets(cheque.chequeImageUri);
          //final docRef = alertRef.doc(cheque.chequeNo.toString());
          final newAlert = Alert(
            id: alert.id,
            workerId: alert.workerId,
            readingId: alert.readingId,
            time: alert.time,
            severityLevel: alert.severityLevel,
            description: alert.description,
            status: alert.status,
          );
          await alertRef.doc(alert.id.toString()).set(newAlert.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing alert: $e');
      }
    }
  }

  Stream<List<Alert>> observeAlerts({bool descending = true}) {
    return alertRef
        .orderBy('time', descending: descending)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Alert.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<void> addAlert(
    Reading reading,
    Sensor sensor,
    String description,
  ) async {
    // String time = dtime.toString();
    final docId = alertRef.doc().id;
    final newAlert = Alert(
      id: docId,
      workerId: sensor.workerId,
      readingId: reading.id,
      time: reading.time,
      severityLevel: 'HIGH',
      description: description,
      status: 'PENDING',
    );
    await alertRef.doc(docId).set(newAlert.toMap());
  }

  Future<void> updateAlertStatus(String alertId, String newStatus) async {
    await alertRef.doc(alertId).update({'status': newStatus});
  }

  Future<void> checkReadingToAlert(Reading reading, Sensor sensor) async {
    if (reading.sensorId == sensor.id) {
      if (sensor.type.toLowerCase() == "heart rate") {
        if (reading.value > 130) {
          addAlert(
            reading,
            sensor,
            "Heart Rate is too high (${reading.value} bpm).",
          );
        }
      } else if (sensor.type.toLowerCase() == "body temperature") {
        if (reading.value > 37.8) {
          addAlert(
            reading,
            sensor,
            "Body temperature is too high (${reading.value} C).",
          );
        }
      } else if (sensor.type.toLowerCase() == "temperature") {
        if (reading.value > 31.5) {
          addAlert(
            reading,
            sensor,
            "Temperature is too high (${reading.value} C).",
          );
        }
      }
    }
  }

  Stream<List<Alert>> getAlertsForWorker(String id) {
    return observeAlerts().map((allAlerts) {
      return allAlerts.where((u) => u.workerId == id).toList();
    });
  }
}
