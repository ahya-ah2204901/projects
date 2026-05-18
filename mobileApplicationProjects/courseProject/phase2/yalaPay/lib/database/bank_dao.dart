import 'package:floor/floor.dart';

import '../models/enums/bank.dart';

@dao
abstract class BankDao {
  /// add a bank to db
  @insert
  Future<void> addBank(Bank bank);

  /// get all bank names
  @Query('SELECT bankName FROM banks')
  Future<List<String>> getBanks();
}
