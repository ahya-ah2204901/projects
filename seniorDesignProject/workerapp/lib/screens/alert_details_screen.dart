import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/providers/alert_provider.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/user_provider.dart';

class AlertDetailsScreen extends ConsumerStatefulWidget {
  final String alertId;
  const AlertDetailsScreen({super.key, required this.alertId});

  @override
  ConsumerState<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends ConsumerState<AlertDetailsScreen> {
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
        "${time.year}  "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
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
          Icon(
            icon,
            color: //const Color.fromARGB(255, 8, 21, 65), size: 22,),
            const Color(
              0xFF0D21A1,
            ),
            size: 22,
          ),
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
    final alerts = ref.watch(alertNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;

    if (alerts == null || users == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final matchingAlerts = alerts.where((a) => a.id == widget.alertId);
    if (matchingAlerts.isEmpty) {
      return const Scaffold(body: Center(child: Text('Alert not found')));
    }

    final alert = matchingAlerts.first;
    final worker = users.where((u) => u.id == alert.workerId).firstOrNull;

    final workerName = worker == null
        ? "Unknown worker"
        : "${worker.firstName} ${worker.lastName}";

    //  final userNotifier = ref.read(userNotifierProvider.notifier);
    //final authUser = ref.watch(authNotifierProvider).value;
    //final users = ref.watch(userNotifierProvider).value;
    //final userId = fb.FirebaseAuth.instance.currentUser?.uid;

    // if (authUser == null || users == null || userId == null) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    final severityColor = _severityColor(alert.severityLevel);
    final authUser = ref.watch(authNotifierProvider).value;

    final loggedInUsers = users.where((u) => u.id == authUser?.uid);
    if (loggedInUsers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loggedInUser = loggedInUsers.first;
    //final currentUser = users.firstWhereOrNull((u) => u.id == authUser?.uid);
    final isSupervisor = loggedInUser?.role.toLowerCase() == 'supervisor';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(
          255,
          8,
          21,
          65,
        ), // const Color(0xFF0D21A1),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "Alert Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: severityColor.withOpacity(0.15)),
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
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: severityColor.withOpacity(0.10),
                    child: Icon(
                      _severityIcon(alert.severityLevel),
                      color: severityColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.severityLevel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: severityColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF011638),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(alert.status).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      alert.status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(alert.status), //.withOpacity(0.10),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alert Information",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF011638),
                ),
              ),
            ),

            const SizedBox(height: 14),

            _buildDetailTile(
              label: "Alert ID",
              value: alert.id,
              icon: Icons.tag_outlined,
            ),
            _buildDetailTile(
              label: "Worker",
              value: workerName,
              icon: Icons.person_outline,
            ),

            _buildDetailTile(
              label: "Severity Level",
              value: alert.severityLevel,
              icon: Icons.priority_high_rounded,
            ),
            _buildDetailTile(
              label: "Status",
              value: alert.status,
              icon: Icons.info_outline,
            ),
            _buildDetailTile(
              label: "Time",
              value: _formatTime(alert.time),
              icon: Icons.access_time,
            ),
            _buildDetailTile(
              label: "Description",
              value: alert.description,
              icon: Icons.description_outlined,
            ),
            _buildDetailTile(
              label: "Worker ID",
              value: alert.workerId,
              icon: Icons.badge_outlined,
            ),
            _buildDetailTile(
              label: "Reading ID",
              value: alert.readingId,
              icon: Icons.monitor_heart_outlined,
            ),
            if (isSupervisor) ...[
              const SizedBox(height: 8),

              if (alert.status.toLowerCase() == 'new')
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(alertNotifierProvider.notifier)
                          .updateAlertStatus(alert.id, 'ACKNOWLEDGED');
                      if (context.mounted) context.pop();
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark as Acknowledged'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D21A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

              if (alert.status.toLowerCase() != 'resolved') ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(alertNotifierProvider.notifier)
                          .updateAlertStatus(alert.id, 'RESOLVED');
                      if (context.mounted) context.pop();
                    },
                    icon: const Icon(Icons.task_alt),
                    label: const Text('Mark as Resolved'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
