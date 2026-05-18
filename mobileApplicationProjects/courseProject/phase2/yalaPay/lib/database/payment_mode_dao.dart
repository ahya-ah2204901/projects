import 'package:floor/floor.dart';

import '../models/enums/payment_mode.dart';

@dao
abstract class PaymentModeDao {
  /// add a payment mode to db
  @insert
  Future<void> addPaymentMode(PaymentMode paymentMode);

  /// get all payment modes
  @Query('SELECT mode FROM paymentModes')
  Future<List<String>> getPaymentModes();
}
