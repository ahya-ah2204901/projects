import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';
import 'package:yala_pay/providers/payment_search_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/comfirm_deletion_dialog.dart';

// original class commented out at the bottom

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
    final searchProvider = ref.watch(paymentSearchNotifierProvider);
    final searchNotifier = ref.read(paymentSearchNotifierProvider.notifier);
    final chequesProvider = ref.watch(chequeNotifierProvider);

    final chequesValidation = chequesProvider.when(
        data: (cheques) {
          return cheques.isEmpty ? SizedBox() : SizedBox();
        },
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')),
        loading: () => const Center(child: CircularProgressIndicator()));

    List<Cheque> chequesList = chequesProvider.when(
        data: (cheques) => cheques,
        error: (error, stack) => [],
        loading: () => []);

    final payments = ref.watch(paymentNotifierProvider);

    final paymentsNotifier = ref.watch(paymentNotifierProvider.notifier);

    final validPayments = chequesProvider.when(
        data: (chequesData) {
          return payments.when(
              data: (paymentsData) {
                final filteredPayments = paymentsData.where((payment) {
                  if (widget.invoiceId == payment.invoiceNo) {
                    if (payment.paymentMode == 'Cheque' ||
                        payment.paymentMode == 'cheque') {
                      final cheque = chequesData.firstWhere(
                          (c) => c.chequeNo == payment.chequeNo,
                          orElse: () => Cheque(bankName: ''));
                      return cheque.status != 'Returned' &&
                          cheque.status != 'Returned'.toLowerCase();
                    }
                    return true;
                  }
                  return false;
                }).toList();
                return filteredPayments;
              },
              error: (error, stack) => [],
              loading: () => []);
        },
        error: (error, stack) => [],
        loading: () => []);

    final invoicesProvider = ref.watch(invoiceNotifierProvider);

    return invoicesProvider.when(
        data: (invoices) {
          final isSearchEmpty = searchProvider.isEmpty;
          final invoice = invoices.firstWhere(
              (inv) => inv.id == widget.invoiceId,
              orElse: () => Invoice());
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
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                            _buildDetailColumn(
                                "Customer Id", invoice.customerId),
                            _buildDetailColumn(
                                "Customer Name", invoice.customerName),
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
                                final balance = invoice.amount -
                                    validPayments.fold(0.0,
                                        (sum, payment) => sum + payment.amount);
                                if (balance > 0) {
                                  context.pushNamed(
                                      AppRouter.paymentAddUpdate.name,
                                      pathParameters: {
                                        'paymentId': '-1',
                                        'invoiceId': widget.invoiceId
                                      });
                                }
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
                          initialValue: searchProvider,
                          onChanged: (s) {
                            searchNotifier.setSearch(s);
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
                    child: isSearchEmpty
                        ? payments.when(
                            data: (paymentsData) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...paymentsData
                                      .where((payment) =>
                                          payment.invoiceNo == widget.invoiceId)
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final payment = entry.value;
                                    return GestureDetector(
                                      onTap: () {
                                        context.pushNamed(
                                            AppRouter.paymentDetails.name,
                                            pathParameters: {
                                              'invoiceId': widget.invoiceId,
                                              'paymentId': payment.id
                                            });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Card(
                                          child: ListTile(
                                            title: Text(
                                              "Payment No.: ${index + 1}",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: Text(
                                                    "Payment Amount: ${payment.amount}",
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: Text(
                                                    "Payment Date: ${payment.paymentDate?.year}-${payment.paymentDate?.month}-${payment.paymentDate?.day}",
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: Text(
                                                    'Payment Mode: ${payment.paymentMode}',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                                if (payment.paymentMode ==
                                                        'Cheque' ||
                                                    payment.paymentMode ==
                                                        'cheque')
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                        "Cheque status: ${chequesList.firstWhere((c) => c.chequeNo == payment.chequeNo.toString(), orElse: () => Cheque(bankName: '')).status}"),
                                                  ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              onPressed: () => showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ConfirmDeletionDialog(
                                                    onDelete: () {
                                                      ref
                                                          .read(
                                                              paymentNotifierProvider
                                                                  .notifier)
                                                          .deletePayment(
                                                              payment);
                            
                                                       ref.read(chequeNotifierProvider.notifier).deleteCheque(payment.chequeNo!);       
                                                    },
                                                  );
                                                },
                                              ),
                                              icon: const Icon(
                                                  CupertinoIcons.trash),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    return const SizedBox();
                                  }),
                                ],
                              );
                            },
                            error: (error, stack) => Center(
                                child: Text('Error: ${error.toString()}')),
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                          )
                        : StreamBuilder<List<Payment>>(
                            stream:
                                paymentsNotifier.searchPayment(searchProvider),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              final filteredPayments = snapshot.data
                                      ?.where((payment) =>
                                          payment.invoiceNo == widget.invoiceId)
                                      .toList() ??
                                  [];
                              return SizedBox(
                                width: double.infinity,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filteredPayments.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final payment = filteredPayments[index];
                                      return GestureDetector(
                                        onTap: () {
                                          context.pushNamed(
                                              AppRouter.paymentDetails.name,
                                              pathParameters: {
                                                'invoiceId': widget.invoiceId,
                                                'paymentId': payment.id
                                              });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Card(
                                            child: ListTile(
                                              title: Text(
                                                "Payment No.: ${index + 1}",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      "Payment Amount: ${payment.amount}",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      "Payment Date: ${payment.paymentDate?.year}-${payment.paymentDate?.month}-${payment.paymentDate?.day}",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      'Payment Mode: ${payment.paymentMode}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  if (payment.paymentMode ==
                                                          'Cheque' ||
                                                      payment.paymentMode ==
                                                          'cheque')
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                          "Cheque status: ${chequesList.firstWhere((c) => c.chequeNo == payment.chequeNo.toString(), orElse: () => Cheque(bankName: '')).status}"),
                                                    ),
                                                ],
                                              ),
                                              trailing: IconButton(
                                                onPressed: () => showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ConfirmDeletionDialog(
                                                      onDelete: () {
                                                        ref
                                                            .read(
                                                                paymentNotifierProvider
                                                                    .notifier)
                                                            .deletePayment(
                                                                payment);
                                                      },
                                                    );
                                                  },
                                                ),
                                                icon: const Icon(
                                                    CupertinoIcons.trash),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            }),
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
