import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';

class ChequeDepositNotifier extends Notifier<List<ChequeDeposit>> {
  final _chequeRepo = AppRepo();
  List<ChequeDeposit> _allChequeDeposits = [];

  @override
  List<ChequeDeposit> build() {
    initializeChequeDeposits();
    return [];
  }

  void initializeChequeDeposits() async {
    List<ChequeDeposit> chequeDeposits = await _chequeRepo.loadChequeDeposits();
    _allChequeDeposits = chequeDeposits;
    state = _allChequeDeposits;
  }

  void deleteChequeDeposit(ChequeDeposit chequeDeposit) {
    var chequeDeposits = [...state];
    // ignore: prefer_typing_uninitialized_variables
    var toBeRemoved;
    for (var c in chequeDeposits) {
      if (chequeDeposit.id == c.id) {
        toBeRemoved = c;
        break;
      }
    }
    chequeDeposits.remove(toBeRemoved);
    state = List.from(chequeDeposits);
  }

  void addChequeDeposit(
      String bankAccountNo, List<Cheque> cheques, String depositDate) {
    List<dynamic> chequeNos = [];
    for (var c in cheques) {
      chequeNos.add(c.chequeNo);
    }
    state = [
      ...state,
      ChequeDeposit(
        id: generateChequeDepId(),
        bankAccountNo: bankAccountNo,
        status: DepositStatus.deposited,
        depositDate: DateTime.tryParse(depositDate) ?? DateTime.now(),
        chequeNos: chequeNos,
      )
    ];
    _allChequeDeposits = state;
  }

  void updateDepositStatus(ChequeDeposit chequeDeposit,
      DepositStatus depositStatus, String cashedDate) {
    List<ChequeDeposit> updatedChequeDeposits = state.map((cd) {
      if (cd.id == chequeDeposit.id) {
        return ChequeDeposit(
          id: chequeDeposit.id,
          bankAccountNo: chequeDeposit.bankAccountNo,
          depositDate: chequeDeposit.depositDate,
          status: depositStatus, //used for deleting, adding and updating cheque
          chequeNos: chequeDeposit.chequeNos,
          cashedDate: DateTime.tryParse(cashedDate) ?? DateTime.now(),
        );
      }
      return cd;
    }).toList();

    state = updatedChequeDeposits;

    _allChequeDeposits = state;
  }

  String generateChequeDepId() {
    int id = _allChequeDeposits.length + 1;
    bool unique = true;
    while (!unique) {
      unique = true;
      for (var cd in _allChequeDeposits) {
        if (cd.id == id.toString()) {
          unique = false;
          id++;
          break;
        }
      }
    }
    return id.toString();
  }

  ChequeDeposit findChequeDeposit(String chequeDepId) {
    return _allChequeDeposits.firstWhere((c) => c.id == chequeDepId);
  }

  void searchChequeDeposits(String q) {
    if (q.isNotEmpty) {
      var startsWith = _allChequeDeposits
          .where((i) => (i.bankAccountNo.startsWith(q)))
          .toList();
      var contains = _allChequeDeposits
          .where((i) => ((i.bankAccountNo.contains(q)) &&
              (!i.bankAccountNo.startsWith(q))))
          .toList();

      state = [...startsWith, ...contains];
    } else {
      state = _allChequeDeposits;
    }
  }
}

final chequeDepositNotifierProvider =
    NotifierProvider<ChequeDepositNotifier, List<ChequeDeposit>>(
        () => ChequeDepositNotifier());
