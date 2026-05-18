import 'package:cloud_firestore/cloud_firestore.dart';

class ChequeDeposit {
  String id;
  DateTime? depositDate;
  String bankAccountNo;
  String status;
  List<dynamic>? chequeNos;
  DateTime? cashedDate;

  ChequeDeposit(
      {this.id = '',
      this.depositDate,
      this.bankAccountNo = '',
      this.status = 'Deposited',
      this.chequeNos,
      this.cashedDate});

  factory ChequeDeposit.fromMap(Map<String, dynamic> map) {
    return ChequeDeposit(
      id: map['id']?.toString() ?? '',
      depositDate: map['depositDate'] is Timestamp
          ? (map['depositDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['depositDate']?.toString() ?? ''),
      bankAccountNo: map['bankAccountNo']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      chequeNos: (map['chequeNos'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList(),
      cashedDate: map['cashedDate'] is Timestamp
          ? (map['cashedDate'] as Timestamp).toDate()
          : map['cashedDate'] != null
              ? DateTime.tryParse(map['cashedDate']!.toString())
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'depositDate': formatDate(depositDate),
      'bankAccountNo': bankAccountNo,
      'status': status,
      'chequeNos': chequeNos,
      'cashedDate': formatDate(cashedDate),
    };
  }

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
