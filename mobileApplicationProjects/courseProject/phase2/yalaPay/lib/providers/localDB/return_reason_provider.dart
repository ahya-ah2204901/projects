import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/return_reason_repo.dart';

class ReturnReasonNotifier extends AsyncNotifier<List<String>> {
  ReturnReasonRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(returnReasonRepoProvider.future);
    print("Fetching return reasons...");
    await _repo?.initializeData();
    final returnReasons = await _repo?.getReturnReasons();
    print("Fetched return reasons: $returnReasons");
    return returnReasons ?? [];
  }
}

final returnReasonNotifierProvider =
    AsyncNotifierProvider<ReturnReasonNotifier, List<String>>(
        () => ReturnReasonNotifier());
