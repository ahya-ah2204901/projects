import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';
import 'package:workerapp/providers/alert_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/repo_provider.dart';
import 'package:workerapp/repositories/sensor_repo.dart';

class SensorNotifier extends AsyncNotifier<List<Sensor>> {
  late final SensorRepo _sensorRepo;

  Timer? _timer;

  @override
  Future<List<Sensor>> build() async {
    _sensorRepo = await ref.watch(sensorRepoProvider.future);
    await _sensorRepo.initializeSensors();

    final sensorsStream = _sensorRepo.observeSensors();

    final firstValue = await sensorsStream.first;
    sensorsStream.listen((sensors) {
      state = AsyncValue.data(sensors);
    });

    return firstValue;
  }

  Stream<List<Sensor>> observeSensors() {
    return _sensorRepo.observeSensors();
  }

  Future<Sensor> getSensorById(String sensorId) async {
    return _sensorRepo.getSensorById(sensorId);
  }

  Future<List<Sensor>> getSensorByWorkerId(String workerId) async {
    return _sensorRepo.getSensorByWorkerId(workerId);
  }

  Stream<List<Sensor>> getSensorsForWorker(String workerId) {
    return observeSensors().map((allSensors) {
      return allSensors.where((s) => s.workerId == workerId).toList();
    });
  }

  String? getSensorType(String sensorId, List<Sensor> sensors) {
    try {
      Sensor sensor = sensors.firstWhere((s) => s.id == sensorId);
      return sensor.type;
    } catch (_) {
      return null;
    }
  }
}

final sensorNotifierProvider =
    AsyncNotifierProvider<SensorNotifier, List<Sensor>>(() => SensorNotifier());
