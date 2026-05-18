import 'package:floor/floor.dart';

@Entity(tableName: 'depositStatuses')
class DepositStatus {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String status;

  DepositStatus({this.id, required this.status});
}
