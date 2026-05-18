import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/method_constants.dart';
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
    final chequeDeposit = ref
        .read(chequeDepositNotifierProvider.notifier)
        .findChequeDeposit(widget.chequeDepId);
    //chequeDeposits.firstWhere((cd) => cd.id == widget.chequeDepId);
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
              child: FutureBuilder<ChequeDeposit>(
                future: chequeDeposit,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final deposit = snapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.money_dollar,
                          size: 70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Cheque Deposit Id: ${deposit.id}",
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  } else {
                    return Text('No data available');
                  }
                },
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
                  child: FutureBuilder<ChequeDeposit>(
                    future: chequeDeposit,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final deposit = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailColumn("Cheque Deposit Id", deposit.id),
                            _buildDetailColumn(
                                "Bank Account No", deposit.bankAccountNo),
                            _buildDetailColumn("Status", deposit.status),
                            _buildDetailColumn(
                              "Deposit Date",
                              "${deposit.depositDate?.year}-${deposit.depositDate?.month}-${deposit.depositDate?.day}",
                            ),
                            if (deposit.cashedDate != null)
                              _buildDetailColumn(
                                "Cashed Date",
                                "${deposit.cashedDate?.year}-${deposit.cashedDate?.month}-${deposit.cashedDate?.day}",
                              ),
                            FutureBuilder<double>(
                              future: cheques.getTotalChequeAmount(
                                  deposit.chequeNos ?? []),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  return _buildDetailColumn(
                                    "Total Amount",
                                    "${snapshot.data}",
                                  );
                                } else {
                                  return _buildDetailColumn(
                                    "Total Amount",
                                    "No data available",
                                  );
                                }
                              },
                            ),
                            StreamBuilder<List<Cheque>>(
                              stream: cheques.getAwaitingCheques(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  return _buildDetailColumn(
                                    "No. of Cheques to be deposited",
                                    "${snapshot.data!.length}",
                                  );
                                } else {
                                  return _buildDetailColumn(
                                    "No. of Cheques to be deposited",
                                    "No cheques available",
                                  );
                                }
                              },
                            )
                          ],
                        );
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    },
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
              child: FutureBuilder<ChequeDeposit>(
                future: chequeDeposit,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final chequeDeposit = snapshot.data!;

                    if (chequeDeposit.chequeNos != null &&
                        chequeDeposit.chequeNos!.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: chequeDeposit.chequeNos?.length,
                        itemBuilder: (context, index) {
                          final chequeNo = chequeDeposit.chequeNos?[index];
                          final cheque = cheques.findCheque(chequeNo);
                          return FutureBuilder<Cheque>(
                            future: cheque,
                            builder: (context, chequeSnapshot) {
                              if (chequeSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (chequeSnapshot.hasError) {
                                return Center(
                                    child:
                                        Text('Error: ${chequeSnapshot.error}'));
                              } else if (chequeSnapshot.hasData) {
                                final cheque = chequeSnapshot.data!;
                                return GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                        AppRouter.chequeDetails.name,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${cheque.drawer}\n${cheque.bankName}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'DATE RECEIVED\nDUE DATE',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: primaryColor),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0),
                                                  child: Text(
                                                    '${getStringDate(cheque.receivedDate)}\n${getStringDate(cheque.dueDate)}',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${cheque.amount} QAR',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Text(
                                                      '${cheque.status.toUpperCase()} ',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: secondaryColor,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                              } else {
                                return const Center(
                                    child:
                                        Text('No data available for cheque'));
                              }
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No cheques available'));
                    }
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
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
