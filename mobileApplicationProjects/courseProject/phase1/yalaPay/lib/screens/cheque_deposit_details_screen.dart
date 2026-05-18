import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';
import 'package:yala_pay/providers/cheque_deposit_provider.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/routes/app_router.dart';

class ChequeDepositDetailsScreen extends ConsumerStatefulWidget {
  final String chequeDepId;
  const ChequeDepositDetailsScreen({super.key, required this.chequeDepId});

  @override
  ConsumerState<ChequeDepositDetailsScreen> createState() =>
      _ChequeDepositDetailsScreenState();
}

class _ChequeDepositDetailsScreenState
    extends ConsumerState<ChequeDepositDetailsScreen> {
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
    final chequeDeposits = ref.watch(chequeDepositNotifierProvider);
    final chequeDeposit =
        chequeDeposits.firstWhere((cd) => cd.id == widget.chequeDepId);
    final cheques = ref.read(chequeNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: const Text("Cheque Deposit Details"),
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(AppRouter.chequeDepositUpdate.name,
                    pathParameters: {'chequeDepId': widget.chequeDepId});
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
                    "Cheque Deposit Id: ${chequeDeposit.id}",
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Cheque Deposit Info",
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
                      _buildDetailColumn("Cheque Deposit Id", chequeDeposit.id),
                      _buildDetailColumn(
                          "Bank Account No", chequeDeposit.bankAccountNo),
                      _buildDetailColumn(
                          "Status", getStatusString(chequeDeposit.status)),
                      _buildDetailColumn("Deposit Date",
                          "${chequeDeposit.depositDate?.year}-${chequeDeposit.depositDate?.month}-${chequeDeposit.depositDate?.day}"),
                      if (chequeDeposit.cashedDate != null)
                        _buildDetailColumn("Cashed Date",
                            "${chequeDeposit.cashedDate?.year}-${chequeDeposit.cashedDate?.month}-${chequeDeposit.cashedDate?.day}"),
                      _buildDetailColumn(
                          "Total Amount",
                          cheques
                              .getTotalChequeAmount(
                                  chequeDeposit.chequeNos ?? [])
                              .toString()),
                      _buildDetailColumn("No. of Cheques to be deposited",
                          (cheques.getAwaitingCheques().length).toString()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Cheques Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: chequeDeposit.chequeNos != null &&
                      chequeDeposit.chequeNos!.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: chequeDeposit.chequeNos?.length,
                      itemBuilder: (context, index) {
                        final chequeNo = chequeDeposit.chequeNos?[index];
                        final cheque = cheques.findCheque(chequeNo);
                        return GestureDetector(
                          onTap: () {
                            context.pushNamed(AppRouter.chequeDetails.name,
                                pathParameters: {
                                  'chequeNo': cheque.chequeNo.toString()
                                });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                title: Row(
                                  children: [
                                    const Spacer(),
                                    Text('No. ${cheque.chequeNo}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: primaryColor)),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${cheque.drawer}\n${getBankName(cheque.bankName)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'DATE RECEIVED\nDUE DATE',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            '${getStringDate(cheque.receivedDate)}\n${getStringDate(cheque.dueDate)}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${cheque.amount} QAR',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '${cheque.status.name.toUpperCase()} ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: secondaryColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No cheques available')),
            ),
          ],
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

String getStringDate(DateTime? date) {
  return (date == null) ? '' : '${date.year}-${date.month}-${date.day}';
}

String getBankName(Bank bank) {
  return switch (bank) {
    Bank.QatarNationalBank => "Qatar National Bank",
    Bank.DohaBank => "Doha Bank",
    Bank.CommercialBank => "Commercial Bank",
    Bank.QatarInternationalIslamicBank => "Qatar International Islamic Bank",
    Bank.QatarIslamicBank => "Qatar Islamic Bank",
    Bank.QatarDevelopmentBank => "Qatar Development Bank",
    Bank.ArabBank => "Arab Bank",
    Bank.Ahlibank => "Ahli bank",
    Bank.MashreqBank => "Mashreq Bank",
    Bank.HSBCBankMiddleEast => "HSBC Bank Middle East",
    Bank.BNPParibas => "BNP Paribas",
    Bank.BankSaderatIran => "Bank Saderat Iran",
    Bank.UnitedBankltd => "United Bank ltd.",
    Bank.StandardCharteredBank => "Standard Chartered Bank",
    Bank.MasrafAlRayan => "Masraf Al Rayan",
    Bank.InternationalBankofQatar => "International Bank of Qatar",
    Bank.BarwaBank => "Barwa Bank",
  };
}

String getStatusString(DepositStatus depositStatus) {
  switch (depositStatus) {
    case DepositStatus.cashed:
      return 'Cashed';
    case DepositStatus.cashedwithReturns:
      return 'Cashed with Returns';
    case DepositStatus.deposited:
      return 'Deposited';
  }
}
