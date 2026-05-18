import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/providers/invoice_search_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/invoice_tile.dart';

import '../providers/invoice_provider.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final searchProvider = ref.watch(invoiceSearchNotifierProvider);
    final searchNotifier = ref.read(invoiceSearchNotifierProvider.notifier);
    final invoices = ref.watch(invoiceNotifierProvider);
    final invoicesNotifier = ref.read(invoiceNotifierProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: searchProvider,
                  onChanged: (s) {
                    searchNotifier.setSearch(s);
                    invoicesNotifier.searchInvoice(s);
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    labelText: "Search Invoices",
                    prefixIconColor: primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: SizedBox(
                  width: 80,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 3,
                        fixedSize: const Size(10.0, 30.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      context.pushNamed(AppRouter.invoicesReport.name);
                    },
                    child: const Text(
                      "Report",
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (BuildContext context, int index) {
                final invoice = invoices[index];
                return InvoiceTile(invoice: invoice);
              },
            ),
          ),
        ],
      ),
    );
  }
}
