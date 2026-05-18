import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/payment_mode_repo.dart';

class PaymentModeNotifier extends AsyncNotifier<List<String>> {
  PaymentModeRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(paymentModeRepoProvider.future);
    print("Fetching payment modes...");
    await _repo?.initializeData();
    final paymentModes = await _repo?.getPaymentModes();
    print("Fetched payment modes: $paymentModes");
    return paymentModes ?? [];
  }
}

final paymentModeNotifierProvider =
    AsyncNotifierProvider<PaymentModeNotifier, List<String>>(
        () => PaymentModeNotifier());
