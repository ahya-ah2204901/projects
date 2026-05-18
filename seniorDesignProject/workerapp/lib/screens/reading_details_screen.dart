import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/providers/reading_provider.dart';

class ReadingDetailsScreen extends ConsumerStatefulWidget {
  final String readingId;
  const ReadingDetailsScreen({super.key, required this.readingId});

  @override
  ConsumerState<ReadingDetailsScreen> createState() =>
      _ReadingDetailsScreenState();
}

class _ReadingDetailsScreenState extends ConsumerState<ReadingDetailsScreen> {
  String _formatTime(DateTime time) {
    return "${time.day.toString().padLeft(2, '0')}/"
        "${time.month.toString().padLeft(2, '0')}/"
        "${time.year}  "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  IconData _iconForType(String type) {
    final lower = type.toLowerCase();

    if (lower.contains('heart')) return Icons.favorite_outline;
    if (lower.contains('body')) return Icons.thermostat_outlined;
    if (lower.contains('humidity')) return Icons.water_drop_outlined;
    if (lower.contains('temp')) return Icons.device_thermostat_outlined;
    if (lower.contains('breath')) return Icons.air;

    return Icons.sensors_outlined;
  }

  Widget _buildDetailTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D21A1), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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

  @override
  Widget build(BuildContext context) {
    final detailsProvider = ref.watch(readingDetailsProvider(widget.readingId));

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
          "Reading Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: detailsProvider.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text("Reading not found"));
          }

          final reading = details.reading;
          final sensor = details.sensor;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      //const
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(
                          0xFF0D21A1,
                        ).withOpacity(0.10),
                        child: Icon(
                          _iconForType(sensor.type),
                          color: const Color(0xFF0D21A1),
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        sensor.type,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (sensor.type.toLowerCase() == "breathing status")
                        Text(
                          breathingLabelFromCode(reading.value),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF011638),
                          ),
                        )
                      else
                        Text(
                          reading.value.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF011638),
                          ),
                        ),
                      const SizedBox(height: 6),
                      const Text(
                        "Recorded Sensor Value",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reading Information",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF011638),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _buildDetailTile(
                  label: "Reading ID",
                  value: reading.id,
                  icon: Icons.tag_outlined,
                ),
                _buildDetailTile(
                  label: "Data Type",
                  value: sensor.type,
                  icon: Icons.category_outlined,
                ),
                if (sensor.type.toLowerCase() == "breathing status")
                  _buildDetailTile(
                    label: "Value",
                    value: breathingLabelFromCode(reading.value),
                    icon: Icons.speed_outlined,
                  )
                else
                  _buildDetailTile(
                    label: "Value",
                    value: reading.value.toString(),
                    icon: Icons.speed_outlined,
                  ),
                _buildDetailTile(
                  label: "Time",
                  value: _formatTime(reading.time),
                  icon: Icons.access_time,
                ),
                _buildDetailTile(
                  label: "Sensor ID",
                  value: reading.sensorId,
                  icon: Icons.sensors_outlined,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
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
