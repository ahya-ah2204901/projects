import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/method_constants.dart';
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref.read(chequeNotifierProvider.notifier).filterCheques(
             widget.startDate.toString(),
              widget.endDate.toString(),
              widget.status,
            ),
        builder: (context, snapshot) {
          final filteredCheques = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return SizedBox(
                child: Text('Cheque Report Error: ${snapshot.error}'));
          } else {
            double totalAmount =
                filteredCheques!.fold(0, (sum, c) => sum + c.amount);
            int count = filteredCheques.length;

            return (filteredCheques.isEmpty)
                ? const SizedBox()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 80.0, left: 13),
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
                                        child: ChequeTile(
                                            cheque: filteredCheques[index]));
                                  },
                                  itemCount: filteredCheques.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          }
        });
  }


  String getStringDate(DateTime? date) {
    return (date == null) ? '' : '${date.year}-${date.month}-${date.day}';
  }
}
