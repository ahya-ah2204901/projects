import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/routes/app_router.dart';


class ChequeTile extends ConsumerStatefulWidget {
  final Cheque cheque;
  const ChequeTile({super.key, required this.cheque});

  @override
  ConsumerState<ChequeTile> createState() => _ChequeTileState();
}

class _ChequeTileState extends ConsumerState<ChequeTile> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final cheques = ref.read(chequeNotifierProvider.notifier);
    // ignore: unused_local_variable
    final chequeProvider = ref.watch(chequeNotifierProvider);
    var cheque = widget.cheque;
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.chequeDetails.name,
            pathParameters: {'chequeNo': cheque.chequeNo.toString()});
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text('No. ${cheque.chequeNo}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: primaryColor)),
                ],
              ),
              Text(
                '${cheque.drawer}\n${cheque.bankName}',
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
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
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '${getStringDate(cheque.receivedDate)}\n${getStringDate(cheque.dueDate)}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${cheque.amount} QAR',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${cheque.status.toUpperCase()} ',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String getStringDate(DateTime? date) {
    return (date == null) ? '' : '${date.year}-${date.month}-${date.day}';
  }
}
