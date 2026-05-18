import 'package:floor/floor.dart';
import 'package:yala_pay/models/enums/invoice_status.dart';

@dao
abstract class InvoiceStatusDao {
  /// add a invoice status to db
  @insert
  Future<void> addInvoiceStatus(InvoiceStatus invoiceStatus);

  /// get all invoice statuses
  @Query('SELECT status FROM invoiceStatuses')
  Future<List<String>> getInvoiceStatuses();
}