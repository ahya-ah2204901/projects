import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workerapp/models/user.dart';
import 'package:workerapp/routes/app_router.dart';

class WorkerTile extends ConsumerWidget {
  final User worker;

  const WorkerTile({super.key, required this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.pushNamed(
          AppRouter.workerReadings.name,
          pathParameters: {'workerId': worker.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6EBF2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Avatar
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE8EEF9),
              child: Icon(Icons.person_outline, color: Color(0xFF0D21A1)),
            ),

            const SizedBox(width: 12),

            /// Name + Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${worker.firstName} ${worker.lastName}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF011638),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    worker.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            /// Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF0D21A1),
            ),
          ],
        ),
      ),
    );
  }
}
