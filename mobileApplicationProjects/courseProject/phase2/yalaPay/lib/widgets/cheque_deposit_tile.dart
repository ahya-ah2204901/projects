import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/providers/cheque_deposit_provider.dart';
import 'package:yala_pay/providers/cheque_provider.dart';

import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/comfirm_deletion_dialog.dart';

class ChequeDepositTile extends ConsumerStatefulWidget {
  final ChequeDeposit chequeDeposit;
  const ChequeDepositTile({super.key, required this.chequeDeposit});

  @override
  ConsumerState<ChequeDepositTile> createState() => _ChequeDepositTileState();
}

class _ChequeDepositTileState extends ConsumerState<ChequeDepositTile> {
  @override
  Widget build(BuildContext context) {
    final chequeDeposits = ref.read(chequeDepositNotifierProvider.notifier);
    var chequeDeposit = widget.chequeDeposit;
    final cheques = ref.read(chequeNotifierProvider.notifier);
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.chequeDepositDetails.name,
            pathParameters: {'chequeDepId': chequeDeposit.id});
      },
      child: Card(
        child: ListTile(
          leading: const Column(
            children: [
              Icon(
                CupertinoIcons.money_dollar,
                size: 25,
              ),
            ],
          ),
          title: Text(
            "BANK ACCOUNT NO: ${chequeDeposit.bankAccountNo}",
            style: const TextStyle(fontSize: 12),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      "DEPOSIT DATE : \nNO. OF CHEQUES : \nTOTAL AMOUNT   : ",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: primaryColor),
                    ),
                    const Spacer(),
                    FutureBuilder<double>(
                      future: cheques
                          .getTotalChequeAmount(chequeDeposit.chequeNos ?? []),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading...',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.end);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}',
                              style: const TextStyle(fontSize: 15),
                              textAlign: TextAlign.end);
                        } else if (snapshot.hasData) {
                          return Text(
                            "${chequeDeposit.depositDate?.year}-${chequeDeposit.depositDate?.month}-${chequeDeposit.depositDate?.day}\n${chequeDeposit.chequeNos?.length}\n${snapshot.data} QAR",
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.end,
                          );
                        } else {
                          return const Text('No data available',
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.end);
                        }
                      },
                    ),
                  ],
                ),
                Text(
                  chequeDeposit.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ),
          trailing: //Column(
              //children: [
              IconButton(
                  onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmDeletionDialog(
                            onDelete: () {
                              chequeDeposits.deleteChequeDeposit(chequeDeposit);
                              cheques.updateChequeListStatus(
                                  chequeDeposit.chequeNos ?? [], 'Awaiting');
                            },
                          );
                        },
                      ),
                  icon: const Icon(CupertinoIcons.trash)),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
