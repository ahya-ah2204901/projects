import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/bank_account_repo.dart';

import '../../models/enums/bank_account.dart';

class BankAccountNotifier extends AsyncNotifier<List<BankAccount>> {
  BankAccountRepo? _repo;

  @override
  Future<List<BankAccount>> build() async {
    _repo = await ref.watch(bankAccountRepoProvider.future);
    print("Fetching bank accounts...");
    await _repo?.initializeData();
    final bankAccounts = await _repo?.getBankAccounts();
    print("Fetched bank accounts: $bankAccounts");
    return bankAccounts ?? [];
  }
}

final bankAccountNotifierProvider =
    AsyncNotifierProvider<BankAccountNotifier, List<BankAccount>>(
        () => BankAccountNotifier());

