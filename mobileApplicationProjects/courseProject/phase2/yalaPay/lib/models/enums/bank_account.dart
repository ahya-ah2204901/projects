import 'package:floor/floor.dart';

@Entity(tableName: 'bankAccounts')
class BankAccount {
  @PrimaryKey() // assumed not auto generated because that makes more sense
  final String accountNo;
  final String bankName;

  BankAccount({required this.accountNo, required this.bankName});
}
