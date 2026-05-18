import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/cheque_status_repo.dart';

class ChequeStatusNotifier extends AsyncNotifier<List<String>> {
  ChequeStatusRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(chequeStatusRepoProvider.future);
    print("Fetching cheque statuses...");
    await _repo?.initializeData();
    final chequeStatuses = await _repo?.getChequeStatuses();
    print("Fetched cheque statuses: $chequeStatuses");
    return chequeStatuses ?? [];
  }
}

final chequeStatusNotifierProvider =
    AsyncNotifierProvider<ChequeStatusNotifier, List<String>>(
        () => ChequeStatusNotifier());
