import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/sensor_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/widgets/reading_tile.dart';
import 'package:collection/collection.dart';

class WorkerReadingsScreen extends ConsumerStatefulWidget {
  final String workerId;
  const WorkerReadingsScreen({super.key, required this.workerId});

  @override
  ConsumerState<WorkerReadingsScreen> createState() =>
      _WorkerReadingsScreenState();
}

class _WorkerReadingsScreenState extends ConsumerState<WorkerReadingsScreen> {
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
    } catch (_) {
      return "unknown";
    }
  }

  DateTime? getReadingDate(dynamic time) {
    if (time == null) return null;
    if (time.runtimeType.toString() == 'Timestamp') return time.toDate();
    if (time is DateTime) return time;
    if (time is String) return DateTime.tryParse(time);
    return null;
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

  Widget _buildDetailColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Stream<Map<String, dynamic>?> latestPredictionStream(String workerId) {
    return ref
        .read(userNotifierProvider.notifier)
        .observeLatestPrediction(workerId);
  }

  Color _predictionColor(String label) {
    final lower = label.toLowerCase();

    if (lower.contains('hot')) return Colors.red;
    if (lower.contains('warm')) return Colors.orange;

    return const Color(0xFF0D21A1);
  }

  @override
  Widget build(BuildContext context) {
    final sensors = ref.watch(sensorNotifierProvider).value;

    if (sensors == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userId = fb.FirebaseAuth.instance.currentUser?.uid;
    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider);
    final userData = users.value;

    if (authUser == null || userData == null || userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final worker = userData.firstWhere((u) => u.id == widget.workerId);
    final workerReadings = ref.watch(readingsForWorkerProvider(widget.workerId));

    if (userData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    //final loggedInUser = users.firstWhere((u) => u.id == authUser!.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(
          255,
          8,
          21,
          65,
        ), //const Color(0xFF0D21A1),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "Worker Readings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: workerReadings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (readingList) {
          final now = DateTime.now();

          final filteredReadings = readingList.where((reading) {
            final id = reading.id.toLowerCase();
            final value = reading.value.toString().toLowerCase();
            final timeText = reading.time.toString().toLowerCase();
            final type = getTypeFromSensor(reading.sensorId, sensors);

            final isLiftingReading =
                type.contains("left lifting") ||
                type.contains("right lifting") ||
                (type.contains("left") && type.contains("lifting")) ||
                (type.contains("right") && type.contains("lifting"));

            if (isLiftingReading) return false;

            final matchesSearch =
                searchQuery.isEmpty ||
                id.contains(searchQuery) ||
                value.contains(searchQuery) ||
                timeText.contains(searchQuery) ||
                type.contains(searchQuery);

            final matchesType = selectedType == "all" || type == selectedType;

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

            return matchesSearch && matchesType && matchesRange;
          }).toList();

          filteredReadings.sort((a, b) {
            final aDate = getReadingDate(a.time) ?? DateTime(1900);
            final bDate = getReadingDate(b.time) ?? DateTime(1900);

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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkerHeader(
                  fullName: "${worker.firstName} ${worker.lastName}",
                  email: worker.email,
                  role: worker.role,
                  workerId: widget.workerId,
                  readingCount: readingList.length,
                ),
                const SizedBox(height: 18),

                const Text(
                  "Latest Readings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF011638),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Search and filter this worker's sensor readings",
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 14),

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
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
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
                          // "left lifting": "Left Lifting",
                          //"right lifting": "Right Lifting",
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

                _buildFilterDropdown(
                  label: "Sort",
                  value: selectedSort,
                  items: const {"newest": "Newest", "oldest": "Oldest"},
                  onChanged: (value) {
                    setState(() => selectedSort = value);
                  },
                ),

                const SizedBox(height: 16),
                _buildFilterDropdown(
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

                const SizedBox(height: 16),

                if (displayedReadings.isEmpty) //if (filteredReadings.isEmpty)
                  _buildEmptyState()
                else ...[
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedReadings
                        .length, //itemCount: filteredReadings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ReadingTile(
                        reading:
                            displayedReadings[index], //reading: filteredReadings[index],
                        workerId: widget.workerId,
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkerHeader({
    required String fullName,
    required String email,
    required String role,
    required String workerId,
    required int readingCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFE8EEF9),
            child: Icon(
              Icons.person_outline,
              color: Color(0xFF0D21A1),
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF011638),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 16),

          StreamBuilder<Map<String, dynamic>?>(
            stream: latestPredictionStream(workerId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return _buildInfoChip(
                  label: "Heat Prediction",
                  value: "No prediction yet",
                  icon: Icons.local_fire_department_outlined,
                  fullWidth: true,
                );
              }

              final data = snapshot.data!;
              final prediction = (data['predictedLabel'] ?? 'Unknown')
                  .toString();
              final probs = Map<String, dynamic>.from(
                data['probabilities'] ?? {},
              );

              double predictionPercent = 0;

              if (probs.isNotEmpty) {
                final key = prediction.toLowerCase();
                predictionPercent = ((probs[key] ?? 0) as num).toDouble();
              }

              final color = _predictionColor(prediction);

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_outlined,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Heat Prediction",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Text(
                      "$prediction ${predictionPercent.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  label: "Role",
                  value: role,
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoChip(
                  label: "Readings",
                  value: readingCount.toString(),
                  icon: Icons.monitor_heart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoChip(
            label: "Worker ID",
            value: workerId,
            icon: Icons.tag_outlined,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required IconData icon,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0D21A1)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF011638),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.sensors_off_outlined, size: 42, color: Color(0xFF6B7280)),
          SizedBox(height: 10),
          Text(
            "No readings found",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF011638),
            ),
          ),
          SizedBox(height: 4),
          Text(
            "This worker does not have any readings yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             context.pop();
//           },
//           icon: const Icon(CupertinoIcons.back),
//           color: Colors.white,
//         ),
//         title: const Text(
//           "Worker Readings",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color.fromARGB(255, 8, 21, 65),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   const Icon(CupertinoIcons.money_dollar, size: 70),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Worker Id: ${widget.workerId}",
//                     style: const TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             const Text(
//               "Worker Info",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildDetailColumn("Worker Id", widget.workerId),
//                       _buildDetailColumn("First Name", worker.firstName),
//                       _buildDetailColumn("Last Name", worker.lastName),
//                       _buildDetailColumn("Role", worker.role),

//                       _buildDetailColumn("Email", worker.email),
//                       // _buildDetailColumn(
//                       //   "Supervisor Email",
//                       //   ,
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "Worker Readings",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),

//             SizedBox(
//               width: double.infinity,
//               child: readingProvider.when(
//                 data: ((readings) {
//                   return StreamBuilder<List<Reading>>(
//                     stream: readingNotifier.getReadingsForWorker(
//                       widget.workerId,
//                     ),
//                     builder: (context, snapshot) {
//                       print('connectionState: ${snapshot.connectionState}');
//                       print('hasError: ${snapshot.hasError}');
//                       print('error: ${snapshot.error}');
//                       print('hasData: ${snapshot.hasData}');
//                       print('data length: ${snapshot.data?.length}');
//                       print('workerId being passed: ${widget.workerId}');

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }

//                       final readingList = snapshot.data ?? [];

//                       if (readingList.isEmpty) {
//                         return const Center(child: Text('No readings found'));
//                       }

//                       return ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: readingList.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           final reading = readingList[index];
//                           return ReadingTile(
//                             reading: reading,
//                             workerId: widget.workerId,
//                           );
//                         },
//                       );
//                     },
//                   );
//                 }),
//                 //   data: ((readings) {
//                 //     StreamBuilder<List<Reading>>(
//                 //       stream: readingNotifier.getReadingsForWorker(
//                 //         widget.workerId,
//                 //       ),
//                 //       builder: (context, snapshot) {
//                 //         print('connectionState: ${snapshot.connectionState}');
//                 //         print('hasError: ${snapshot.hasError}');
//                 //         print('error: ${snapshot.error}');
//                 //         print('hasData: ${snapshot.hasData}');
//                 //         print('data length: ${snapshot.data?.length}');
//                 //         print('workerId being passed: ${widget.workerId}');
//                 //         if (snapshot.connectionState == ConnectionState.waiting) {
//                 //           return const Center(child: CircularProgressIndicator());
//                 //         }
//                 //         if (snapshot.hasError) {
//                 //           return Center(child: Text('Error: ${snapshot.error}'));
//                 //         }
//                 //         final readingList = snapshot.data ?? [];
//                 //         return ListView.builder(
//                 //           shrinkWrap: true,
//                 //           physics: const NeverScrollableScrollPhysics(),
//                 //           itemCount: readingList.length,
//                 //           itemBuilder: (BuildContext context, int index) {
//                 //             final reading = readingList[index];
//                 //             return ReadingTile(
//                 //               reading: reading,
//                 //               workerId: widget.workerId,
//                 //             );
//                 //           },
//                 //         );
//                 //       },
//                 //     );
//                 //   }),
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (error, stack) =>
//                     Center(child: Text('Error: ${error.toString()}')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// SizedBox(
//               width: double.infinity,
//               child: readingProvider.when(
//                 data: ((readings) {
//                   //final isSearchEmpty = searchProvider.isEmpty;

//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         // Row(
//                         //   children: [
//                         //     Expanded(
//                         //       child: TextFormField(
//                         //         initialValue: searchProvider,
//                         //         decoration: InputDecoration(
//                         //             //prefixIconColor: primaryColor,
//                         //             border: const OutlineInputBorder(),
//                         //             prefixIcon: const Icon(
//                         //               Icons.search,
//                         //             ),
//                         //             hintText: "Search",
//                         //             labelText: "Search Customers"),
//                         //         onChanged: (s) {
//                         //           searchNotifier.setSearch(s);
//                         //         },
//                         //       ),
//                         //     ),
//                         //   ],
//                         // ),
//                         Expanded(
//                            child: // isSearchEmpty
//                         //?
//                         // ListView.builder(
//                         //   itemCount: readings.length,
//                         //   itemBuilder: (BuildContext context, int index) {
//                         //     final reading = readings[index];
//                         //     return ReadingTile(reading: reading);
//                         //   },
//                         // ),
//                         // :
//                         StreamBuilder<List<Reading>>(
//                           stream: readingNotifier.getReadingsForWorker(
//                             widget.workerId,
//                           ),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             }
//                             if (snapshot.hasError) {
//                               return Center(
//                                 child: Text('Error: ${snapshot.error}'),
//                               );
//                             }
//                             final readingList = snapshot.data ?? [];
//                             return ListView.builder(
//                               itemCount: readingList.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 final reading = readingList[index];
//                                 return ReadingTile(
//                                   reading: reading,
//                                   workerId: widget.workerId,
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                          ),
//                       ],
//                     ),
//                   );
//                 }),
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (error, stack) =>
//                     Center(child: Text('Error: ${error.toString()}')),
//               ),
//             ),
