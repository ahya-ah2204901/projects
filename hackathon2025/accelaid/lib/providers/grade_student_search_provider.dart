import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradeStudentSearchProvider extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setSearch(String s) {
    state = s;
  }
}

final gradeStudentSearchNotifierProvider =
    NotifierProvider<GradeStudentSearchProvider, String>(
        () => GradeStudentSearchProvider());
