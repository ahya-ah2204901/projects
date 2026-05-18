import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workerapp/models/user.dart';
import 'package:workerapp/providers/auth_provider.dart';
import 'package:workerapp/providers/user_provider.dart';
import 'package:workerapp/widgets/worker_tile.dart';

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key});

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authNotifierProvider).value;
    final users = ref.watch(userNotifierProvider).value;

    if (authUser == null || users == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final loggedInUser = users.firstWhere((u) => u.id == authUser.uid);
    final workersProvider = ref.watch(
      workersForSupervisorProvider(loggedInUser.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // /// Header
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(vertical: 18),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF062B67),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: const Center(
              //     child: Text(
              //       "Workers",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),

              /// Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase().trim();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Worker list
              Expanded(
                child: workersProvider.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (workerList) {
                    final filteredWorkers = workerList.where((worker) {
                      final name = "${worker.firstName} ${worker.lastName}"
                          .toLowerCase();
                      final email = worker.email.toLowerCase();

                      return name.contains(searchQuery) ||
                          email.contains(searchQuery);
                    }).toList();

                    if (filteredWorkers.isEmpty) {
                      return const Center(child: Text("No workers found"));
                    }

                    return ListView.builder(
                      itemCount: filteredWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = filteredWorkers[index];
                        return WorkerTile(worker: worker);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
