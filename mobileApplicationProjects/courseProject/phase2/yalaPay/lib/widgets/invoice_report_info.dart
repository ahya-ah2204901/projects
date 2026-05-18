import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';

class InvoiceReportInfo extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  const InvoiceReportInfo(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.status});

  @override
  ConsumerState<InvoiceReportInfo> createState() => _InvoiceReportInfoState();
}

class _InvoiceReportInfoState extends ConsumerState<InvoiceReportInfo> {

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref.read(invoiceNotifierProvider.notifier).filterInvoices(
              (widget.startDate.toString()),
              (widget.endDate.toString()),
              widget.status,
            ),
        builder: (context, snapshot) {
          final filteredInvoices = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return SizedBox(
                child: Text('Cheque Report Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 75.0, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "TOTAL INVOICE AMOUNT",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${filteredInvoices!['totals']['totalAmount']} QAR",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (widget.status == 'All')
                          Row(
                            children: [
                              Text(
                                "PAID TOTAL\nUNPAID TOTAL\nPARTIALLY PAID TOTAL",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${filteredInvoices['totals']['paidTotal']} QAR\n${filteredInvoices['totals']['unpaidTotal']} QAR\n${filteredInvoices['totals']['partiallyPaidTotal']} QAR",
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        if (widget.status != 'All')
                          Row(
                            children: [
                              Text(
                                "CHOSEN STATUS INVOICES TOTAL",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const Spacer(),
                              if (widget.status == 'Unpaid')
                              Text(
                                "${filteredInvoices['totals']['unpaidTotal']} QAR",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (widget.status == 'Partially Paid')
                                Text(
                                  "${filteredInvoices['totals']['partiallyPaidTotal']} QAR",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              if (widget.status == 'Paid')
                                Text(
                                  "${filteredInvoices['totals']['paidTotal']} QAR",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                            ],
                          ),
                        Row(
                          children: [
                            Text(
                              "INVOICES COUNT",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                                "${filteredInvoices['totals']['invoiceCount']} INVOICES",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 360,
                            child: ListView.builder(
                              itemCount: filteredInvoices['filteredInvoices'].length,
                              itemBuilder: (context, index) {
                                var invoice = filteredInvoices['filteredInvoices'][index];
                                return SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailColumn(
                                              "Invoice Id", invoice.id),
                                          _buildDetailColumn("Customer Id",
                                              invoice.customerId),
                                          _buildDetailColumn("Customer Name",
                                              invoice.customerName),
                                          _buildDetailColumn(
                                              "Amount", "${invoice.amount}"),
                                          FutureBuilder<double>(
                                            future: ref
                                                .read(invoiceNotifierProvider.notifier)
                                                .getPendingBalance(invoice),
                                            builder: (context, balanceSnapshot) {
                                              if (balanceSnapshot.connectionState == ConnectionState.waiting) {
                                                return _buildDetailColumn(
                                                  "Balance Pending",
                                                  "Loading...",
                                                );
                                              } else if (balanceSnapshot.hasError) {
                                                return _buildDetailColumn(
                                                  "Balance Pending",
                                                  "Error",
                                                );
                                              } else {
                                                return _buildDetailColumn(
                                                  "Balance Pending",
                                                  "${balanceSnapshot.data} QAR",
                                                );
                                              }
                                            },
                                          ),
                                          _buildDetailColumn(
                                            "Invoice Date",
                                            "${invoice.invoiceDate?.year}-${invoice.invoiceDate?.month}-${invoice.invoiceDate?.day}",
                                          ),
                                          _buildDetailColumn(
                                            "Due Date",
                                            "${invoice.dueDate?.year}-${invoice.dueDate?.month}-${invoice.dueDate?.day}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
