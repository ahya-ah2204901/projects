import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/return_reason.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';
import '../models/enums/bank.dart';

class ChequeNotifier extends Notifier<List<Cheque>> {
  final _chequeRepo = AppRepo();
  List<Cheque> _allCheques = [];

  @override
  List<Cheque> build() {
    initializeCheques();
    return [];
  }

  void initializeCheques() async {
    List<Cheque> cheques = await _chequeRepo.loadCheques();
    _allCheques = List.from(cheques);
    state = _allCheques;
  }

  Cheque findCheque(int chequeNo) {
    return _allCheques.firstWhere((c) => c.chequeNo == chequeNo);
  }

  List<Cheque> getCheques(List<dynamic> chequeNos) {
    List<Cheque> cheques = [];
    for (Cheque c in state) {
      if (chequeNos.contains(c.chequeNo)) {
        cheques.add(c);
      }
    }
    return cheques;
  }

  double getTotalChequeAmount(List<dynamic> chequeNos) {
    double total = 0;
    for (Cheque c in state) {
      if (chequeNos.contains(c.chequeNo)) {
        total += c.amount;
      }
    }
    return total;
  }

  List<Cheque> getAwaitingCheques() {
    List<Cheque> cheques = [];
    for (Cheque c in state) {
      if (c.status == ChequeStatus.awaiting) {
        cheques.add(c);
      }
    }
    return cheques;
  }

  List<Cheque> filterByStatus(ChequeStatus status) {
    return (status.name.toLowerCase() == 'all')
        ? _allCheques
        : _allCheques.where((c) => c.status == status).toList();
  }

  void updateChequeListStatus(
      List<dynamic> chequeNos, ChequeStatus chequeStatus) {
    for (var c in chequeNos) {
      updateChequeStatus(findCheque(c), chequeStatus);
    }
  }

  void updateChequeStatus(Cheque cheque, ChequeStatus chequeStatus) {
    List<Cheque> updatedCheques = state.map((c) {
      if (c.chequeNo == cheque.chequeNo) {
        return Cheque(
            chequeNo: cheque.chequeNo,
            amount: cheque.amount,
            drawer: cheque.drawer,
            bankName: cheque.bankName,
            status: chequeStatus, //used for deleting and adding cheque deposit
            receivedDate: cheque.receivedDate,
            dueDate: cheque.dueDate,
            chequeImageUri: cheque.chequeImageUri,
            returnReason: null,
            returnDate: null,
            cashedDate: null);
      }
      return c;
    }).toList();

    state = updatedCheques;

    _allCheques = state;
  }

  void updateChequeListReturn(List<dynamic> chequeNos,
      ChequeStatus chequeStatus, ReturnReason returnReason, String returnDate) {
    for (var c in chequeNos) {
      updateChequeReturn(findCheque(c), chequeStatus, returnReason, returnDate);
    }
  }

  void updateChequeReturn(Cheque cheque, ChequeStatus chequeStatus,
      ReturnReason returnReason, String returnDate) {
    List<Cheque> updatedCheques = state.map((c) {
      if (c.chequeNo == cheque.chequeNo) {
        return Cheque(
            chequeNo: cheque.chequeNo,
            amount: cheque.amount,
            drawer: cheque.drawer,
            bankName: cheque.bankName,
            status: chequeStatus, //used for updating cheque
            receivedDate: cheque.receivedDate,
            dueDate: cheque.dueDate,
            chequeImageUri: cheque.chequeImageUri,
            returnReason: returnReason,
            returnDate: DateTime.tryParse(returnDate) ?? cheque.returnDate,
            cashedDate: null //used for updating cheque
            );
      }
      return c;
    }).toList();

    state = updatedCheques;

    _allCheques = state;
  }

  void updateChequeListCashed(
      List<dynamic> chequeNos, ChequeStatus chequeStatus, String cashedDate) {
    for (var c in chequeNos) {
      updateChequeCashed(findCheque(c), chequeStatus, cashedDate);
    }
  }

  void updateChequeCashed(
      Cheque cheque, ChequeStatus chequeStatus, String cashedDate) {
    List<Cheque> updatedCheques = state.map((c) {
      if (c.chequeNo == cheque.chequeNo) {
        return Cheque(
            chequeNo: cheque.chequeNo,
            amount: cheque.amount,
            drawer: cheque.drawer,
            bankName: cheque.bankName,
            status: chequeStatus, //used for updating cheque
            receivedDate: cheque.receivedDate,
            dueDate: cheque.dueDate,
            chequeImageUri: cheque.chequeImageUri,
            returnReason: null,
            returnDate: null,
            cashedDate: DateTime.tryParse(cashedDate) ??
                cheque.cashedDate //used for updating cheque
            );
      }
      return c;
    }).toList();

    state = updatedCheques;

    _allCheques = state;
  }

  void addChequeAsPayment(int chequeNo, double amount, String drawer, Bank bank,
      DateTime receivedDate, DateTime dueDate, String imageURL) {
    state = [
      ...state,
      Cheque(
          chequeNo: chequeNo,
          amount: amount,
          drawer: drawer,
          bankName: bank,
          receivedDate: receivedDate,
          dueDate: dueDate,
          chequeImageUri: imageURL)
    ];
  }
}

final chequeNotifierProvider =
    NotifierProvider<ChequeNotifier, List<Cheque>>(() => ChequeNotifier());
