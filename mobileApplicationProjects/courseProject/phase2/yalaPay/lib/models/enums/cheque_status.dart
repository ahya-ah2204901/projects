import 'package:floor/floor.dart';

@Entity(tableName: 'chequeStatuses')
class ChequeStatus {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String status;

  ChequeStatus({this.id, required this.status});
}
