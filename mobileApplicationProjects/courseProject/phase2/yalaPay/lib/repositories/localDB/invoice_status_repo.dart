import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/database/invoice_status_dao.dart';
import 'package:yala_pay/models/enums/invoice_status.dart';

class InvoiceStatusRepo {
  final InvoiceStatusDao invoiceStatusDao;

  InvoiceStatusRepo({required this.invoiceStatusDao});

  /// initialize invoiced statuses
  Future<void> initializeData() async {
    final existingInvoiceStatuses = await invoiceStatusDao.getInvoiceStatuses();
    if (existingInvoiceStatuses.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/invoice-status.json');
        final List<dynamic> invoiceStatusList = jsonDecode(jsonData);
        for (var status in invoiceStatusList) {
          final invoiceStatus = InvoiceStatus(status: status as String);
          await invoiceStatusDao.addInvoiceStatus(invoiceStatus);
        }
        print('Successfully loaded invoice status');
      } on Exception catch (e) {
        print('Error initializing invoice statuses: $e');
      }
    }
  }

  /// get all invoice statuses
  Future<List<String>> getInvoiceStatuses() =>
      invoiceStatusDao.getInvoiceStatuses();
}
