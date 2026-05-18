import 'package:cloud_firestore/cloud_firestore.dart';


class Cheque {
  int chequeNo;
  double amount;
  String drawer;
  late String bankName;
  String status;
  DateTime? receivedDate;
  DateTime? dueDate;
  String? chequeImageUri;
  String? returnReason;
  DateTime? returnDate;
  DateTime? cashedDate;

  Cheque(
      {this.chequeNo = 0,
      this.amount = 0.0,
      this.drawer = '',
      required this.bankName,
      this.status = "Awaiting",
      this.receivedDate,
      this.dueDate,
      this.chequeImageUri = '',
      this.returnReason,
      this.returnDate,
      this.cashedDate});

  factory Cheque.fromMap(Map<String, dynamic> map) {
    return Cheque(
      chequeNo: int.tryParse(map['chequeNo']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
      drawer: map['drawer'] ?? '',
      bankName: map['bankName'] ?? '',
      status: map['status']?.toString() ?? '',
      receivedDate: map['receivedDate'] is Timestamp
          ? (map['receivedDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['receivedDate']?.toString() ?? '') ??
              DateTime.now(),
      dueDate: map['dueDate'] is Timestamp
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['dueDate']?.toString() ?? '') ??
              DateTime.now(),
      chequeImageUri: map['chequeImageUri'] ?? '',
      returnReason: map['returnReason'] ?? null,
      returnDate: map['returnDate'] is Timestamp
          ? (map['returnDate'] as Timestamp).toDate()
          : map['returnDate'] != null
              ? DateTime.tryParse(map['returnDate']?.toString() ?? '')
              : null,
      cashedDate: map['cashedDate'] is Timestamp
          ? (map['cashedDate'] as Timestamp).toDate()
          : map['cashedDate'] != null
              ? DateTime.tryParse(map['cashedDate']?.toString() ?? '')
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chequeNo': chequeNo,
      'amount': amount,
      'drawer': drawer,
      'bankName': bankName,
      'status': status,
      'receivedDate': formatDate(receivedDate),
      'dueDate': formatDate(dueDate),
      'chequeImageUri': chequeImageUri,
      'returnReason': returnReason,
      'returnDate': formatDate(returnDate),
      'cashedDate': formatDate(cashedDate),
    };
  }

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
