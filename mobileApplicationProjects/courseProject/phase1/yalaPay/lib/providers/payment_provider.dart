import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/enums/payment_mode.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';

class PaymentNotifier extends Notifier<List<Payment>> {
  final _paymentsRepo = AppRepo();
  List<Payment> _allPayments = [];
  @override
  List<Payment> build() {
    initializePayments();
    return [];
  }

  void initializePayments() async {
    List<Payment> invoices = await _paymentsRepo.loadPayments();
    _allPayments = invoices;
    state = _allPayments;
  }

  void deletePayment(Payment payment) {
    _allPayments.removeWhere((pay) => pay.id == payment.id);
    state = List.from(_allPayments);
  }

  void addUpdatePayment({
    required id,
    required invoiceNo,
    required amount,
    required paymentDate,
    required paymentMode,
    required List<Invoice> invoices,
    int? chequeNo,
  }) {
    final existingPaymentIndex = state.indexWhere((p) => p.id == id);
    if (existingPaymentIndex != -1) {
      final updatedPayment = Payment(
        id: id,
        invoiceNo: invoiceNo,
        amount: amount,
        paymentDate: paymentDate,
        paymentMode: paymentMode,
        chequeNo: paymentMode == PaymentMode.cheque ? chequeNo : null,
      );
      _allPayments = [
        ..._allPayments.sublist(0, existingPaymentIndex),
        updatedPayment,
        ..._allPayments.sublist(existingPaymentIndex + 1)
      ];
      state = List.from(_allPayments);
    } else {
      final newPayment = Payment(
        id: generateId(),
        invoiceNo: invoiceNo,
        amount: amount,
        paymentDate: paymentDate,
        paymentMode: paymentMode,
        chequeNo: paymentMode == PaymentMode.cheque ? chequeNo : null,
      );
      _allPayments = [..._allPayments, newPayment];
      state = List.from(_allPayments);
    }
  }

  String generateId() {
    int newId = int.parse(state[state.length - 1].id) + 1;
    return "$newId";
  }

  void searchPayment(String q) {
    if (q.isNotEmpty) {
      var startsWith = _allPayments
          .where((p) =>
              ("${p.amount}".startsWith(q)) ||
              ("${p.paymentDate?.year}".startsWith(q)) ||
              ("${p.paymentDate?.month}".startsWith(q)) ||
              ("${p.paymentDate?.day}".startsWith(q)) ||
              (p.paymentMode.toString().startsWith(q)))
          .toList();
      var contains = _allPayments
          .where((p) =>
              (("${p.amount}".contains(q)) && (!"${p.amount}".startsWith(q))) ||
              (("${p.paymentDate?.year}".contains(q)) &&
                  (!"${p.paymentDate?.year}".startsWith(q))) ||
              (("${p.paymentDate?.month}".contains(q)) &&
                  (!"${p.paymentDate?.month}".startsWith(q))) ||
              (("${p.paymentDate?.day}".contains(q)) &&
                  (!"${p.paymentDate?.day}".startsWith(q))) ||
              ((p.paymentMode.toString().contains(q)) &&
                  (!p.paymentMode.toString().startsWith(q))))
          .toList();

      state = [...startsWith, ...contains];
    } else {
      state = _allPayments;
    }
  }
}

final paymentNotifierProvider =
    NotifierProvider<PaymentNotifier, List<Payment>>(() => PaymentNotifier());
