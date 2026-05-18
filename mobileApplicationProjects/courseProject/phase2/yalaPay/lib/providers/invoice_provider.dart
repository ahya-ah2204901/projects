import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/invoice_repo.dart';

class InvoiceNotifier extends AsyncNotifier<List<Invoice>> {
  late final InvoiceRepo _invoiceRepo;

  @override
  Future<List<Invoice>> build() async {
    _invoiceRepo = await ref.watch(invoiceRepoProvider.future);
    await _invoiceRepo.initializeInvoices();
    _invoiceRepo.observeInvoices().listen((invoices) {
      state = AsyncValue.data(invoices);
    }).onError((e) {
      print('Error building invoice provider: $e');
    });
    return [];
  }

  //add and update
  Future<void> addUpdateInvoice(Invoice invoice) async {
    await _invoiceRepo.addUpdateInvoice(invoice);
  }

  //delete
  Future<void> deleteInvoice(Invoice invoice) async {
    await _invoiceRepo.deleteInvoice(invoice);
  }

  //search
  Stream<List<Invoice>> searchInvoice(String q) {
    return _invoiceRepo.searchInvoice(q);
  }

  //get by ID
  Future<Invoice?> getInvoiceById(String id) async {
    return _invoiceRepo.getInvoiceById(id);
  }

  Future<List<double>> totalInvoicesAllByDues() {
    return _invoiceRepo.totalInvoicesAllByDues();
  }

  Future<Map<String, dynamic>> filterInvoices(
      String startDate, String endDate, String status) async {
    return await _invoiceRepo.filterInvoices(startDate, endDate, status);
  }

  Future<double> getPendingBalance(Invoice invoice) async {
    return await _invoiceRepo.getPendingBalance(invoice);
  }
}

final invoiceNotifierProvider =
    AsyncNotifierProvider<InvoiceNotifier, List<Invoice>>(
        () => InvoiceNotifier());
