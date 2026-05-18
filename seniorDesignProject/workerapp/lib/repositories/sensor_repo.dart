import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';

class SensorRepo {
  final CollectionReference sensorRef;

  SensorRepo({required this.sensorRef});

  Future<void> initializeSensors() async {
    final snapshot = await sensorRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/sensors.json');
        var sensorJsonList = jsonDecode(data);

        String readingData = await rootBundle.loadString(
          'assets/data/readings.json',
        );

        for (var sensorMap in sensorJsonList) {
          final docId = sensorRef.doc().id;
          Sensor sensor = Sensor.fromMap(sensorMap);

          final newSensor = Sensor(
            id: sensor.id,
            type: sensor.type,
            workerId: sensor.workerId,
          );
          await sensorRef.doc(sensor.id.toString()).set(newSensor.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing Sensors: $e');
      }
    }
  }

  Stream<List<Sensor>> observeSensors() {
    return sensorRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Sensor.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  Stream<List<Sensor>> observeSensorsForWorker(String workerId) {
    return sensorRef
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Sensor.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  //returns sensor object
  Future<Sensor> getSensorById(String sensorId) async {
    final snapshot = await sensorRef.get();
    final sensors = snapshot.docs.map((doc) {
      return Sensor.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    //Sensor sensor =
    return sensors.firstWhere(
      (s) => s.id == sensorId,
      orElse: () {
        throw Exception('Sensor not found');
      },
    );
    //return sensor.workerId;
  }

  Future<List<Sensor>> getSensorByWorkerId(String workerId) async {
    final snapshot = await sensorRef.get();
    final sensors = snapshot.docs.map((doc) {
      return Sensor.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return sensors.where((s) => s.workerId == workerId).toList();
    //return sensor.workerId;
  }
}
