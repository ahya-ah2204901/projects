import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/return_reason.dart';
import 'package:yala_pay/providers/localDB/cheque_status_provider.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/cheque_repo.dart';
import '../models/enums/bank.dart';



class ChequeNotifier extends AsyncNotifier<List<Cheque>> {
  late final ChequeRepo _chequeRepo;

  @override
  Future<List<Cheque>> build() async {
    _chequeRepo = await ref.watch(chequeRepoProvider.future);
    await _chequeRepo.initializeCheques();
    _chequeRepo.observeCheques().listen((cheques) {
      state = AsyncValue.data(cheques);
    }).onError((e) {
      print('Error building cheque provider: $e');
    });
    return [];
  }

  Stream<List<Cheque>> observeCheques() {
    return _chequeRepo.observeCheques();
  }

  Future<void> updateChequeStatus(Cheque cheque, String chequeStatus) async {
    await _chequeRepo.updateChequeStatus(cheque, chequeStatus);
  }

  Future<void> updateChequeListStatus(
      List<dynamic> chequeNos, String chequeStatus) async {
    for (var c in chequeNos) {
      final cheque = await findCheque(c);
      await _chequeRepo.updateChequeStatus(cheque, chequeStatus);
    }
  }

  Stream<List<Cheque>> getAwaitingCheques() {
    return _chequeRepo.getAwaitingCheques();
  }

  Future<double> getTotalChequeAmount(List<dynamic> chequeNos) async {
    return _chequeRepo.getTotalChequeAmount(chequeNos);
  }

  Future<Cheque> findCheque(int chequeNo) {
    return _chequeRepo.findCheque(chequeNo);
  }

  Future<List<double>> totalChequesOfAllStatuses() {
    // final chequeStatuses = ref.watch(chequeStatusNotifierProvider);
    return _chequeRepo.totalChequesOfAllStatuses(
        ['Awaiting', 'Deposited', 'Cashed', 'Returned']);
  }

  /// returns filtered cheques by due date range and status
  Future<List<Cheque>> filterCheques(
          String startDate, String endDate, String status) =>
      _chequeRepo.filterCheques(startDate, endDate, status);

  Future<void> updateChequeListCashed(
      List<dynamic> chequeNos, String chequeStatus, String cashedDate) async {
    for (var c in chequeNos) {
      final cheque = await findCheque(c);
      await _chequeRepo.updateChequeCashed(cheque, chequeStatus, cashedDate);
    }
  }

  Future<void> updateChequeCashed(
      Cheque cheque, String chequeStatus, String cashedDate) async {
    await _chequeRepo.updateChequeCashed(cheque, chequeStatus, cashedDate);
  }

  Future<void> updateChequeReturn(Cheque cheque, String chequeStatus,
      String returnReason, String returnDate) async {
    await _chequeRepo.updateChequeReturn(
        cheque, chequeStatus, returnReason, returnDate);
  }

  Future<void> addChequeAsPayment(
      int chequeNo,
      double amount,
      String drawer,
      String bank,
      DateTime receivedDate,
      DateTime dueDate,
      String imageURL) async {
    await _chequeRepo.addChequeAsPayment(
        chequeNo, amount, drawer, bank, receivedDate, dueDate, imageURL);
  }

  Future<void> deleteCheque(int chequeNo) async {
    final cheque = await _chequeRepo.findCheque(chequeNo);
    await _chequeRepo.deleteCheque(cheque);
  }

  Future<String?> uploadImageFromAssets(String? imageUri) async{
    return _chequeRepo.uploadImageFromAssets(imageUri);
  }

  Future<String?> uploadChequeImageFromGallery() async {
    return _chequeRepo.uploadChequeImageFromGallery();
  }

  Future<String?> uploadChequeImageFromCamera() async {
    return _chequeRepo.uploadChequeImageFromCamera();
  }

  
}

final chequeNotifierProvider =
    AsyncNotifierProvider<ChequeNotifier, List<Cheque>>(() => ChequeNotifier());
