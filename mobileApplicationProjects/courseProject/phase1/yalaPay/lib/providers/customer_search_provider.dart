import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerSearchProvider extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setSearch(String s) {
    state = s;
  }
}

final customerSearchNotifierProvider =
    NotifierProvider<CustomerSearchProvider, String>(
        () => CustomerSearchProvider());
