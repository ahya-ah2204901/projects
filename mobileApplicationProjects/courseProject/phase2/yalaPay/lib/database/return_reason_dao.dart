import 'package:floor/floor.dart';
import 'package:yala_pay/models/enums/return_reason.dart';

@dao
abstract class ReturnReasonDao {
  /// add a return reason to db
  @insert
  Future<void> addReturnReason(ReturnReason returnReason);

  /// get all return reasons
  @Query('SELECT reason FROM returnReasons')
  Future<List<String>> getReturnReasons();
}
