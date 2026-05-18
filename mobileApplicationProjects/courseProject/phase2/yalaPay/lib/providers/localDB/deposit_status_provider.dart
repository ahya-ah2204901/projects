import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/deposit_status_repo.dart';

class DepositStatusNotifier extends AsyncNotifier<List<String>> {
  DepositStatusRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(depositStatusRepoProvider.future);
    print("Fetching deposit statuses...");
    await _repo?.initializeData();
    final depositStatuses = await _repo?.getDepositStatuses();
    print("Fetched deposit statuses: $depositStatuses");
    return depositStatuses ?? [];
  }
}

final depositStatusNotifierProvider =
    AsyncNotifierProvider<DepositStatusNotifier, List<String>>(
        () => DepositStatusNotifier());
