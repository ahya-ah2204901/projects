import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleNotifier extends Notifier<String> {
  @override
  String build() {
    return "STARX";
  }

  void setTitle(String t) {
    state = t;
  }
}

final titleNotifierProvider = NotifierProvider<TitleNotifier, String>(
  () => TitleNotifier(),
);
