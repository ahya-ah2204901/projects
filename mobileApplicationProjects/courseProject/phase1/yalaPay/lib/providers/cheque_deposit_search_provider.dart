import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChequeDepositSearchProvider extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setSearch(String s) {
    state = s;
  }
}

final chequeDepositSearchNotifierProvider =
    NotifierProvider<ChequeDepositSearchProvider, String>(
        () => ChequeDepositSearchProvider());
