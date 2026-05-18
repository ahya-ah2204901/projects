import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/cheque_deposit.dart';

class ChequeDepositRepo {
  final CollectionReference chequeDepRef;

  ChequeDepositRepo({required this.chequeDepRef});

  // reads from chequedep json file
  Future<void> initializeChequeDeposits() async {
    final snapshot = await chequeDepRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data =
            await rootBundle.loadString('assets/data/cheque-deposits.json');
        var chequeDepJsonList = jsonDecode(data);
        for (var chequeDepMap in chequeDepJsonList) {
          final docId = chequeDepRef.doc().id;
          ChequeDeposit chequeDeposit = ChequeDeposit.fromMap(chequeDepMap);
          final newChequeDeposit = ChequeDeposit(
              id: docId,
              depositDate: chequeDeposit.depositDate,
              bankAccountNo: chequeDeposit.bankAccountNo,
              status: chequeDeposit.status,
              chequeNos: chequeDeposit.chequeNos,
              cashedDate: chequeDeposit.cashedDate);
          await chequeDepRef.doc(docId).set(newChequeDeposit.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing cheque deposits: $e');
      }
    }
  }

  // observe all cheque deposits
  Stream<List<ChequeDeposit>> observeChequeDeposits() {
    return chequeDepRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ChequeDeposit.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // add a cheque deposit
  Future<void> addChequeDeposit(
      String bankAccountNo, List<Cheque> cheques, String depositDate) async {
    List<dynamic> chequeNos = [];
    for (var c in cheques) {
      chequeNos.add(c.chequeNo);
    }
    final docId = chequeDepRef.doc().id;
    final newChequeDeposit = ChequeDeposit(
        id: docId,
        bankAccountNo: bankAccountNo,
        status: 'Deposited',
        depositDate: DateTime.tryParse(depositDate) ?? DateTime.now(),
        chequeNos: chequeNos);
    await chequeDepRef.doc(docId).set(newChequeDeposit.toMap());
  }

  //update a cheque dep
  Future<void> updateDepositStatus(ChequeDeposit chequeDeposit,
      String depositStatus, String cashedDate) async {
    final updatedChequeDeposit = ChequeDeposit(
      id: chequeDeposit.id,
      bankAccountNo: chequeDeposit.bankAccountNo,
      depositDate: chequeDeposit.depositDate,
      status: depositStatus,
      chequeNos: chequeDeposit.chequeNos,
      cashedDate: DateTime.tryParse(cashedDate) ?? DateTime.now(),
    );

    await chequeDepRef
        .doc(updatedChequeDeposit.id)
        .update(updatedChequeDeposit.toMap());
  }

  Future<ChequeDeposit> findChequeDeposit(String chequeDepId) async {
    final snapshot = await chequeDepRef.get();
    final chequeDeposits = snapshot.docs.map((doc) {
      return ChequeDeposit.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return chequeDeposits.firstWhere((c) => c.id == chequeDepId, orElse: () {
      throw Exception('Cheque Deposit not found');
    });
  }

  /// delete a cheque deposit
  Future<void> deleteChequeDeposit(ChequeDeposit chequeDeposit) async {
    await chequeDepRef.doc(chequeDeposit.id).delete();
  }

  Stream<List<ChequeDeposit>> searchChequeDeposits(String q) {
    final query = q.toLowerCase();

    final filtered = chequeDepRef.where(Filter.and(
        Filter("bankAccountNo", isGreaterThanOrEqualTo: query),
        Filter("bankAccountNo", isLessThan: '$query\uf8ff')));

    return filtered.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ChequeDeposit.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
