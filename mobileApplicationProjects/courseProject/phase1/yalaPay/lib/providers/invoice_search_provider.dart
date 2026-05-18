import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoiceSearchProvider extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setSearch(String s) {
    state = s;
  }
}

final invoiceSearchNotifierProvider =
    NotifierProvider<InvoiceSearchProvider, String>(
        () => InvoiceSearchProvider());
