import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/payment_repo.dart';



class PaymentNotifier extends AsyncNotifier<List<Payment>> {
  late final PaymentRepo _paymentRepo;

  @override
  Future<List<Payment>> build() async{
    _paymentRepo = await ref.watch(paymentRepoProvider.future);
    await _paymentRepo.initializePayments();
    _paymentRepo.observePayments().listen((payments){
      state = AsyncValue.data(payments);
    }).onError((e){
      print('Error building payments provider: $e');
    });
    return [];
  }

  Future<void> deletePayment(Payment payment) async{
    await _paymentRepo.deletePayment(payment);
  }

  Future<void> addUpdatePayment(Payment payment) async{
    await _paymentRepo.addUpdatePayment(payment);
  }

  Stream<List<Payment>> searchPayment(String q) {
    return _paymentRepo.searchPayment(q);
  }
  Future<Payment?> getPaymentById(String id) async{
    return _paymentRepo.getPaymentById(id);
  }
}

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, List<Payment>>(() => PaymentNotifier());
