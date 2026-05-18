import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/models/sensor.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/sensor_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/routes/app_router.dart';

class ReadingTile extends ConsumerWidget {
  final Reading reading;
  final String workerId;

  const ReadingTile({super.key, required this.reading, required this.workerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingNotifier = ref.read(readingNotifierProvider.notifier);
    final authProvider = ref.watch(authNotifierProvider);
    final usersProvider = ref.watch(userNotifierProvider);
    return StreamBuilder<List<Sensor>>(
      stream: ref
          .read(sensorNotifierProvider.notifier)
          .getSensorsForWorker(workerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 74,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final sensors = snapshot.data ?? [];
        final sensor = sensors.firstWhereOrNull(
          (s) => s.id == reading.sensorId,
        );
        final type = sensor?.type ?? "Unknown";

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.pushNamed(
              AppRouter.readingDetails.name,
              pathParameters: {'readingId': reading.id},
            );
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6EBF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFF0D21A1).withOpacity(0.10),
                  child: Icon(
                    _iconForType(type),
                    color: const Color(0xFF0D21A1),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF011638),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (type.toLowerCase() == "breathing status")
                        Text(
                          "Value: ${breathingLabelFromCode(reading.value)}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        )
                      else
                        Text(
                          "Value: ${reading.value}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                      const SizedBox(height: 2),
                      Text(
                        "Time: ${_formatTime(reading.time)}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF0D21A1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  String _formatTime(DateTime time) {
    return "${time.day.toString().padLeft(2, '0')}/"
        "${time.month.toString().padLeft(2, '0')}/"
        "${time.year} "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
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
