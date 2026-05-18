import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentSearchProvider extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setSearch(String s) {
    state = s;
  }
}

final paymentSearchNotifierProvider =
    NotifierProvider<PaymentSearchProvider, String>(
        () => PaymentSearchProvider());
