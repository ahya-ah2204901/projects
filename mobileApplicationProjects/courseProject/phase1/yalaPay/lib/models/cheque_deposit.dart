import 'package:yala_pay/models/enums/deposit_status.dart';

class ChequeDeposit {
  String id;
  DateTime? depositDate;
  String bankAccountNo;
  DepositStatus status;
  List<dynamic>? chequeNos;
  DateTime? cashedDate;

  ChequeDeposit(
      {this.id = '',
      this.depositDate,
      this.bankAccountNo = '',
      this.status = DepositStatus.deposited,
      this.chequeNos,
      this.cashedDate});

  factory ChequeDeposit.fromMap(Map<String, dynamic> map) {
    return ChequeDeposit(
      id: map['id'] ?? '',
      depositDate: map['depositDate'] != null
          ? DateTime.tryParse(map['depositDate'])
          : null,
      bankAccountNo: map['bankAccountNo'] ?? '',
      status: parseStatus(map['status']),
      chequeNos: (map['chequeNos'] as List<dynamic>?)!.map((e) => e).toList(),
      cashedDate: map['cashedDate'] != null
          ? DateTime.tryParse(map['cashedDate'])
          : null,
    );
  }

  static DepositStatus parseStatus(String status) {
    return DepositStatus.values.firstWhere(
      (s) => s.toString().split('.').last.toLowerCase() == status.toLowerCase(),
      orElse: () => DepositStatus.deposited,
    );
  }
}
