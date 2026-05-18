import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/database/bank_account_dao.dart';
import 'package:yala_pay/models/enums/bank_account.dart';

class BankAccountRepo {
  final BankAccountDao bankAccountDao;

  BankAccountRepo({required this.bankAccountDao});

  /// initialize bank accounts
  Future<void> initializeData() async {
    final existingBankAccounts = await bankAccountDao.getBankAccounts();
    if (existingBankAccounts.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/bank-accounts.json');
        final List<dynamic> bankAccountList = jsonDecode(jsonData);
        for (var bankAccountMap in bankAccountList) {
          final bankAccount = BankAccount(
            accountNo: bankAccountMap['accountNo'] as String,
            bankName: bankAccountMap['bank'] as String,
          );
          await bankAccountDao.addBankAccount(bankAccount);
        }
        print('Successfully loaded bank accounts');
      } on Exception catch (e) {
        print('Error initializing bank accounts: $e');
      }
    }
  }

  /// get all bank accounts
  Future<List<BankAccount>> getBankAccounts() =>
      bankAccountDao.getBankAccounts();
}
