import 'package:floor/floor.dart';

@Entity(tableName: 'returnReasons')
class ReturnReason {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String reason;

  ReturnReason({this.id, required this.reason});
}
