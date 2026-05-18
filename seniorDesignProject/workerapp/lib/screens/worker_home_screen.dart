import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/providers/alert_provider.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/sensor_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/alert.dart';

class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  int selectedMetricIndex = 0;
  String selectedTrendRange = 'Last 10 Readings';
  String selectedUsageRange = 'This Week';

  final List<String> metrics = [
    'Heart Rate',
    'Body Temp',
    'Humidity',
    'Environment Temp',
    // 'Breathing',
  ];

  List<Color> colors = [
    Color(0xFF0D21A1), // primary
    Color(0xFF1976D2), // blue
    Color(0xFF42A5F5), // light blue
    Color(0xFF26A69A), // teal
    Color(0xFF80CBC4), // soft teal
  ];

  Color hotColor = const Color(0xFFEF9A9A); // lighter soft red
  Color warmColor = const Color(0xFFFFCC80); // softer orange
  Color slightlyWarmColor = const Color(0xFFFFF176); // soft yellow (clearer)
  Color neutralColor = const Color(0xFF7FA8FF); // slightly lighter blue

  @override
  void initState() {
    super.initState();
    _setupFCM();
    initNotifications();
  }

  Future<void> _setupFCM() async {
    final userId = await ref
        .read(authNotifierProvider.notifier)
        .getCurrentUserId();
    if (userId == null) return;

    final userNotifier = ref.read(userNotifierProvider.notifier);
    await userNotifier.saveCurrentFcmToken(userId);
    await userNotifier.watchFcmTokenRefresh(userId);
  }

  Stream<Map<String, dynamic>?> latestPredictionStream(String workerId) {
    return ref
        .read(userNotifierProvider.notifier)
        .observeLatestPrediction(workerId);
  }

  Future<void> initNotifications() async {
    await ref.read(userNotifierProvider.notifier).initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(alertNotifierProvider);
    ref.watch(sensorNotifierProvider);
    ref.watch(userNotifierProvider);
    ref.watch(authNotifierProvider);
    final sensors = ref.watch(sensorNotifierProvider).value;
    if (sensors == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;

    if (authUser == null || users == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);
    final workerReadings = ref.watch(
      readingsForWorkerProvider(loggedInUser.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(loggedInUser.firstName, loggedInUser.lastName),
              const SizedBox(height: 18),

              _buildPredictionDonutCard(loggedInUser.id),
              const SizedBox(height: 18),

              workerReadings.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (readings) {
                  return Column(
                    children: [
                      _buildMetricTabs(),
                      const SizedBox(height: 14),
                      _buildLineChartCard(readings, sensors),
                      const SizedBox(height: 16),
                      _buildUsageBarChart(readings, sensors),
                      const SizedBox(height: 16),
                      _buildLatestReadingCards(readings, sensors),
                      const SizedBox(height: 18),
                      _buildAbnormalAlertsPieChart(loggedInUser.id),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 5, 17, 96), //const Color(0xFF0D21A1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Worker Dashboard",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome back, $firstName $lastName",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // const Icon(Icons.notifications_none_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildPredictionDonutCard(String userId) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: latestPredictionStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyCard("No prediction yet");
        }

        final data = snapshot.data!;
        final probs = Map<String, dynamic>.from(data['probabilities'] ?? {});
        final predictedLabel = (data['predictedLabel'] ?? 'Unknown').toString();

        double val(String key) => ((probs[key] ?? 0) as num).toDouble();

        //String fmt(String key) => "${val(key).toStringAsFixed(1)}%";
        String fmt(String key) => "${val(key).toStringAsFixed(2)}%";

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Heat Stress Prediction",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                predictedLabel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _predictionColor(predictedLabel),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 38,
                        sectionsSpace: 1,
                        sections: [
                          PieChartSectionData(
                            value: val('hot'),
                            color: hotColor,
                            title: '',
                            radius: 16,
                          ),
                          PieChartSectionData(
                            value: val('warm'),
                            color: warmColor,
                            title: '',
                            radius: 16,
                          ),
                          PieChartSectionData(
                            value: val('slightly warm'),
                            color: slightlyWarmColor,
                            title: '',
                            radius: 16,
                          ),
                          PieChartSectionData(
                            value: val('neutral'),
                            color: neutralColor,
                            title: '',
                            radius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _buildPredictionLegend("Hot", fmt('hot'), hotColor),
                        _buildPredictionLegend("Warm", fmt('warm'), warmColor),
                        _buildPredictionLegend(
                          "Slightly Warm",
                          fmt('slightly warm'),
                          slightlyWarmColor,
                        ),
                        _buildPredictionLegend(
                          "Neutral",
                          fmt('neutral'),
                          neutralColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPredictionLegend(String label, String value, Color color) {
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
            value,
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

  Color _predictionColor(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('hot'))
      return hotColor; // const Color.fromARGB(255, 240, 92, 81); // Colors.red;
    if (lower.contains('warm'))
      return warmColor; //const Color.fromARGB(255, 243, 175, 72); // Colors.orange;
    return neutralColor; // const Color.fromARGB(255, 84, 105, 243); //const Color(0xFF0D21A1);
  }

  Widget _buildMetricTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(metrics.length, (index) {
            final isSelected = selectedMetricIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMetricIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0D21A1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  metrics[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF011638),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLineChartCard(List<Reading> readings, List sensors) {
    final spots = _getTrendSpotsFromReadings(readings, sensors);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _getMetricTitle(),
                  style: const TextStyle(
                    fontSize: 16,
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
                  value: selectedTrendRange,
                  underline: const SizedBox(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  items: const [
                    DropdownMenuItem(
                      value: 'Last 10 Readings',
                      child: Text(
                        'Last 10 Readings',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last 30 Readings',
                      child: Text(
                        'Last 30 Readings',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last Hour: Latest 20',
                      child: Text(
                        'Last Hour: Latest 20',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Last Hour: Every 5 min',
                      child: Text(
                        'Last Hour: Every 5 min',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedTrendRange = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Latest readings trend",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      "No ${metrics[selectedMetricIndex]} readings for this range",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: _dynamicMinY(spots),
                      maxY: _dynamicMaxY(spots),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getInterval(),
                      ),
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
                            reservedSize: 34,
                            showTitles: true,
                            interval: _getInterval(),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(
                                  selectedMetricIndex == 1 ? 1 : 0,
                                ),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          color: const Color(0xFF0D21A1),
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF0D21A1).withOpacity(0.12),
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

  String getTypeFromSensor(String sensorId, List sensors) {
    try {
      final sensor = sensors.firstWhere((s) => s.id == sensorId);
      return sensor.type.toString().toLowerCase();
    } catch (_) {
      return "unknown";
    }
  }

  DateTime? _readingDate(dynamic time) {
    if (time == null) return null;

    if (time.runtimeType.toString() == 'Timestamp') {
      return time.toDate();
    }

    if (time is DateTime) return time;

    if (time is String) return DateTime.tryParse(time);

    return null;
  }

  List<String> _selectedSensorTypes() {
    switch (selectedMetricIndex) {
      case 0:
        return ["heart rate", "heartrate"];
      case 1:
        return ["body temperature", "body temp", "bodytemperature"];
      case 2:
        return ["humidity"];
      case 3:
        return ["temperature", "environment temp", "environment temperature"];
      default:
        return [];
    }
  }

  List<Reading> _filteredMetricReadings(List<Reading> readings, List sensors) {
    final now = DateTime.now();

    final filtered = readings.where((reading) {
      final type = getTypeFromSensor(reading.sensorId, sensors);
      final date = _readingDate(reading.time);

      final selectedTypes = _selectedSensorTypes();

      if (date == null) return false;

      final matchesType = selectedTypes.any((t) => type.contains(t));
      if (!matchesType) return false;

      if (selectedTrendRange.startsWith('Last Hour')) {
        return date.isAfter(now.subtract(const Duration(hours: 1)));
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final aDate = _readingDate(a.time) ?? DateTime(1900);
      final bDate = _readingDate(b.time) ?? DateTime(1900);
      return aDate.compareTo(bDate);
    });

    if (selectedTrendRange == 'Last 10 Readings' && filtered.length > 10) {
      return filtered.sublist(filtered.length - 10);
    }

    if (selectedTrendRange == 'Last 30 Readings' && filtered.length > 30) {
      return filtered.sublist(filtered.length - 30);
    }

    if (selectedTrendRange == 'Last Hour: Latest 20' && filtered.length > 20) {
      return filtered.sublist(filtered.length - 20);
    }

    if (selectedTrendRange == 'Last Hour: Every 5 min') {
      return _bucketReadingsEvery5Minutes(filtered);
    }

    return filtered;
  }

  List<Reading> _bucketReadingsEvery5Minutes(List<Reading> readings) {
    final buckets = <int, Reading>{};

    for (final reading in readings) {
      final date = _readingDate(reading.time);
      if (date == null) continue;

      final bucketKey = date.minute ~/ 5;
      buckets[bucketKey] = reading;
    }

    final bucketed = buckets.values.toList();

    bucketed.sort((a, b) {
      final aDate = _readingDate(a.time) ?? DateTime(1900);
      final bDate = _readingDate(b.time) ?? DateTime(1900);
      return aDate.compareTo(bDate);
    });

    return bucketed;
  }

  List<FlSpot> _getTrendSpotsFromReadings(
    List<Reading> readings,
    List sensors,
  ) {
    final filtered = _filteredMetricReadings(readings, sensors);

    return filtered.asMap().entries.map((entry) {
      final value = (entry.value.value as num).toDouble();
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  double _dynamicMinY(List<FlSpot> spots) {
    final min = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    return min - 5;
  }

  double _dynamicMaxY(List<FlSpot> spots) {
    final max = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return max + 5;
  }

  Widget _buildUsageBarChart(List<Reading> readings, List sensors) {
    final dailySeconds = _dailyArmUsageSeconds(readings, sensors);
    final dailyMinutes = dailySeconds.map(
      (day, seconds) => MapEntry(day, ((seconds / 60) * 10).round() / 10),
    );

    final hasUsage = dailyMinutes.values.any((value) => value > 0);

    final maxY = !hasUsage
        ? 10.0
        : dailyMinutes.values.reduce((a, b) => a > b ? a : b).toDouble() + 5;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Daily Arm Usage",
                  style: TextStyle(
                    fontSize: 16,
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
                  value: selectedUsageRange,
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
                    setState(() => selectedUsageRange = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Total left + right lifting duration per day",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 200,
            child: !hasUsage
                ? Center(
                    child: Text(
                      "No arm usage recorded for $selectedUsageRange",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
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
                            reservedSize: 38,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                "${value.toInt()}m",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = [
                                'M',
                                'T',
                                'W',
                                'T',
                                'F',
                                'S',
                                'S',
                              ];
                              final index = value.toInt();
                              if (index < 0 || index > 6)
                                return const SizedBox();
                              return Text(
                                labels[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
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
                      barGroups: List.generate(7, (index) {
                        return _barGroup(
                          index,
                          dailyMinutes[index]?.toDouble() ?? 0,
                          const Color(0xFF26A69A),
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<int, num> _dailyArmUsageSeconds(List<Reading> readings, List sensors) {
    final now = DateTime.now();

    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final selectedWeekStart = selectedUsageRange == 'Last Week'
        ? weekStart.subtract(const Duration(days: 7))
        : weekStart;

    final selectedWeekEnd = selectedWeekStart.add(const Duration(days: 6));

    final totals = <int, num>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (final reading in readings) {
      final type = getTypeFromSensor(reading.sensorId, sensors);
      final date = _readingDate(reading.time);

      if (date == null) continue;

      final isArmUsage = type == "right lifting" || type == "left lifting";

      if (!isArmUsage) continue;

      final dayDate = DateTime(date.year, date.month, date.day);

      if (dayDate.isBefore(selectedWeekStart)) continue;
      if (dayDate.isAfter(selectedWeekEnd)) continue;

      final dayIndex = dayDate.difference(selectedWeekStart).inDays;

      totals[dayIndex] = (totals[dayIndex] ?? 0) + (reading.value as num);
    }

    return totals;
  }

  Widget _buildLatestReadingCards(List<Reading> readings, List sensors) {
    Reading? latestReading(String sensorType) {
      final filtered = readings.where((reading) {
        final type = getTypeFromSensor(reading.sensorId, sensors);
        return type.contains(sensorType);
      }).toList();

      filtered.sort((a, b) {
        final aDate = _readingDate(a.time) ?? DateTime(1900);
        final bDate = _readingDate(b.time) ?? DateTime(1900);
        return bDate.compareTo(aDate);
      });

      return filtered.isEmpty ? null : filtered.first;
    }

    String latestValue(String sensorType, String unit) {
      final reading = latestReading(sensorType);
      if (reading == null) return "--";
      return "${reading.value}$unit";
    }

    final breathingReading = latestReading("breathing");
    final breathingLabel = breathingReading == null
        ? "Unknown"
        : breathingLabelFromCode(breathingReading.value as num);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniInfoCard(
                title: "Heart Rate",
                value: latestValue("heart rate", " bpm"),
                subtitle: "Latest reading",
                icon: Icons.favorite_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniInfoCard(
                title: "Body Temp",
                value: latestValue("body", "°C"),
                subtitle: "Latest reading",
                icon: Icons.thermostat_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniInfoCard(
                title: "Humidity",
                value: latestValue("humidity", "%"),
                subtitle: "Latest reading",
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniInfoCard(
                title: "Breathing",
                value: _shortBreathingLabel(breathingLabel),
                subtitle: breathingLabel,
                icon: Icons.air,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMiniInfoCard(
          title: "Environment Temp",
          value: latestValue("temperature", "°C"),
          subtitle: "Latest reading",
          icon: Icons.device_thermostat_outlined,
        ),
      ],
    );
  }

  Widget _buildAbnormalAlertsPieChart(String workerId) {
    final alertNotifier = ref.read(alertNotifierProvider.notifier);

    return StreamBuilder<List<Alert>>(
      stream: alertNotifier.getAlertsForWorker(workerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildEmptyCard("Loading alerts...");
        }

        if (snapshot.hasError) {
          return _buildEmptyCard("Could not load alerts");
        }

        final alerts = snapshot.data ?? [];

        final data = {'HR': 0.0, 'BT': 0.0, 'ET': 0.0, 'BR': 0.0, 'HS': 0.0};

        for (final alert in alerts) {
          final desc = alert.description.toLowerCase();

          if (desc.contains("heart")) {
            data['HR'] = data['HR']! + 1;
          } else if (desc.contains("body")) {
            data['BT'] = data['BT']! + 1;
          } else if (desc.contains("environment") ||
              desc.contains("temperature")) {
            data['ET'] = data['ET']! + 1;
          } else if (desc.contains("breathing")) {
            data['BR'] = data['BR']! + 1;
          } else if (desc.contains("heat")) {
            data['HS'] = data['HS']! + 1;
          }
        }

        final total = data.values.fold(0.0, (a, b) => a + b);

        if (total == 0) {
          return _buildEmptyCard("No abnormal alerts yet");
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Abnormal Alerts by Type",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF011638),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Summary of your abnormal alerts",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 38,
                        sectionsSpace: 3,
                        sections: [
                          _pieSection(data['HR']!, total, colors[0]),
                          _pieSection(data['BT']!, total, colors[1]),
                          _pieSection(data['ET']!, total, colors[2]),
                          _pieSection(data['BR']!, total, colors[3]),
                          _pieSection(data['HS']!, total, colors[4]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegend(
                          "Heart Rate",
                          data['HR']!,
                          total,
                          colors[0],
                        ),
                        _buildLegend(
                          "Body Temp",
                          data['BT']!,
                          total,
                          colors[1],
                        ),
                        _buildLegend(
                          "Environment Temp",
                          data['ET']!,
                          total,
                          colors[2],
                        ),
                        _buildLegend(
                          "Breathing",
                          data['BR']!,
                          total,
                          colors[3],
                        ),
                        _buildLegend(
                          "Heat Stress",
                          data['HS']!,
                          total,
                          colors[4],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  PieChartSectionData _pieSection(double value, double total, Color color) {
    final percentage = total == 0 ? 0 : (value / total) * 100;

    return PieChartSectionData(
      value: value,
      color: color,
      radius: 16,
      title: "", //${percentage.toStringAsFixed(0)}%",
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegend(String label, double value, double total, Color color) {
    final percentage = total == 0 ? 0 : (value / total) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            "${value.toInt()} (${percentage.toStringAsFixed(1)}%)",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 18,
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
      ],
    );
  }

  Widget _buildMiniInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF0D21A1).withOpacity(0.10),
            child: Icon(icon, color: const Color(0xFF0D21A1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF011638),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF011638),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  String _getMetricTitle() {
    switch (selectedMetricIndex) {
      case 0:
        return "Heart Rate Trend";
      case 1:
        return "Body Temperature Trend";
      case 2:
        return "Humidity Trend";
      case 3:
        return "Environmental Temperature Trend";
      // case 4:
      //   return "Breaths Per Minute Trend";
      default:
        return "Trend";
    }
  }

  double _getMinY() {
    switch (selectedMetricIndex) {
      case 0:
        return 60;
      case 1:
        return 35;
      case 2:
        return 40;
      case 3:
        return 20;
      // case 4:
      //   return 10;
      default:
        return 0;
    }
  }

  double _getMaxY() {
    switch (selectedMetricIndex) {
      case 0:
        return 110;
      case 1:
        return 39;
      case 2:
        return 80;
      case 3:
        return 40;
      // case 4:
      //   return 25;
      default:
        return 100;
    }
  }

  double _getInterval() {
    switch (selectedMetricIndex) {
      case 0:
        return 10;
      case 1:
        return 1;
      case 2:
        return 10;
      case 3:
        return 5;
      // case 4:
      //   return 5;
      default:
        return 10;
    }
  }

  List<FlSpot> _getSelectedSpots() {
    switch (selectedMetricIndex) {
      /// ❤️ Heart Rate (bpm)
      case 0:
        return const [
          FlSpot(0, 78),
          FlSpot(1, 82),
          FlSpot(2, 76),
          FlSpot(3, 88),
          FlSpot(4, 90),
          FlSpot(5, 85),
          FlSpot(6, 92),
          FlSpot(7, 87),
          FlSpot(8, 89),
          FlSpot(9, 84),
        ];

      /// 🌡 Body Temperature (°C)
      case 1:
        return const [
          FlSpot(0, 36.2),
          FlSpot(1, 36.4),
          FlSpot(2, 36.6),
          FlSpot(3, 36.5),
          FlSpot(4, 36.8),
          FlSpot(5, 37.1),
          FlSpot(6, 37.4),
          FlSpot(7, 37.0),
          FlSpot(8, 36.9),
          FlSpot(9, 36.7),
        ];

      /// 💧 Humidity (%)
      case 2:
        return const [
          FlSpot(0, 52),
          FlSpot(1, 55),
          FlSpot(2, 58),
          FlSpot(3, 57),
          FlSpot(4, 60),
          FlSpot(5, 63),
          FlSpot(6, 65),
          FlSpot(7, 62),
          FlSpot(8, 59),
          FlSpot(9, 57),
        ];

      /// 🌡 Environment Temp (°C)
      case 3:
        return const [
          FlSpot(0, 27),
          FlSpot(1, 28),
          FlSpot(2, 29),
          FlSpot(3, 31),
          FlSpot(4, 33),
          FlSpot(5, 34),
          FlSpot(6, 35),
          FlSpot(7, 33),
          FlSpot(8, 32),
          FlSpot(9, 31),
        ];

      // /// 🌬 Breathing Rate (bpm)
      // case 4:
      //   return const [
      //     FlSpot(0, 14),
      //     FlSpot(1, 15),
      //     FlSpot(2, 16),
      //     FlSpot(3, 17),
      //     FlSpot(4, 18),
      //     FlSpot(5, 19),
      //     FlSpot(6, 17),
      //     FlSpot(7, 16),
      //     FlSpot(8, 15),
      //     FlSpot(9, 17),
      //   ];

      default:
        return const [FlSpot(0, 0)];
    }
  }

  List<FlSpot> _getTrendSpots() {
    final base = _getSelectedSpots();

    if (selectedTrendRange == 'Last 30 Readings') {
      return [
        ...base,
        ...base.asMap().entries.map(
          (e) => FlSpot(e.key + base.length.toDouble(), e.value.y + 1),
        ),
        ...base.asMap().entries.map(
          (e) => FlSpot(e.key + (base.length * 2).toDouble(), e.value.y - 1),
        ),
      ];
    }

    if (selectedTrendRange == 'Last Hour') {
      return base
          .asMap()
          .entries
          .map((e) => FlSpot(e.key * 6, e.value.y))
          .toList();
    }

    return base;
  }

  String breathingLabelFromCode(num value) {
    switch (value.toInt()) {
      case 0:
        return "CALIBRATING";
      case 1:
        return "NORMAL";
      case 2:
        return "HIGH BREATHING";
      case 3:
        return "LOW BREATHING";
      case 4:
        return "IRREGULAR BREATHING";
      case 5:
        return "NO BREATHING";
      case 6:
        return "BAD FIT / MOTION";
      default:
        return "UNKNOWN";
    }
  }

  Color _breathingColor(String label) {
    switch (label) {
      case "LOW BREATHING":
        return const Color(0xFF26A69A); // teal

      case "HIGH BREATHING":
        return const Color(0xFF0D21A1); // primary blue

      case "NORMAL":
        return const Color(0xFF42A5F5); // light blue

      case "IRREGULAR BREATHING":
        return const Color(0xFF1976D2); // medium blue

      case "NO BREATHING":
        return const Color(0xFF011638); // dark navy (strong emphasis)

      case "BAD FIT / MOTION":
        return const Color(0xFF80CBC4); // soft teal

      case "CALIBRATING":
        return const Color(0xFFB2DFDB); // very light teal

      default:
        return const Color(0xFF90A4AE); // neutral grey-blue
    }
  }

  String _shortBreathingLabel(String label) {
    switch (label) {
      case "CALIBRATING":
        return "Calib.";
      case "NORMAL":
        return "Normal";
      case "HIGH BREATHING":
        return "High";
      case "LOW BREATHING":
        return "Low";
      case "IRREGULAR BREATHING":
        return "Irreg.";
      case "NO BREATHING":
        return "None";
      case "BAD FIT / MOTION":
        return "Bad Fit";
      default:
        return "Unknown";
    }
  }
}
