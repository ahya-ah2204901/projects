import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/bank_repo.dart';

class BankNotifier extends AsyncNotifier<List<String>> {
  BankRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(bankRepoProvider.future);
    print("Fetching banks...");
    await _repo?.initializeData();
    final banks = await _repo?.getBanks();
    print("Fetched banks: $banks");
    return banks ?? [];
  }
}

final bankNotifierProvider =
    AsyncNotifierProvider<BankNotifier, List<String>>(() => BankNotifier());
