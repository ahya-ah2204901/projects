import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/database/bank_dao.dart';

import '../../models/enums/bank.dart';

class BankRepo {
  final BankDao bankDao;

  BankRepo({required this.bankDao});

  /// initialize banks
  Future<void> initializeData() async {
    final existingBanks = await bankDao.getBanks();
    if (existingBanks.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/banks.json');
        final List<dynamic> bankList = jsonDecode(jsonData);
        for (var bankName in bankList) {
          final bank = Bank(bankName: bankName);
          await bankDao.addBank(bank);
        }
        print('Successfully loaded banks');
      } on Exception catch (e) {
        print('Error initializing banks: $e');
      }
    }
  }

  /// get all banks
  Future<List<String>> getBanks() => bankDao.getBanks();
}
