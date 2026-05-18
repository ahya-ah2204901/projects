import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/payment_mode.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/comfirm_deletion_dialog.dart';

class InvoiceTile extends ConsumerStatefulWidget {
  final Invoice invoice;
  const InvoiceTile({super.key, required this.invoice});

  @override
  ConsumerState<InvoiceTile> createState() => _InvoiceTileState();
}

class _InvoiceTileState extends ConsumerState<InvoiceTile> {
  @override
  Widget build(BuildContext context) {
    final cheques = ref.watch(chequeNotifierProvider);
    if (cheques.isEmpty) return const SizedBox();
    final invoices = ref.watch(invoiceNotifierProvider.notifier);
    var invoice = widget.invoice;
    final payments = ref
        .watch(paymentNotifierProvider)
        .where((payment) => payment.invoiceNo == invoice.id)
        .toList();

    // ignore: unused_local_variable
    final paymentsNotifier = ref.watch(paymentNotifierProvider.notifier);

    final validPayments = payments.where((payment) {
      if (payment.paymentMode == PaymentMode.cheque) {
        final cheque =
            cheques.firstWhere((c) => c.chequeNo == payment.chequeNo);
        return cheque.status == ChequeStatus.cashed;
      }
      return true;
    }).toList();

    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.invoiceDetails.name,
            pathParameters: {'invoiceId': invoice.id});
      },
      child: Card(
        child: ListTile(
          leading: Column(
            children: [
              const Icon(
                CupertinoIcons.rectangle_dock,
                size: 25,
              ),
              Text(
                invoice.id,
                style: TextStyle(fontSize: 13, color: secondaryColor),
              )
            ],
          ),
          title: Text(
            "For: ${invoice.customerName}",
            style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: (invoice.customerName.length > 21) ? 15 : 16),
          ),
          subtitle: Row(
            children: [
              Text(
                "AMOUNT :  \nBALANCE :  \nDUE BY :  ",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: primaryColor),
              ),
              Text(
                "${invoice.amount} QAR\n${invoice.amount - validPayments.fold(0.0, (sum, payment) => sum + payment.amount)} QAR\n${invoice.dueDate?.year}-${invoice.dueDate?.month}-${invoice.dueDate?.day}",
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          trailing: IconButton(
              onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDeletionDialog(
                        onDelete: () {
                          invoices.deleteInvoice(invoice);
                        },
                      );
                    },
                  ),
              icon: const Icon(
                CupertinoIcons.trash,
                size: 22,
              )),
        ),
      ),
    );
  }
}
