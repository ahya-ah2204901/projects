import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';
import 'package:workerapp/providers/repo_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/repositories/reading_repo.dart';

class ReadingDetails {
  final Reading reading;
  final Sensor sensor;

  const ReadingDetails({required this.reading, required this.sensor});
}

class ReadingNotifier extends AsyncNotifier<List<Reading>> {
  late final ReadingRepo _readingRepo;

  @override
  Future<List<Reading>> build() async {
    _readingRepo = await ref.watch(readingRepoProvider.future);
    await _readingRepo.initializeReadings();
    _readingRepo
        .observeReadings()
        .listen((readings) {
          state = AsyncValue.data(readings);
        })
        .onError((e) {
          print('Error building reading provider: $e');
        });
    return [];
  }

  Stream<List<Reading>> observeReadings() {
    return _readingRepo.observeReadings();
  }

  Future<List<Reading>> addReadingFromJson(Map<String, dynamic> json) async {
    return await _readingRepo.addReadingFromJson(json);
  }

  Future<Reading> addReading(
    DateTime time,
    double value,
    String sensorId,
  ) async {
    return await _readingRepo.addReading(time, value, sensorId);
  }

  Stream<List<Reading>> getReadingsForWorker(String workerId) {
    final sensors = ref.read(sensorsForWorkerProvider(workerId)).value ?? [];
    final sensorIds = sensors.map((s) => s.id).toSet();
    return _readingRepo.observeReadingsForSensorIds(sensorIds);
    //return _alertRepo.getAlertsForWorker(id);
  }
}

final readingNotifierProvider =
    AsyncNotifierProvider<ReadingNotifier, List<Reading>>(
      () => ReadingNotifier(),
    );

final sensorsForWorkerProvider = StreamProvider.family<List<Sensor>, String>((
  ref,
  workerId,
) async* {
  final sensorRepo = await ref.watch(sensorRepoProvider.future);
  await sensorRepo.initializeSensors();
  yield* sensorRepo.observeSensorsForWorker(workerId);
});

final readingsForWorkerProvider = StreamProvider.family<List<Reading>, String>((
  ref,
  workerId,
) async* {
  final readingRepo = await ref.watch(readingRepoProvider.future);
  await readingRepo.initializeReadings();
  final sensors = await ref.watch(sensorsForWorkerProvider(workerId).future);
  final sensorIds = sensors.map((s) => s.id).toSet();

  yield* readingRepo.observeReadingsForSensorIds(sensorIds);
});

final readingsForSupervisorProvider =
    StreamProvider.family<List<Reading>, String>((ref, supervisorId) async* {
      final readingRepo = await ref.watch(readingRepoProvider.future);
      final sensorRepo = await ref.watch(sensorRepoProvider.future);
      await readingRepo.initializeReadings();
      await sensorRepo.initializeSensors();

      final users = await ref.watch(userNotifierProvider.future);
      final workerIds = users
          .where((user) => user.supervisorId == supervisorId)
          .map((user) => user.id)
          .toSet();

      if (workerIds.isEmpty) {
        yield <Reading>[];
        return;
      }

      final sensors = await sensorRepo.observeSensors().first;
      final sensorIds = sensors
          .where((sensor) => workerIds.contains(sensor.workerId))
          .map((sensor) => sensor.id)
          .toSet();

      yield* readingRepo.observeReadingsForSensorIds(sensorIds);
    });

final readingDetailsProvider = StreamProvider.family<ReadingDetails?, String>((
  ref,
  readingId,
) async* {
  final readingRepo = await ref.watch(readingRepoProvider.future);
  final sensorRepo = await ref.watch(sensorRepoProvider.future);
  await readingRepo.initializeReadings();
  await sensorRepo.initializeSensors();

  await for (final reading in readingRepo.observeReadingById(readingId)) {
    if (reading == null) {
      yield null;
      continue;
    }

    final sensor = await sensorRepo.getSensorById(reading.sensorId);
    yield ReadingDetails(reading: reading, sensor: sensor);
  }
});
