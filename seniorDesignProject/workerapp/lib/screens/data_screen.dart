import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/widgets/reading_tile.dart';

class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  String selectedType = "all";
  String selectedSort = "newest";
  String selectedRange = "all";
  String selectedSampling = "all";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count == 1) return "1 reading";
    return "$count readings";
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                "$label: ${entry.value}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }

  String getTypeFromSensor(String sensorId, List sensors) {
    try {
      final sensor = sensors.firstWhere((s) => s.id == sensorId);
      return sensor.type.toLowerCase();
    } catch (e) {
      return "unknown";
    }
  }

  List<Reading> applySampling(
    List<Reading> readings,
    DateTime? Function(dynamic time) getReadingDate,
    List sensors,
  ) {
    if (selectedSampling == "all") return readings;

    final minutes = selectedSampling == "5min"
        ? 5
        : selectedSampling == "15min"
        ? 15
        : 30;

    final buckets = <String, Reading>{};

    for (final reading in readings) {
      final date = getReadingDate(reading.time);
      if (date == null) continue;

      final type = getTypeFromSensor(reading.sensorId, sensors);

      final bucketMinute = (date.minute ~/ minutes) * minutes;

      final key =
          "${date.year}-${date.month}-${date.day}-${date.hour}-$bucketMinute-$type";

      buckets[key] = reading;
    }

    final sampled = buckets.values.toList();

    sampled.sort((a, b) {
      final aDate = getReadingDate(a.time) ?? DateTime(1900);
      final bDate = getReadingDate(b.time) ?? DateTime(1900);

      return selectedSort == "newest"
          ? bDate.compareTo(aDate)
          : aDate.compareTo(bDate);
    });

    return sampled;
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;
    final userId = fb.FirebaseAuth.instance.currentUser?.uid;

    if (authUser == null || users == null || userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);
    final sensorsProvider = ref.watch(
      sensorsForWorkerProvider(loggedInUser.id),
    );
    final readingsProvider = ref.watch(
      readingsForWorkerProvider(loggedInUser.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: sensorsProvider.when(
          data: (sensors) {
            return readingsProvider.when(
              data: (readingList) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE6EBF2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase().trim();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Search readings",
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF6B7280),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              label: "Type",
                              value: selectedType,
                              items: const {
                                "all": "All",
                                "heart rate": "Heart Rate",
                                "body temperature": "Body Temp",
                                "temperature": "Env Temp",
                                "humidity": "Humidity",
                                "breathing status": "Breathing",
                              },
                              onChanged: (value) {
                                setState(() => selectedType = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFilterDropdown(
                              label: "Range",
                              value: selectedRange,
                              items: const {
                                "all": "All",
                                "today": "Today",
                                "7days": "Last 7 days",
                                "30days": "Last month",
                              },
                              onChanged: (value) {
                                setState(() => selectedRange = value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              label: "Sort",
                              value: selectedSort,
                              items: const {
                                "newest": "Newest",
                                "oldest": "Oldest",
                              },
                              onChanged: (value) {
                                setState(() => selectedSort = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              label: "Sampling",
                              value: selectedSampling,
                              items: const {
                                "all": "All readings",
                                "5min": "Every 5 min",
                                "15min": "Every 15 min",
                                "30min": "Every 30 min",
                              },
                              onChanged: (value) {
                                setState(() => selectedSampling = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            DateTime? getReadingDate(dynamic time) {
                              if (time == null) return null;

                              // Firestore Timestamp
                              if (time.runtimeType.toString() == 'Timestamp') {
                                return time.toDate();
                              }

                              // DateTime
                              if (time is DateTime) {
                                return time;
                              }

                              // String time
                              if (time is String) {
                                return DateTime.tryParse(time);
                              }

                              return null;
                            }

                            final now = DateTime.now();

                            final filteredReadings = readingList.where((
                              reading,
                            ) {
                              final id = reading.id.toLowerCase();
                              final value = reading.value
                                  .toString()
                                  .toLowerCase();
                              final timeText = reading.time
                                  .toString()
                                  .toLowerCase();

                              final type = getTypeFromSensor(
                                reading.sensorId,
                                sensors,
                              );
                              final isLiftingReading =
                                  type.contains("left lifting") ||
                                  type.contains("right lifting") ||
                                  (type.contains("left") &&
                                      type.contains("lifting")) ||
                                  (type.contains("right") &&
                                      type.contains("lifting"));

                              if (isLiftingReading) return false;

                              final matchesSearch =
                                  searchQuery.isEmpty ||
                                  id.contains(searchQuery) ||
                                  value.contains(searchQuery) ||
                                  timeText.contains(searchQuery) ||
                                  type.contains(searchQuery);

                              final matchesType =
                                  selectedType == "all" || type == selectedType;

                              final readingDate = getReadingDate(reading.time);

                              bool matchesRange = true;

                              if (selectedRange != "all") {
                                if (readingDate == null) {
                                  matchesRange = false;
                                } else if (selectedRange == "today") {
                                  matchesRange =
                                      readingDate.year == now.year &&
                                      readingDate.month == now.month &&
                                      readingDate.day == now.day;
                                } else if (selectedRange == "7days") {
                                  matchesRange = readingDate.isAfter(
                                    now.subtract(const Duration(days: 7)),
                                  );
                                } else if (selectedRange == "30days") {
                                  matchesRange = readingDate.isAfter(
                                    now.subtract(const Duration(days: 30)),
                                  );
                                }
                              }

                              return matchesSearch &&
                                  matchesType &&
                                  matchesRange;
                            }).toList();

                            filteredReadings.sort((a, b) {
                              final aDate =
                                  getReadingDate(a.time) ?? DateTime(1900);
                              final bDate =
                                  getReadingDate(b.time) ?? DateTime(1900);

                              if (selectedSort == "newest") {
                                return bDate.compareTo(aDate);
                              } else {
                                return aDate.compareTo(bDate);
                              }
                            });
                            final displayedReadings = applySampling(
                              filteredReadings,
                              getReadingDate,
                              sensors,
                            );
                            if (displayedReadings.isEmpty) {
                              return _buildEmptyState();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatCount(
                                    displayedReadings.length,
                                  ), //_formatCount(filteredReadings.length),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    itemCount: displayedReadings
                                        .length, // itemCount: filteredReadings.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final reading =
                                          displayedReadings[index]; //final reading = filteredReadings[index];

                                      return ReadingTile(
                                        reading: reading,
                                        workerId: loggedInUser.id,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error: ${error.toString()}')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error: ${error.toString()}')),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6EBF2)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sensors_off_outlined,
              size: 42,
              color: Color(0xFF6B7280),
            ),
            SizedBox(height: 10),
            Text(
              "No readings found",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF011638),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try searching for another value or wait for new sensor data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
