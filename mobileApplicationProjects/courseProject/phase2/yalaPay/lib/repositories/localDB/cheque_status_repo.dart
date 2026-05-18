import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/database/cheque_status_dao.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';

class ChequeStatusRepo {
  final ChequeStatusDao chequeStatusDao;

  ChequeStatusRepo({required this.chequeStatusDao});

  /// initialize cheque statuses
  Future<void> initializeData() async {
    final existingChequeStatuses = await chequeStatusDao.getChequeStatuses();
    if (existingChequeStatuses.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/cheque-status.json');
        final List<dynamic> chequeStatusList = jsonDecode(jsonData);
        for (var status in chequeStatusList) {
          final chequeStatus = ChequeStatus(status: status as String);
          await chequeStatusDao.addChequeStatus(chequeStatus);
        }
        print('Successfully loaded cheque status');
      } on Exception catch (e) {
        print('Error initializing cheque statuses: $e');
      }
    }
  }

  /// get all cheque statuses
  Future<List<String>> getChequeStatuses() =>
      chequeStatusDao.getChequeStatuses();
}
