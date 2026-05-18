import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/models/enums/return_reason.dart';

import '../../database/return_reason_dao.dart';

class ReturnReasonRepo {
  final ReturnReasonDao returnReasonDao;

  ReturnReasonRepo({required this.returnReasonDao});

  /// initialize return reasons
  Future<void> initializeData() async {
    final existingReturnReasons = await returnReasonDao.getReturnReasons();
    if (existingReturnReasons.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/return-reasons.json');
        final List<dynamic> returnReasonList = jsonDecode(jsonData);
        for (var reason in returnReasonList) {
          final returnReason = ReturnReason(reason: reason as String);
          await returnReasonDao.addReturnReason(returnReason);
        }
        print('Successfully loaded return reasons');
      } on Exception catch (e) {
        print('Error initializing return reasons: $e');
      }
    }
  }

  /// get all return reasons
  Future<List<String>> getReturnReasons() => returnReasonDao.getReturnReasons();
}
