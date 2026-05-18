import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/payment_mode.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/screens/cheque_deposit_details_screen.dart';
import 'package:yala_pay/widgets/comfirm_deletion_dialog.dart';

class InvoiceDetailsScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailsScreen> createState() =>
      _InvoiceDetailsScreenState();
}

Widget _buildDetailColumn(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}

class _InvoiceDetailsScreenState extends ConsumerState<InvoiceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final cheques = ref.watch(chequeNotifierProvider);
    if (cheques.isEmpty) return const SizedBox();
    final invoices = ref.watch(invoiceNotifierProvider);
    final invoice = invoices.firstWhere((inv) => inv.id == widget.invoiceId);
    final payments = ref
        .watch(paymentNotifierProvider)
        .where((payment) => payment.invoiceNo == invoice.id)
        .toList();
    final paymentsNotifier = ref.watch(paymentNotifierProvider.notifier);

    final validPayments = payments.where((payment) {
      if (payment.paymentMode == PaymentMode.cheque) {
        final cheque =
            cheques.firstWhere((c) => c.chequeNo == payment.chequeNo);
        return cheque.status == ChequeStatus.cashed;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: const Text("Invoice Details"),
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(AppRouter.invoiceAddUpdate.name,
                    pathParameters: {'invoiceId': widget.invoiceId});
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.rectangle_dock,
                    size: 70,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Invoice No.: ${invoice.id}",
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Invoice Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailColumn("Customer Id", invoice.customerId),
                      _buildDetailColumn("Customer Name", invoice.customerName),
                      _buildDetailColumn("Amount", "${invoice.amount}"),
                      _buildDetailColumn("Balance Pending",
                          "${invoice.amount - validPayments.fold(0.0, (sum, payment) => sum + payment.amount)}"),
                      _buildDetailColumn("Invoice Date",
                          "${invoice.invoiceDate?.year}-${invoice.invoiceDate?.month}-${invoice.invoiceDate?.day}"),
                      _buildDetailColumn("Due Date",
                          "${invoice.dueDate?.year}-${invoice.dueDate?.month}-${invoice.dueDate?.day}"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Invoice Payments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.pushNamed(AppRouter.paymentAddUpdate.name,
                              pathParameters: {
                                'paymentId': '-1',
                                'invoiceId': widget.invoiceId
                              });
                        },
                        alignment: Alignment.center,
                        icon: const Icon(CupertinoIcons.add),
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8.0),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextFormField(
                    onChanged: (s) {
                      paymentsNotifier.searchPayment(s);
                    },
                    decoration: const InputDecoration(
                      hintText: "Search",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      labelText: "Search Payments of this Invoice",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...payments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final payment = entry.value;
                    return GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRouter.paymentDetails.name,
                            pathParameters: {
                              'invoiceId': widget.invoiceId,
                              'paymentId': payment.id
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              "Payment No.: ${index + 1}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Payment Amount: ${payment.amount}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Payment Date: ${payment.paymentDate?.year}-${payment.paymentDate?.month}-${payment.paymentDate?.day}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    switch (payment.paymentMode) {
                                      PaymentMode.bankTransfer =>
                                        "Payment Mode: Bank Transfer",
                                      PaymentMode.creditCard =>
                                        "Payment Mode: Credit Card",
                                      PaymentMode.cheque =>
                                        "Payment Mode: Cheque",
                                    },
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                if (payment.paymentMode == PaymentMode.cheque)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                        "Cheque status: ${cheques.firstWhere((c) => c.chequeNo == payment.chequeNo).status.name.capitalize()}"),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ConfirmDeletionDialog(
                                    onDelete: () {
                                      ref
                                          .read(
                                              paymentNotifierProvider.notifier)
                                          .deletePayment(payment);
                                    },
                                  );
                                },
                              ),
                              icon: const Icon(CupertinoIcons.trash),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
