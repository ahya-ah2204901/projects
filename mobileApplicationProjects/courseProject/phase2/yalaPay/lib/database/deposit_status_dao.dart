import 'package:floor/floor.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';

@dao
abstract class DepositStatusDao {
  /// add a deposit status to db
  @insert
  Future<void> addDepositStatus(DepositStatus depositStatus);

  /// get all deposit statuses
  @Query('SELECT status FROM depositStatuses')
  Future<List<String>> getDepositStatuses();
}
