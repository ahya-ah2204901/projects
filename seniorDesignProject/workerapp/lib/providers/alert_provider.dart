import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/models/alert.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';
import 'package:workerapp/models/user.dart' as app_user;
import 'package:workerapp/providers/repo_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/repositories/alert_repo.dart';

class AlertNotifier extends AsyncNotifier<List<Alert>> {
  late final AlertRepo _alertRepo;

  @override
  Future<List<Alert>> build() async {
    _alertRepo = await ref.watch(alertRepoProvider.future);
    await _alertRepo.initializeAlerts();
    _alertRepo
        .observeAlerts()
        .listen((alerts) {
          state = AsyncValue.data(alerts);
        })
        .onError((e) {
          print('Error building alert provider: $e');
        });
    return [];
  }

  Stream<List<Alert>> observeAlerts() {
    return _alertRepo.observeAlerts();
  }

  Future<void> checkReadingToAlert(Reading reading, Sensor sensor) async {
    return _alertRepo.checkReadingToAlert(reading, sensor);
  }

  Future<void> updateAlertStatus(String alertId, String newStatus) async {
    return _alertRepo.updateAlertStatus(alertId, newStatus);
  }

  Stream<List<Alert>> getAlertsForWorker(String id) {
    return _alertRepo.getAlertsForWorker(id);
  }

  Stream<List<Alert>> getAlertsForSupervisor(String supervisorId) {
    return observeAlerts().map((allAlerts) {
      final allUsers = ref.read(userNotifierProvider).value ?? [];

      final workerIds = allUsers
          .where((u) => u.supervisorId == supervisorId)
          .map((u) => u.id)
          .toSet();

      return allAlerts.where((a) => workerIds.contains(a.workerId)).toList();
    });
  }

  Stream<List<Alert>> getFilteredAlertsForUser({
    required app_user.User user,
    String searchQuery = '',
    String selectedStatus = 'all',
    String selectedSeverity = 'all',
  }) {
    final userAlerts = user.role.toLowerCase() == 'supervisor'
        ? getAlertsForSupervisor(user.id)
        : getAlertsForWorker(user.id);

    return userAlerts.map((alerts) {
      final normalizedSearch = searchQuery.toLowerCase().trim();

      final filteredAlerts = alerts.where((alert) {
        final description = alert.description.toLowerCase();
        final severity = alert.severityLevel.toLowerCase();
        final id = alert.id.toLowerCase();
        final status = alert.status.toLowerCase();

        final matchesSearch =
            normalizedSearch.isEmpty ||
            description.contains(normalizedSearch) ||
            severity.contains(normalizedSearch) ||
            id.contains(normalizedSearch) ||
            status.contains(normalizedSearch);

        final matchesStatus =
            selectedStatus == 'all' || status == selectedStatus;

        final matchesSeverity =
            selectedSeverity == 'all' || severity == selectedSeverity;

        return matchesSearch && matchesStatus && matchesSeverity;
      }).toList();

      filteredAlerts.sort((a, b) => b.time.compareTo(a.time));
      return filteredAlerts;
    });
  }
}

final alertNotifierProvider = AsyncNotifierProvider<AlertNotifier, List<Alert>>(
  () => AlertNotifier(),
);
