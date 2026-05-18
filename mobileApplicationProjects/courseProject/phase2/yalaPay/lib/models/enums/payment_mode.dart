import 'package:floor/floor.dart';

@Entity(tableName: 'paymentModes')
class PaymentMode {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String mode;

  PaymentMode({this.id, required this.mode});
}
