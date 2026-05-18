class Payment {
  String id;
  String invoiceNo;
  double amount;
  DateTime? paymentDate;
  late String paymentMode;
  int? chequeNo;

  Payment(
      {this.id = '',
      this.invoiceNo = '',
      this.amount = 0.0,
      this.paymentDate,
      this.chequeNo = 0,
      required this.paymentMode});

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      invoiceNo: map['invoiceNo'] ?? '',
      amount: map['amount'] ?? 0.0,
      paymentDate: DateTime.parse(map['paymentDate']),
      paymentMode: map['paymentMode'],
      chequeNo: map['chequeNo'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'amount': amount,
      'paymentDate': paymentDate.toString(),
      'paymentMode': paymentMode.toString(),
      'paymentModeLower' : paymentMode.toString().toLowerCase(),
      'chequeNo': chequeNo,
    };
  }
}
