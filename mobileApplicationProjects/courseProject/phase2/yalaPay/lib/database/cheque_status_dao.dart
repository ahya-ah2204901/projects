import 'package:floor/floor.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';

@dao
abstract class ChequeStatusDao {
  /// add a cheque status to db
  @insert
  Future<void> addChequeStatus(ChequeStatus chequeStatus);

  /// get all cheque statuses
  @Query('SELECT status FROM chequeStatuses')
  Future<List<String>> getChequeStatuses();
}
