import 'package:floor/floor.dart';

import '../models/enums/bank_account.dart';

@dao
abstract class BankAccountDao{
  /// add a bank account to db
  @insert
  Future<void> addBankAccount(BankAccount bankAccount);

  /// get all bank accounts
  @Query('SELECT * FROM bankAccounts')
  Future<List<BankAccount>> getBankAccounts();
}