import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/providers/alert_provider.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/widgets/alert_tile.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  String selectedStatus = "all";
  String selectedSeverity = "all";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _label(String value) {
    return value[0].toUpperCase() + value.substring(1);
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
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Color(0xFF6B7280),
          ),
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                "$label: ${entry.value}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
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

  @override
  Widget build(BuildContext context) {
    final alertProvider = ref.watch(alertNotifierProvider);
    final alertNotifier = ref.read(alertNotifierProvider.notifier);

    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;
    final userId = fb.FirebaseAuth.instance.currentUser?.uid;

    if (authUser == null || users == null || userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);
    final isSupervisor = loggedInUser.role.toLowerCase() == "supervisor";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: alertProvider.when(
          data: (_) {
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
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase().trim();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search alerts",
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
                          label: "Status",
                          value: selectedStatus,
                          items: const {
                            "all": "All",
                            "new": "New",
                            "acknowledged": "Acknowledged",
                            "resolved": "Resolved",
                          },
                          onChanged: (value) {
                            setState(() => selectedStatus = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterDropdown(
                          label: "Severity",
                          value: selectedSeverity,
                          items: const {
                            "all": "All",
                            "warning": "Warning",
                            "critical": "Critical",
                          },
                          onChanged: (value) {
                            setState(() => selectedSeverity = value);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder(
                      stream: alertNotifier.getFilteredAlertsForUser(
                        user: loggedInUser,
                        searchQuery: searchQuery,
                        selectedStatus: selectedStatus,
                        selectedSeverity: selectedSeverity,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final alertList = snapshot.data ?? [];

                        if (alertList.isEmpty) {
                          return const Center(
                            child: Text(
                              "No alerts found",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: alertList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return AlertTile(
                              alert: alertList[index],
                              showWorkerInfo: isSupervisor,
                            );
                          },
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
        ),
      ),
    );
  }
}
