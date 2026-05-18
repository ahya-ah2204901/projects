import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/invoice_status.dart';
import 'package:yala_pay/models/enums/payment_mode.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';

class InvoiceReportInfo extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final InvoiceStatus status;
  const InvoiceReportInfo(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.status});

  @override
  ConsumerState<InvoiceReportInfo> createState() => _InvoiceReportInfoState();
}

class _InvoiceReportInfoState extends ConsumerState<InvoiceReportInfo> {
  double totalAmount = 0.0;
  double grandTotalAmount = 0.0;

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

  List<Invoice> findInvoicesByStatus(
      InvoiceStatus status, List<Invoice> invoices, List<Payment> payments) {
    List<Invoice> filteredinvoices = [];
    if (status == InvoiceStatus.paid) {
      for (var invoice in invoices) {
        List<Payment> thisPayments = payments
            .where((payment) => payment.invoiceNo == invoice.id)
            .toList();
        if (thisPayments.fold(0.0, (sum, payment) => sum + payment.amount) ==
            invoice.amount) {
          filteredinvoices.add(invoice);
        }
      }
    }
    if (status == InvoiceStatus.partiallyPaid) {
      for (var invoice in invoices) {
        List<Payment> thisPayments = payments
            .where((payment) => payment.invoiceNo == invoice.id)
            .toList();
        if (thisPayments.fold(0.0, (sum, payment) => sum + payment.amount) <
                invoice.amount &&
            thisPayments.fold(0.0, (sum, payment) => sum + payment.amount) !=
                0) {
          filteredinvoices.add(invoice);
        }
      }
    }
    if (status == InvoiceStatus.unpaid) {
      for (var invoice in invoices) {
        List<Payment> thisPayments = payments
            .where((payment) => payment.invoiceNo == invoice.id)
            .toList();
        if (thisPayments.isEmpty) {
          filteredinvoices.add(invoice);
        }
      }
    }
    if (status == InvoiceStatus.all) return invoices;
    return filteredinvoices;
  }

  List<Invoice> findInvoicesInRange(List<Invoice> invoices) {
    List<Invoice> filteredinvoices = [];
    for (var invoice in invoices) {
      if ((invoice.dueDate!.isAfter(widget.startDate) ||
              invoice.dueDate!.isAtSameMomentAs(widget.startDate)) &&
          (invoice.dueDate!.isBefore(widget.endDate) ||
              invoice.dueDate!.isAtSameMomentAs(widget.endDate))) {
        filteredinvoices.add(invoice);
      }
    }
    return filteredinvoices;
  }

  List<Payment> validPayments(List<Payment> payments, List<Cheque> cheques) {
    return payments.where((payment) {
      if (payment.paymentMode == PaymentMode.cheque) {
        final cheque =
            cheques.firstWhere((c) => c.chequeNo == payment.chequeNo);
        return cheque.status == ChequeStatus.deposited;
      }
      return true;
    }).toList();
  }

  double findTotalamount(InvoiceStatus status, List<Payment> payments,
      List<Cheque> cheques, List<Invoice> invoices) {
    return findInvoicesInRange(findInvoicesByStatus(
            status, invoices, validPayments(payments, cheques)))
        .fold(0.0, (sum, invoice) => sum + invoice.amount);
  }

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoiceNotifierProvider);
    final payments = ref.watch(paymentNotifierProvider);
    final cheques = ref.watch(chequeNotifierProvider);
    if (cheques.isEmpty) return const SizedBox();

    setState(() {
      grandTotalAmount = findInvoicesInRange(findInvoicesByStatus(
              InvoiceStatus.all, invoices, validPayments(payments, cheques)))
          .fold(0.0, (sum, invoice) => sum + invoice.amount);
    });
    setState(() {
      totalAmount = findInvoicesInRange(findInvoicesByStatus(
              widget.status, invoices, validPayments(payments, cheques)))
          .fold(0.0, (sum, invoice) => sum + invoice.amount);
    });

    var invoicesFiltered = findInvoicesInRange(findInvoicesByStatus(
        widget.status, invoices, validPayments(payments, cheques)));

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
                      "${grandTotalAmount} QAR",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (widget.status == InvoiceStatus.all)
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
                        "${findTotalamount(InvoiceStatus.paid, payments, cheques, invoices)} QAR\n${findTotalamount(InvoiceStatus.unpaid, payments, cheques, invoices)} QAR\n${findTotalamount(InvoiceStatus.partiallyPaid, payments, cheques, invoices)} QAR",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                if (widget.status != InvoiceStatus.all)
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
                      Text(
                        "$totalAmount QAR",
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
                        "${findInvoicesInRange(findInvoicesByStatus(widget.status, invoices, validPayments(payments, cheques))).length} INVOICES",
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
                      itemCount: invoicesFiltered.length,
                      itemBuilder: (context, index) {
                        var invoice = invoicesFiltered[index];
                        return SizedBox(
                          width: double.infinity,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailColumn("Invoice Id", invoice.id),
                                  _buildDetailColumn(
                                      "Customer Id", invoice.customerId),
                                  _buildDetailColumn(
                                      "Customer Name", invoice.customerName),
                                  _buildDetailColumn(
                                      "Amount", "${invoice.amount}"),
                                  _buildDetailColumn(
                                    "Balance Pending",
                                    "${invoice.amount - validPayments(payments, cheques).where((payment) => payment.invoiceNo == invoice.id).fold(0.0, (sum, payment) => sum + payment.amount)}",
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
}
