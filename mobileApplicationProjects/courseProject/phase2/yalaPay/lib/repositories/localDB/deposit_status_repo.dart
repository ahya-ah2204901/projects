import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';

import '../../database/deposit_status_dao.dart';

class DepositStatusRepo {
  final DepositStatusDao depositStatusDao;

  DepositStatusRepo({required this.depositStatusDao});

  /// initialize deposit statuses
  Future<void> initializeData() async {
    final existingDepositStatuses = await depositStatusDao.getDepositStatuses();
    if (existingDepositStatuses.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/deposit-status.json');
        final List<dynamic> depositStatusList = jsonDecode(jsonData);
        for (var status in depositStatusList) {
          final depositStatus = DepositStatus(status: status as String);
          await depositStatusDao.addDepositStatus(depositStatus);
        }
        print('Successfully loaded deposit status');
      } on Exception catch (e) {
        print('Error initializing deposit statuses: $e');
      }
    }
  }

  /// get all deposit statuses
  Future<List<String>> getDepositStatuses() =>
      depositStatusDao.getDepositStatuses();
}
