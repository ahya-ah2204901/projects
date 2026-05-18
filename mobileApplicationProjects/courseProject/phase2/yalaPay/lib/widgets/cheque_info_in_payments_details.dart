import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/repositories/image_repo.dart';
import 'package:yala_pay/routes/app_router.dart';

class ChequeInfo extends ConsumerStatefulWidget {
  final int? chequeNo;
  const ChequeInfo({super.key, required this.chequeNo});

  @override
  ConsumerState<ChequeInfo> createState() => _ChequeInfoState();
}

class _ChequeInfoState extends ConsumerState<ChequeInfo> {
  ImageRepository imageRepo = ImageRepository();
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
    final chequeProvider = ref.read(chequeNotifierProvider.notifier);

    final cheque = chequeProvider.findCheque(widget.chequeNo!);

    return StreamBuilder<List<Cheque>>(
      stream: chequeProvider.observeCheques(),
      builder: (context, chequeSnapshot) {
        if (chequeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (chequeSnapshot.hasError) {
          return Center(child: Text('Error: ${chequeSnapshot.error}'));
        } else if (chequeSnapshot.hasData) {
          final cheques = chequeSnapshot.data!;

          if (cheques.isEmpty) {
            return const SizedBox();
          }

          return FutureBuilder<Cheque?>(
            future: cheque,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data != null) {
                final cheque = snapshot.data!;

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
                            _buildDetailColumn(
                                "Cheque No.", cheque.chequeNo.toString()),
                            _buildDetailColumn(
                                "Amount", cheque.amount.toString()),
                            _buildDetailColumn("Drawer", cheque.drawer),
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "Bank Name",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              cheque.bankName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "Status",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              cheque.status,
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
                              _buildDetailColumn(
                                  "Return Reason", cheque.returnReason!),
                            if (cheque.chequeImageUri != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Image",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    TextButton(
                                      onPressed: () async {
                                        String uri =
                                            await imageRepo.downloadFile(
                                                cheque.chequeImageUri);
                                        context.pushNamed(
                                            AppRouter.chequeImage.name,
                                            pathParameters: {'chequeFilePath': uri});
                                      },
                                      child: const Text(
                                        "view image",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 10, 81, 140)),
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
              } else {
                return const Center(child: Text('No cheque found.'));
              }
            },
          );
        } else {
          return const Center(child: Text('No cheques available.'));
        }
      },
    );
  }
}
