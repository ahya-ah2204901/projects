import 'package:floor/floor.dart';

@Entity(tableName: 'banks')
class Bank {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String bankName;

  Bank({this.id, required this.bankName});

}
