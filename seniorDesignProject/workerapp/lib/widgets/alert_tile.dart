import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/models/alert.dart';
import 'package:workerapp/models/reading.dart';
import 'package:workerapp/providers/alert_provider.dart';
import 'package:workerapp/providers/reading_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/routes/app_router.dart';

class AlertTile extends ConsumerWidget {
  final Alert alert;
  final bool showWorkerInfo;

  const AlertTile({
    super.key,
    required this.alert,
    this.showWorkerInfo = false,
  });

  Color _severityColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
      case 'warning':
      case 'caution':
        return Colors.orange;
      case 'high':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'acknowledged':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _severityIcon(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Icons.info_outline;
      case 'medium':
      case 'warning':
      case 'caution':
        return Icons.warning_amber_rounded;
      case 'high':
      case 'critical':
        return Icons.error_outline_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String _formatTime(DateTime time) {
    return "${time.day.toString().padLeft(2, '0')}/"
        "${time.month.toString().padLeft(2, '0')}/"
        "${time.year} "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userNotifierProvider).value;
    final worker = users?.where((u) => u.id == alert.workerId).firstOrNull;
    final workerName = worker == null
        ? "Worker ID: ${alert.workerId}"
        : "${worker.firstName} ${worker.lastName}";

    final severityColor = _severityColor(alert.severityLevel);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.pushNamed(
          AppRouter.alertDetails.name,
          pathParameters: {'alertId': alert.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: severityColor.withOpacity(0.18)),
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
              backgroundColor: severityColor.withOpacity(0.10),
              child: Icon(
                _severityIcon(alert.severityLevel),
                color: severityColor,
                size: 23,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showWorkerInfo) ...[
                    Text(
                      workerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF011638),
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    alert.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF011638),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(alert.time),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alert.severityLevel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: severityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(alert.status).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alert.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(alert.status),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF0D21A1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color getSeverityColor(String level) {
  switch (level.toLowerCase()) {
    case 'low':
      return Colors.green;
    case 'medium':
      return Colors.orange;
    case 'high':
      return Colors.red;
    default:
      return Colors.grey; // fallback
  }
}
