import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/cheque_deposit_repo.dart';

import 'dart:async';

class ChequeDepositNotifier extends AsyncNotifier<List<ChequeDeposit>> {
  late final ChequeDepositRepo _chequeDepRepo;

  @override
  Future<List<ChequeDeposit>> build() async {
    _chequeDepRepo = await ref.watch(chequeDepositRepoProvider.future);
    await _chequeDepRepo.initializeChequeDeposits();
    _chequeDepRepo.observeChequeDeposits().listen((chequeDeposits) {
      state = AsyncValue.data(chequeDeposits);
    }).onError((e) {
      print('Error building cheque deposit provider: $e');
    });
    return [];
  }

  Future<void> addChequeDeposit(
      String bankAccountNo, List<Cheque> cheques, String depositDate) async {
    await _chequeDepRepo.addChequeDeposit(bankAccountNo, cheques, depositDate);
  }

  Future<void> updateDepositStatus(ChequeDeposit chequeDeposit,
      String depositStatus, String cashedDate) async {
    await _chequeDepRepo.updateDepositStatus(
        chequeDeposit, depositStatus, cashedDate);
  }

  Future<void> deleteChequeDeposit(ChequeDeposit chequeDeposit) async {
    await _chequeDepRepo.deleteChequeDeposit(chequeDeposit);
  }

  Stream<List<ChequeDeposit>> searchChequeDeposits(String q) {
    return _chequeDepRepo.searchChequeDeposits(q);
  }

  Future<ChequeDeposit> findChequeDeposit(String chequeDepId) {
    return _chequeDepRepo.findChequeDeposit(chequeDepId);
  }
}

final chequeDepositNotifierProvider =
    AsyncNotifierProvider<ChequeDepositNotifier, List<ChequeDeposit>>(
        () => ChequeDepositNotifier());
