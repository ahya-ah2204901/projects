import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/widgets/cheque_info_in_payments_details.dart';

class ChequeDetailsScreen extends ConsumerStatefulWidget {
  final int chequeNo;

  const ChequeDetailsScreen({super.key, required this.chequeNo});

  @override
  ConsumerState<ChequeDetailsScreen> createState() =>
      _ChequeDetailsScreenState();
}

class _ChequeDetailsScreenState extends ConsumerState<ChequeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final chequeNo = widget.chequeNo;
    // ignore: unused_local_variable
    final cheques = ref.watch(chequeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: const Text("Cheque Details"),
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
                    "Cheque No.: $chequeNo",
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Cheque Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ChequeInfo(chequeNo: chequeNo)
          ],
        ),
      ),
    );
  }
}
