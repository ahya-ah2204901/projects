import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/providers/alert_provider.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/sensor_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/models/alert.dart';
import 'package:workerapp/models/reading.dart';

class SupervisorHomeScreen extends ConsumerStatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  ConsumerState<SupervisorHomeScreen> createState() =>
      _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends ConsumerState<SupervisorHomeScreen> {
  String selectedAlertsRange = 'Last 7 Days';
  String selectedArmUsageRange = 'This Week';
  final Color primaryBlue = const Color(0xFF0D21A1);
  final Color navy = const Color(0xFF011638);
  final Color mediumBlue = const Color(0xFF1976D2);
  final Color lightBlue = const Color(0xFF42A5F5);
  final Color teal = const Color(0xFF26A69A);
  final Color softTeal = const Color(0xFF80CBC4);
  final Color paleBlue = const Color(0xFF5C7CFA);
  final Color safeColor = const Color(0xFFA8D5BA); // soft green
  final Color cautionColor = const Color(0xFFFFDCA8); // soft orange
  final Color criticalColor = const Color(0xFFF3A6A6); // soft red

  @override
  void initState() {
    super.initState();
    _setupFCM();
    initNotifications();
  }

  Future<void> _setupFCM() async {
    final userId = await ref.read(authNotifierProvider.notifier).getCurrentUserId();
    if (userId == null) return;

    final userNotifier = ref.read(userNotifierProvider.notifier);
    await userNotifier.saveCurrentFcmToken(userId);
    await userNotifier.watchFcmTokenRefresh(userId);
  }

  Future<void> initNotifications() async {
    await ref.read(userNotifierProvider.notifier).initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(readingNotifierProvider);
    ref.watch(alertNotifierProvider);
    ref.watch(sensorNotifierProvider);
    ref.watch(userNotifierProvider);
    ref.watch(authNotifierProvider);

    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;

    if (authUser == null || users == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);
    final workers = users
        .where((u) => u.supervisorId == loggedInUser.id)
        .toList();

    final alertNotifier = ref.read(alertNotifierProvider.notifier);
    final sensors = ref.watch(sensorNotifierProvider).value;
    final supervisorReadings = ref.watch(
      readingsForSupervisorProvider(loggedInUser.id),
    );

    if (sensors == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(loggedInUser.firstName, loggedInUser.lastName),
              const SizedBox(height: 16),

              // _buildSummaryGrid(),
              // const SizedBox(height: 16),
              StreamBuilder<List<Alert>>(
                stream: alertNotifier.getAlertsForSupervisor(loggedInUser.id),
                builder: (context, alertSnapshot) {
                  if (alertSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (alertSnapshot.hasError) {
                    return Center(child: Text('Error: ${alertSnapshot.error}'));
                  }

                  final alerts = alertSnapshot.data ?? [];
                  return supervisorReadings.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                    data: (readings) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTeamStatusChart(workers, alerts),
                          const SizedBox(height: 16),
                          _buildAlertsTrendCard(alerts),
                          const SizedBox(height: 16),
                          _buildAlertsByTypeChart(alerts),
                          const SizedBox(height: 16),
                          _buildArmUsageByWorkerChart(
                            workers,
                            readings,
                            sensors,
                          ),
                          const SizedBox(height: 16),
                          _buildActiveAlertsCard(workers, alerts),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String firstName, String lastName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 5, 17, 96), //const Color(0xFF0D21A1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D21A1).withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white12,
            child: Icon(Icons.groups_2_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Supervisor Dashboard",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome back, $firstName $lastName",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Track recent alerts across your team",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total',
                value: '2',
                subtitle: 'Assigned workers',
                icon: Icons.groups_outlined,
                accent: const Color(0xFF0D21A1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryCard(
                title: 'Safe',
                value: '1',
                subtitle: 'No recent alerts',
                icon: Icons.shield_outlined,
                accent: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Caution',
                value: '0',
                subtitle: 'Recent warning alerts',
                icon: Icons.warning_amber_rounded,
                accent: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryCard(
                title: 'Critical',
                value: '1',
                subtitle: 'Recent critical alerts',
                icon: Icons.notification_important_outlined,
                accent: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamStatusChart(List workers, List<Alert> alerts) {
    int safe = 0;
    int caution = 0;
    int critical = 0;

    for (final worker in workers) {
      final workerAlerts = alerts
          .where((a) => a.workerId == worker.id)
          .toList();

      workerAlerts.sort((a, b) => b.time.compareTo(a.time));

      if (workerAlerts.isEmpty) {
        safe++;
        continue;
      }

      final latest = workerAlerts.first;
      final status = latest.status.toLowerCase();
      final severity = latest.severityLevel.toLowerCase();
      final unresolved = status == "new" || status == "acknowledged";

      if (!unresolved) {
        safe++;
      } else if (severity == "critical") {
        critical++;
      } else if (severity == "warning") {
        caution++;
      } else {
        caution++;
      }
    }

    final total = safe + caution + critical;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Team Status",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF011638),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Based on each worker's most recent alert",
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 42,
                        sectionsSpace: 3,
                        sections: [
                          PieChartSectionData(
                            value: safe.toDouble(),
                            color: safeColor,
                            title: '',
                            radius: 16,
                          ),
                          PieChartSectionData(
                            value: caution.toDouble(),
                            color: cautionColor,
                            title: '',
                            radius: 16,
                          ),
                          PieChartSectionData(
                            value: critical.toDouble(),
                            color: criticalColor,
                            title: '',
                            radius: 16,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$total",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF011638),
                          ),
                        ),
                        const Text(
                          "Workers",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _buildStatusLegend("Safe", safe, total, safeColor),
                    _buildStatusLegend("Caution", caution, total, cautionColor),
                    _buildStatusLegend(
                      "Critical",
                      critical,
                      total,
                      criticalColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(String label, int value, int total, Color color) {
    final percentage = total == 0 ? 0 : (value / total) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF011638)),
            ),
          ),
          Text(
            "$value (${percentage.toStringAsFixed(0)}%)",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF011638),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.07),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withOpacity(0.10),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityWorkerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Needs Attention Now",
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Kareem Ramadan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF011638),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Reason: Critical heart rate alert",
            style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 4),
          // const Text(
          //   "Use this card for the worker with the most urgent current alert. Prediction can be a secondary factor, not the main rule.",
          //   style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          // ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withOpacity(0.40)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View details', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertsCard(List workers, List<Alert> alerts) {
    String workerName(String workerId) {
      try {
        final worker = workers.firstWhere((w) => w.id == workerId);
        return "${worker.firstName} ${worker.lastName}";
      } catch (_) {
        return "Unknown Worker";
      }
    }

    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

    final activeAlerts = alerts.where((alert) {
      final status = alert.status.toLowerCase();
      final unresolved = status == "new" || status == "acknowledged";
      final recent = alert.time.isAfter(oneWeekAgo);

      return unresolved && recent;
    }).toList();

    activeAlerts.sort((a, b) => b.time.compareTo(a.time));

    final latest = activeAlerts.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Active Alerts",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF011638),
                  ),
                ),
              ),
              Text(
                "Latest unresolved",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0D21A1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (latest.isEmpty)
            const Text(
              "No active alerts",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            )
          else
            ...latest.map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SupervisorAlertTile(
                  worker: workerName(alert.workerId),
                  message: alert.description,
                  time: _timeAgo(alert.time),
                  severity: alert.severityLevel,
                ),
              );
            }),
        ],
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return "Now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  Widget _buildArmUsageByWorkerChart(
    List workers,
    List<Reading> readings,
    List sensors,
  ) {
    final data = _armUsageMinutesByWorker(workers, readings, sensors);
    final names = data.keys.toList();
    final values = data.values.toList();

    final hasUsage = values.any((v) => v > 0);
    final maxY = !hasUsage ? 10.0 : values.reduce((a, b) => a > b ? a : b) + 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Arm Usage by Worker",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF011638),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5EAF2)),
                ),
                child: DropdownButton<String>(
                  value: selectedArmUsageRange,
                  underline: const SizedBox(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  items: const [
                    DropdownMenuItem(
                      value: 'This Week',
                      child: Text('This Week', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'Last Week',
                      child: Text('Last Week', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedArmUsageRange = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Total left + right lifting usage in minutes",
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: !hasUsage
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "No arm usage recorded for $selectedArmUsageRange",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) => Text(
                              "${value.toInt()}m",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= names.length)
                                return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  names[index],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: List.generate(names.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: values[index],
                              width: 18,
                              borderRadius: BorderRadius.circular(8),
                              color: primaryBlue,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _armUsageMinutesByWorker(
    List workers,
    List<Reading> readings,
    List sensors,
  ) {
    final now = DateTime.now();
    final thisWeekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final selectedWeekStart = selectedArmUsageRange == 'Last Week'
        ? thisWeekStart.subtract(const Duration(days: 7))
        : thisWeekStart;

    final selectedWeekEnd = selectedWeekStart.add(const Duration(days: 6));

    final totals = <String, double>{};

    for (final worker in workers) {
      totals[worker.firstName] = 0;
    }

    for (final reading in readings) {
      final type = _getTypeFromSensor(reading.sensorId, sensors);
      final date = _readingDate(reading.time);

      if (date == null) continue;
      final isArmUsage =
          type.contains("right lifting") ||
          type.contains("left lifting") ||
          type.contains("right") && type.contains("lifting") ||
          type.contains("left") && type.contains("lifting");

      if (!isArmUsage) continue;

      final day = DateTime(date.year, date.month, date.day);

      if (day.isBefore(selectedWeekStart) || day.isAfter(selectedWeekEnd))
        continue;
      try {
        final sensor = sensors.firstWhere((s) => s.id == reading.sensorId);
        final worker = workers.firstWhere((w) => w.id == sensor.workerId);

        final name = worker.firstName;
        final seconds = (reading.value as num).toDouble();

        totals[name] = (totals[name] ?? 0) + (seconds / 60);
      } catch (_) {}
    }

    return totals.map((name, minutes) {
      return MapEntry(name, (minutes * 10).round() / 10);
    });
  }

  String _getTypeFromSensor(String sensorId, List sensors) {
    try {
      final sensor = sensors.firstWhere((s) => s.id == sensorId);
      return sensor.type.toString().toLowerCase();
    } catch (_) {
      return "unknown";
    }
  }

  DateTime? _readingDate(dynamic time) {
    if (time == null) return null;
    if (time.runtimeType.toString() == 'Timestamp') return time.toDate();
    if (time is DateTime) return time;
    if (time is String) return DateTime.tryParse(time);
    return null;
  }

  Widget _buildAlertsByTypeChart(List<Alert> alerts) {
    final data = {
      'Heart Rate': 0.0,
      'Body Temp': 0.0,
      'Temperature': 0.0,
      'Breathing': 0.0,
      'Heat Stress': 0.0,
    };

    for (final alert in alerts) {
      final desc = alert.description.toLowerCase();

      if (desc.contains("heart")) {
        data['Heart Rate'] = data['Heart Rate']! + 1;
      } else if (desc.contains("body")) {
        data['Body Temp'] = data['Body Temp']! + 1;
      } else if (desc.contains("environment") || desc.contains("temperature")) {
        data['Temperature'] = data['Temperature']! + 1;
      } else if (desc.contains("breathing")) {
        data['Breathing'] = data['Breathing']! + 1;
      } else if (desc.contains("heat")) {
        data['Heat Stress'] = data['Heat Stress']! + 1;
      }
    }

    final typeColors = {
      'Heart Rate': primaryBlue,
      'Body Temp': mediumBlue,
      'Temperature': lightBlue,
      'Breathing': teal,
      'Heat Stress': paleBlue,
    };

    final total = data.values.fold<double>(0, (sum, value) => sum + value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Alerts by Type",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF011638),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Breakdown of abnormal alerts across your team",
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 42,
                        sectionsSpace: 3,
                        sections: data.entries.map((entry) {
                          return _alertTypeSection(
                            entry.value,
                            typeColors[entry.key]!,
                          );
                        }).toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF011638),
                          ),
                        ),
                        const Text(
                          "Alerts",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: data.entries.map((entry) {
                    return _alertTypeLegend(
                      entry.key,
                      entry.value,
                      total,
                      typeColors[entry.key]!,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _alertTypeSection(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: '',
      radius: 16,
    );
  }

  Widget _alertTypeLegend(
    String label,
    double value,
    double total,
    Color color,
  ) {
    final percentage = total == 0 ? 0 : (value / total) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF011638)),
            ),
          ),
          Text(
            "${value.toInt()} (${percentage.toStringAsFixed(0)}%)",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF011638),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _alertTrendSpots(List<Alert> alerts) {
    final now = DateTime.now();

    if (selectedAlertsRange == 'Last 24 Hours') {
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
      ).subtract(const Duration(hours: 23));

      final counts = List<int>.filled(24, 0);

      for (final alert in alerts) {
        final t = alert.time;
        if (t.isBefore(start)) continue;

        final index = t.difference(start).inHours;
        if (index >= 0 && index < 24) counts[index]++;
      }

      return List.generate(
        24,
        (i) => FlSpot(i.toDouble(), counts[i].toDouble()),
      );
    }

    final days = selectedAlertsRange == 'Last 30 Days' ? 30 : 7;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    final counts = List<int>.filled(days, 0);

    for (final alert in alerts) {
      final day = DateTime(alert.time.year, alert.time.month, alert.time.day);
      if (day.isBefore(start)) continue;

      final index = day.difference(start).inDays;
      if (index >= 0 && index < days) counts[index]++;
    }

    return List.generate(
      days,
      (i) => FlSpot(i.toDouble(), counts[i].toDouble()),
    );
  }

  Widget _alertBottomTitle(double value) {
    final index = value.toInt();

    if (selectedAlertsRange == 'Last 24 Hours') {
      if (index % 4 != 0) return const SizedBox();
      return Text(
        "${index}h",
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
    }

    if (selectedAlertsRange == 'Last 30 Days') {
      if (index % 5 != 0) return const SizedBox();
      return Text(
        "D${index + 1}",
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
    }

    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    if (index < 0 || index >= labels.length) return const SizedBox();

    return Text(
      labels[index],
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  Widget _buildAlertsTrendCard(List<Alert> alerts) {
    final spots = _alertTrendSpots(alerts);
    final maxY = spots.isEmpty
        ? 5.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Alerts Over Time",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF011638),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5EAF2)),
                ),
                child: DropdownButton<String>(
                  value: selectedAlertsRange,
                  underline: const SizedBox(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  items: const [
                    DropdownMenuItem(
                      value: 'Last 24 Hours',
                      child: Text(
                        'Last 24 Hours',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last 7 Days',
                      child: Text(
                        'Last 7 Days',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last 30 Days',
                      child: Text(
                        'Last 30 Days',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedAlertsRange = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: spots.every((s) => s.y == 0)
                ? const Center(
                    child: Text(
                      "No alerts in this range",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: spots.length - 1,
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: selectedAlertsRange == 'Last 30 Days'
                                ? 5
                                : 1,
                            getTitlesWidget: (value, meta) =>
                                _alertBottomTitle(value),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          color: primaryBlue,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: primaryBlue.withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorAlertTile extends StatelessWidget {
  final String worker;
  final String message;
  final String time;
  final String severity;

  const _SupervisorAlertTile({
    required this.worker,
    required this.message,
    required this.time,
    required this.severity,
  });

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'caution':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData get severityIcon {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error_outline_rounded;
      case 'caution':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: severityColor.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: severityColor.withOpacity(0.10),
            child: Icon(severityIcon, color: severityColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF011638),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
