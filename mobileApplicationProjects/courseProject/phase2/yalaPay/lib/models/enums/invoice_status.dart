import 'package:floor/floor.dart';

@Entity(tableName: 'invoiceStatuses')
class InvoiceStatus {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String status;

  InvoiceStatus({this.id, required this.status});
}
