import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';

import '../../repositories/localDB/invoice_status_repo.dart';

class InvoiceStatusNotifier extends AsyncNotifier<List<String>> {
  InvoiceStatusRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(invoiceStatusRepoProvider.future);
    print("Fetching invoice statuses...");
    await _repo?.initializeData();
    final invoiceStatuses = await _repo?.getInvoiceStatuses();
    print("Fetched invoice statuses: $invoiceStatuses");
    return invoiceStatuses ?? [];
  }
}

final invoiceStatusNotifierProvider =
    AsyncNotifierProvider<InvoiceStatusNotifier, List<String>>(
        () => InvoiceStatusNotifier());
