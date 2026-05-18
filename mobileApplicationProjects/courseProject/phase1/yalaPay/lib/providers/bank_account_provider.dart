import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/bank_account.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';

class BankAccountNotifier extends Notifier<List<BankAccount>> {
  final _bankAccountRepo = AppRepo();
  List<BankAccount> _allAccounts = [];

  @override
  List<BankAccount> build() {
    initializeAccounts();
    return [];
  }

  void initializeAccounts() async {
    List<BankAccount> accounts = await _bankAccountRepo.loadAccounts();
    _allAccounts = List.from(accounts);
    state = _allAccounts;
  }
}

final bankAccountNotifierProvider =
    NotifierProvider<BankAccountNotifier, List<BankAccount>>(
        () => BankAccountNotifier());
