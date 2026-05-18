import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';
//import 'package:yala_pay/models/cheque.dart';
//import 'package:yala_pay/repositories/image_repo.dart';

class ReadingRepo {
  final CollectionReference readingRef;

  // final ImageRepository _imageRepo = ImageRepository();

  ReadingRepo({required this.readingRef});

  /// reads from cheque json file
  Future<void> initializeReadings() async {
    if (readingRef == null) {
      print('Error: readingRef is null');
      return;
    }

    final snapshot = await readingRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/readings.json');
        var readingJsonList = jsonDecode(data);
        for (var readingMap in readingJsonList) {
          Reading reading = Reading.fromMap(readingMap);
          //String? uri = await uploadImageFromAssets(cheque.chequeImageUri);
          //final docRef = readingRef.doc(cheque.chequeNo.toString());
          final newReading = Reading(
            id: reading.id,
            time: reading.time,
            value: reading.value,
            sensorId: reading.sensorId,
          );
          await readingRef.doc(reading.id.toString()).set(newReading.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing reading: $e');
      }
    }
  }

  Stream<List<Reading>> observeReadings({bool descending = true}) {
    return readingRef
        .orderBy('time', descending: descending)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reading.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Stream<Reading?> observeReadingById(String readingId) {
    return readingRef.doc(readingId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Reading.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Stream<List<Reading>> observeReadingsForSensorIds(
    Set<String> sensorIds, {
    bool descending = true,
  }) {
    if (sensorIds.isEmpty) return Stream.value([]);

    return observeReadings(descending: descending).map((readings) {
      return readings.where((r) => sensorIds.contains(r.sensorId)).toList();
    });
  }

  Future<Reading> addReading(
    DateTime dtime,
    double value,
    String sensorId,
  ) async {
    String time = dtime.toString();
    final docId = readingRef.doc().id;
    final newReading = Reading(
      id: docId,
      time: DateTime.tryParse(time) ?? DateTime.now(),
      value: value,
      sensorId: sensorId,
    );
    print("WRITING READING: ${newReading.toMap()}");

    await readingRef.doc(docId).set(newReading.toMap());
    print("WRITE COMPLETE");
    return newReading;
  }

  Future<List<Reading>> addReadingFromJson(Map<String, dynamic> json) async {
    //final docId = readingRef.doc().id;
    SensorData sd = SensorData.fromMap(json);
    DateTime dtime = DateTime.now();
    String stime = dtime.toString();
    List<Reading> readings = [];
    Reading r1 = await addReading(dtime, sd.temperature, "s009");
    readings.add(r1);
    Reading r2 = await addReading(dtime, sd.humidity, "s010");
    readings.add(r2);
    Reading r3 = await addReading(dtime, sd.bodyTemp, "s011");
    readings.add(r3);
    Reading r4 = await addReading(dtime, sd.heartRate, "s012");
    readings.add(r4);

    return readings;
  }
}
