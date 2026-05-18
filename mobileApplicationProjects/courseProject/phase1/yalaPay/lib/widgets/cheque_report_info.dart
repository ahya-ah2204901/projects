import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';

import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/widgets/cheque_tile.dart';

class ChequeReportInfo extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const ChequeReportInfo(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.status});

  @override
  ConsumerState<ChequeReportInfo> createState() => _ChequeReportInfoState();
}

class _ChequeReportInfoState extends ConsumerState<ChequeReportInfo> {
  List<Cheque> filteredCheques() {
    final ChequeStatus status =
        ChequeStatus.values.firstWhere((st) => st.name == widget.status);
    final List<Cheque> cheques =
        ref.read(chequeNotifierProvider.notifier).filterByStatus(status);
    return cheques
        .where((c) =>
            (c.dueDate!.isAfter(widget.startDate) ||
                c.dueDate!.isAtSameMomentAs(widget.startDate)) &&
            (c.dueDate!.isBefore(widget.endDate) ||
                c.dueDate!.isAtSameMomentAs(widget.endDate)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Cheque> chequesFiltered =
        (widget.status.isEmpty) ? [] : filteredCheques();
    double totalAmount = chequesFiltered.fold(0, (sum, c) => sum + c.amount);
    int count = chequesFiltered.length;

    return (chequesFiltered.isEmpty)
        ? const SizedBox()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 80.0, left: 13),
                      child: Text(
                        "TOTAL AMOUNT\nCHEQUE COUNT",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ),
                    Text(
                      "$totalAmount QAR\n$count CHEQUES",
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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
                        height: 440,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return SizedBox(
                                width: double.infinity,
                                height: 150,
                                child:
                                    ChequeTile(cheque: chequesFiltered[index]));
                          },
                          itemCount: chequesFiltered.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
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
}
