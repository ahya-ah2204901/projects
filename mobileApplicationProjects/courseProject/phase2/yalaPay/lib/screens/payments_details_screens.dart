import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/providers/payment_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/cheque_info_in_payments_details.dart';

class PaymentDetailsScreen extends ConsumerStatefulWidget {
  final String paymentId;
  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PaymentDetailsScreen> createState() =>
      _PaymentDetailsScreenState();
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

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentsProv = ref.watch(paymentNotifierProvider);
    return paymentsProv.when(
        data: (payments) {
          final payment = payments.firstWhere((p) => p.id == widget.paymentId);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(CupertinoIcons.back),
              ),
              title: const Text("Payment Details"),
              actions: [
                IconButton(
                    onPressed: () {
                      context.pushNamed(AppRouter.paymentAddUpdate.name,
                          pathParameters: {
                            'paymentId': widget.paymentId,
                            'invoiceId': payment.invoiceNo
                          });
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
                          CupertinoIcons.money_dollar,
                          size: 70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Payment ID.: ${payment.id}",
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Payment Info",
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
                                "Invoice No.", payment.invoiceNo),
                            _buildDetailColumn(
                                "Amount", payment.amount.toString()),
                            _buildDetailColumn("Payment Date",
                                "${payment.paymentDate?.year}-${payment.paymentDate?.month}-${payment.paymentDate?.day}"),
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "Payment Mode",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              payment.paymentMode,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (payment.paymentMode == 'Cheque' &&
                      payment.chequeNo != null)
                    ChequeInfo(chequeNo: payment.chequeNo)
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
