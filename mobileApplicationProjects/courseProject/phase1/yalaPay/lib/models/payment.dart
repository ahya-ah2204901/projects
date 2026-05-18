import 'package:yala_pay/models/enums/payment_mode.dart';

class Payment {
  String id;
  String invoiceNo;
  double amount;
  DateTime? paymentDate;
  late PaymentMode paymentMode;
  int? chequeNo;

  Payment(
      {this.id = '',
      this.invoiceNo = '',
      this.amount = 0.0,
      this.paymentDate,
      this.chequeNo = 0,
      required this.paymentMode});

  static PaymentMode _mapPaymentMode(String mode) {
    switch (mode) {
      case "Bank transfer":
        return PaymentMode.bankTransfer;
      case "Credit card":
        return PaymentMode.creditCard;
      case "Cheque":
        return PaymentMode.cheque;
      default:
        throw Exception('Unknown status: $mode');
    }
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      invoiceNo: map['invoiceNo'] ?? '',
      amount: map['amount'] ?? 0.0,
      paymentDate: DateTime.parse(map['paymentDate']),
      paymentMode: _mapPaymentMode(map['paymentMode']),
      chequeNo: map['chequeNo'] ?? 0,
    );
  }
}
