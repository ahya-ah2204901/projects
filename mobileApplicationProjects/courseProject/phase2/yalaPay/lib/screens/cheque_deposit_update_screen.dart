import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';
import 'package:yala_pay/models/enums/return_reason.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/cheque_deposit_provider.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/localDB/deposit_status_provider.dart';
import 'package:yala_pay/providers/localDB/return_reason_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/screens/cheque_deposit_details_screen.dart';
import 'package:yala_pay/widgets/discard_changes_dialog.dart';

class ChequeDepositUpdateScreen extends ConsumerStatefulWidget {
  final String chequeDepId;

  const ChequeDepositUpdateScreen({super.key, required this.chequeDepId});

  @override
  ConsumerState<ChequeDepositUpdateScreen> createState() =>
      _ChequeDepositUpdateScreenState();
}

class _ChequeDepositUpdateScreenState
    extends ConsumerState<ChequeDepositUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  // ignore: unused_field
  bool _showErrors = false;

  final returnDateController = TextEditingController();
  final cashedDateController = TextEditingController();
  final statusController = TextEditingController();
  final reasonController = TextEditingController();

  //late final chequeDep;
  late final depositDate;

  //DepositStatus? selectedStatus;
  String? selectedStatus;
  //ReturnReason? selectedReason;
  String? selectedReason;

  Map<int, String> chequeStatusesMap = {};

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  Future<void> _initializeData() async {
    final depositStatusProvider =
        await ref.read(depositStatusNotifierProvider.future);

    returnDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    cashedDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    selectedStatus = "Cashed";

    final chequeDep = await ref
        .read(chequeDepositNotifierProvider.notifier)
        .findChequeDeposit(widget.chequeDepId);

    depositDate = chequeDep.depositDate;

    chequeDep.chequeNos?.forEach((chequeNo) {
      chequeStatusesMap[chequeNo] = "Cashed";
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _initializeData();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final chequeDeposits = ref.read(chequeDepositNotifierProvider.notifier);
    final returnReasonsProvider = ref.watch(returnReasonNotifierProvider);
    final cheques = ref.read(chequeNotifierProvider.notifier);
    var chequeDeposit = chequeDeposits.findChequeDeposit(widget.chequeDepId);
    final depositStatuses = ["Cashed", "CashedWithReturns"];
    final chequeStatuses = ["Cashed", "Returned"];

    bool anyReturned = chequeStatusesMap.values
        .any((status) => status.toLowerCase() == "returned");

    bool isDateWithinRange(DateTime date) {
      //final depositDate = chequeDeposit.depositDate;
      //final depositDate = chequeDep.depositDate;
      final today = DateTime.now();
      return date.isAfter(depositDate!) ||
          date.isAtSameMomentAs(depositDate) && date.isBefore(today) ||
          date.isAtSameMomentAs(today);
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DiscardChangesDialog(),
              );
            },
            icon: const Icon(CupertinoIcons.back),
          ),
          title: const Text(
            "Update Cheque Deposit Details",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: FutureBuilder<ChequeDeposit>(
                future: chequeDeposit,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final chequeDeposit = snapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFormField(
                          enabled: false,
                          initialValue: chequeDeposit.id,
                          decoration: const InputDecoration(
                            labelText: "Cheque Deposit Id",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: false,
                          initialValue:
                              "${chequeDeposit.depositDate?.year}-${chequeDeposit.depositDate?.month}-${chequeDeposit.depositDate?.day}",
                          decoration: const InputDecoration(
                            labelText: "Deposit Date",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          enabled: false,
                          initialValue: chequeDeposit.bankAccountNo,
                          decoration: const InputDecoration(
                            labelText: "Bank Account No.",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: TextFormField(
                            controller: cashedDateController,
                            decoration: const InputDecoration(
                              labelText: "Cashed Date (YYYY-MM-DD)",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.edit),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                snackbarError(
                                    context, "Cashed Date cannot be empty");
                                return "Cashed Date cannot be empty";
                              } else if (DateTime.tryParse(value) == null) {
                                snackbarError(context, "Invalid Date");
                                return "Invalid Date";
                              } else if (!isDateWithinRange(
                                  DateTime.tryParse(value) ??
                                      DateTime(DateTime.now().year + 1))) {
                                snackbarError(context, "Invalid Date");
                                return "Invalid Date";
                              } else {
                                return null;
                              }
                            },
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: chequeDeposit.depositDate ??
                                      DateTime.now(),
                                  lastDate: DateTime.now());
                              if (pickedDate != null) {
                                setState(() {
                                  cashedDateController.text =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: "Status",
                              border: OutlineInputBorder(),
                            ),
                            items: depositStatuses.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(getStatusString(status)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                                statusController.text = selectedStatus!;
                              });
                            },
                            validator: (value) =>
                                value == null ? "Please select a status" : null,
                          ),
                        ),
                        if (selectedStatus!.toLowerCase() ==
                            'cashedwithreturns') ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Cheques",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...?chequeDeposit.chequeNos?.map(
                                (chequeNo) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cheque No: $chequeNo",
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                          value: chequeStatusesMap[chequeNo],
                                          decoration: const InputDecoration(
                                            labelText: "Status",
                                            border: OutlineInputBorder(),
                                          ),
                                          items: chequeStatuses.map((status) {
                                            return DropdownMenuItem<String>(
                                              value: status,
                                              child: Text(status.capitalize()),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              chequeStatusesMap[chequeNo] =
                                                  value!;
                                            });
                                          },
                                          validator: (value) {
                                            if (selectedStatus!.toLowerCase() ==
                                                "cashedwithreturns") {
                                              if (!anyReturned) {
                                                snackbarError(context,
                                                    "At least one cheque must be returned");
                                                return 'At least one cheque must be returned';
                                              }
                                            }
                                            return value == null
                                                ? "Please select a status"
                                                : null;
                                          }),
                                      const SizedBox(height: 16),
                                      if (chequeStatusesMap[chequeNo]!
                                              .toLowerCase() ==
                                          "returned") ...[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: TextFormField(
                                            controller: returnDateController,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  "Return Date (YYYY-MM-DD)",
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(Icons.edit),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                snackbarError(context,
                                                    "Return Date cannot be empty");
                                                return "Return Date cannot be empty";
                                              } else if (DateTime.tryParse(
                                                      value) ==
                                                  null) {
                                                snackbarError(
                                                    context, "Invalid Date");
                                                return "Invalid Date";
                                              } else if (!isDateWithinRange(
                                                  DateTime.tryParse(value) ??
                                                      DateTime(
                                                          DateTime.now().year +
                                                              1))) {
                                                snackbarError(
                                                    context, "Invalid Date");
                                                return "Invalid Date";
                                              } else {
                                                return null;
                                              }
                                            },
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: chequeDeposit
                                                              .depositDate ??
                                                          DateTime.now(),
                                                      lastDate: DateTime.now());
                                              if (pickedDate != null) {
                                                setState(() {
                                                  returnDateController.text =
                                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 24),
                                          child: returnReasonsProvider.when(
                                              data: (returnReasons) {
                                                return DropdownButtonFormField<
                                                        String>(
                                                    value: selectedReason,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          "Return Reason",
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                    items: returnReasons
                                                        .map((returnReason) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: returnReason,
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth:
                                                                      300),
                                                          child: Text(
                                                            returnReason,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 3,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedReason = value!;
                                                        reasonController.text =
                                                            selectedReason!;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null) {
                                                        snackbarError(context,
                                                            "Please select a return reason");
                                                        return "Please select a return reason";
                                                      } else {
                                                        return null;
                                                      }
                                                    });
                                              },
                                              loading: () => const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              error: (error, stack) => Center(
                                                  child: Text(
                                                      'Error: ${error.toString()}'))),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(8, 40, 65, 1),
                                elevation: 3,
                                fixedSize: const Size(90, 40),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              _validateForm();
                              if (_isValidForm) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Changes"),
                                    content: const Text(
                                        "Do you want to confirm the changes or continue editing?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child: const Text("Continue Editing"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          context.pop();
                                          context.pop();
                                          chequeDeposits.updateDepositStatus(
                                              chequeDeposit,
                                              selectedStatus ??
                                                  chequeDeposit.status,
                                              cashedDateController.text);

                                          if (selectedStatus!.toLowerCase() ==
                                              "cashed") {
                                            cheques.updateChequeListCashed(
                                                chequeDeposit.chequeNos ?? [],
                                                "Cashed",
                                                cashedDateController.text);
                                          } else if (selectedStatus!
                                                  .toLowerCase() ==
                                              "cashedwithreturns") {
                                            for (var c
                                                in chequeDeposit.chequeNos ??
                                                    []) {
                                              if (chequeStatusesMap[c]!
                                                      .toLowerCase() ==
                                                  "returned") {
                                                final cheque =
                                                    await cheques.findCheque(c);
                                                cheques.updateChequeReturn(
                                                    cheque,
                                                    "Returned",
                                                    selectedReason!,
                                                    returnDateController.text);
                                              } else if (chequeStatusesMap[c]!
                                                      .toLowerCase() ==
                                                  "cashed") {
                                                final cheque =
                                                    await cheques.findCheque(c);
                                                cheques.updateChequeCashed(
                                                    cheque,
                                                    "Cashed",
                                                    cashedDateController.text);
                                              }
                                            }
                                          }
                                        },
                                        child: const Text("Confirm"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Update",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text('No data available.'));
                  }
                },
              ),
            ),
          ),
        ));
  }
}

String getStatusString(String status) {
  if (status.toLowerCase() == 'cashed') {
    return 'Cashed';
  } else if (status.toLowerCase() == 'cashedwithreturns') {
    return 'Cashed with Returns';
  } else if (status.toLowerCase() == 'deposited') {
    return 'Deposited';
  } else {
    return 'Unknown';
  }
}
