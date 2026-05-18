import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/routes/app_router.dart';

class ChequeInfo extends ConsumerStatefulWidget {
  final int? chequeNo;
  const ChequeInfo({super.key, required this.chequeNo});

  @override
  ConsumerState<ChequeInfo> createState() => _ChequeInfoState();
}

class _ChequeInfoState extends ConsumerState<ChequeInfo> {
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
    final cheques = ref.watch(chequeNotifierProvider);
    if (cheques.isEmpty) return const SizedBox();
    final cheque = cheques.firstWhere((ch) => ch.chequeNo == widget.chequeNo);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailColumn("Cheque No.", cheque.chequeNo.toString()),
                _buildDetailColumn("Amount", cheque.amount.toString()),
                _buildDetailColumn("Drawer", cheque.drawer),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Bank Name",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  switch (cheque.bankName) {
                    Bank.QatarNationalBank => "Qatar National Bank",
                    Bank.DohaBank => "Doha Bank",
                    Bank.CommercialBank => "Commercial Bank",
                    Bank.QatarInternationalIslamicBank =>
                      "Qatar International Islamic Bank",
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
                    Bank.InternationalBankofQatar =>
                      "International Bank of Qatar",
                    Bank.BarwaBank => "Barwa Bank",
                  },
                  style: const TextStyle(fontSize: 14),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Status",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  switch (cheque.status) {
                    ChequeStatus.all => "All",
                    ChequeStatus.awaiting => "Awaiting",
                    ChequeStatus.cashed => "Cashed",
                    ChequeStatus.deposited => "Deposited",
                    ChequeStatus.returned => "Returned",
                  },
                  style: const TextStyle(fontSize: 14),
                ),
                _buildDetailColumn("Received Date",
                    "${cheque.receivedDate?.year}-${cheque.receivedDate?.month}-${cheque.receivedDate?.day}"),
                _buildDetailColumn("Due Date",
                    "${cheque.dueDate?.year}-${cheque.dueDate?.month}-${cheque.dueDate?.day}"),
                if (cheque.cashedDate != null)
                  _buildDetailColumn("Cashed Date",
                      "${cheque.cashedDate?.year}-${cheque.cashedDate?.month}-${cheque.cashedDate?.day}"),
                if (cheque.returnDate != null)
                  _buildDetailColumn("Return Date",
                      "${cheque.returnDate?.year}-${cheque.returnDate?.month}-${cheque.returnDate?.day}"),
                if (cheque.returnReason != null)
                  _buildDetailColumn("Return Reason",
                      Cheque.getReturnReasonString(cheque.returnReason!)),
                if (cheque.chequeImageUri != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Text(
                          "Image",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Expanded(child: SizedBox()),
                        TextButton(
                          onPressed: () {
                            context.pushNamed(AppRouter.chequeImage.name,
                                pathParameters: {
                                  'chequeUri': cheque.chequeImageUri ?? ''
                                });
                          },
                          child: const Text(
                            "view image",
                            style: TextStyle(
                                color: Color.fromARGB(255, 10, 81, 140)),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
