import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/user.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/user_provider.dart';
import 'package:yala_pay/routes/app_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final user = ref.watch(userNotifierProvider);
    final invoiceProvider = ref.watch(invoiceNotifierProvider);
    final chequeProvider = ref.watch(chequeNotifierProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                width: screenSize.width,
                height: 100,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 25.0, right: 25, left: 35),
                  child: Text(
                    'Welcome back ${user?.displayName}.\nCheck your Summary to see what\nInvoices and Cheques you have missed.',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15.5,
                      letterSpacing: 0.3,
                      wordSpacing: 0.4,
                      height: 1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 200,
                  width: 400,
                  child: chequeProvider.when(
                    data: (cheques) {
                      return FutureBuilder(
                        future: ref
                            .read(chequeNotifierProvider.notifier)
                            .totalChequesOfAllStatuses(),
                        builder: (context, snapshot) {
                          List<double> totalSummary =
                              snapshot.data ?? [0, 0, 0, 0];

                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return SizedBox(
                              child: Text(
                                  'Cheque Summary Error: ${snapshot.error}'),
                            );
                          } else {
                            return Card(
                              color: primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CHEQUE SUMMARY',
                                      style: TextStyle(
                                        color: blankColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          'Awaiting\nDeposited\nCashed\nReturned',
                                          style: TextStyle(
                                            color: blankColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${totalSummary[0]}  QAR\n${totalSummary[1]}  QAR\n${totalSummary[2]}  QAR\n${totalSummary[3]}  QAR',
                                          style: TextStyle(
                                            color: blankColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                    error: (err, stack) => Center(
                      child: Text('Error: $err'),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),

              /// invoice card
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 200,
                  width: 400,
                  child: invoiceProvider.when(
                    data: (invoices) {
                      return FutureBuilder(
                        future: ref
                            .read(invoiceNotifierProvider.notifier)
                            .totalInvoicesAllByDues(),
                        builder: (context, snapshot) {
                          List<double> totalSummary =
                              snapshot.data ?? [0.0, 0.0, 0.0];

                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const SizedBox(
                              child: Text(
                                  'Invoice Summary Error: \${snapshot.error}'),
                            );
                          } else {
                            return Card(
                              color: primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INVOICE SUMMARY',
                                      style: TextStyle(
                                        color: blankColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          'Overall Invoices Due\nDue in 30 days\nDue in 60 days',
                                          style: TextStyle(
                                            color: blankColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${totalSummary[0]}  QAR\n${totalSummary[1]}  QAR\n${totalSummary[2]}  QAR',
                                          style: TextStyle(
                                            color: blankColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                    error: (err, stack) => const Center(
                      child: Text('Error: \$err'),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// widget
}
