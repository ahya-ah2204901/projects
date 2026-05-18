import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/deposit_status.dart';
import 'package:yala_pay/models/enums/return_reason.dart';
import 'package:yala_pay/providers/cheque_deposit_provider.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
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

  DepositStatus? selectedStatus;
  ReturnReason? selectedReason;

  Map<String, ChequeStatus> chequeStatusesMap = {};

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  @override
  void initState() {
    super.initState();
    returnDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    cashedDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    selectedStatus = DepositStatus.cashed;

    final chequeDep = ref
        .read(chequeDepositNotifierProvider.notifier)
        .findChequeDeposit(widget.chequeDepId);
    chequeDep.chequeNos?.forEach((chequeNo) {
      chequeStatusesMap[chequeNo.toString()] = ChequeStatus.cashed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chequeDeposits = ref.read(chequeDepositNotifierProvider.notifier);
    final cheques = ref.read(chequeNotifierProvider.notifier);
    var chequeDeposit = chequeDeposits.findChequeDeposit(widget.chequeDepId);
    final depositStatuses = [
      DepositStatus.cashed,
      DepositStatus.cashedwithReturns
    ];
    final chequeStatuses = [ChequeStatus.cashed, ChequeStatus.returned];

    bool anyReturned = chequeStatusesMap.values
        .any((status) => status == ChequeStatus.returned);

    bool isDateWithinRange(DateTime date) {
      final depositDate = chequeDeposit.depositDate;
      final today = DateTime.now();
      return date.isAfter(depositDate!)||
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
              child: Column(
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
                          return "Cashed Date cannot be empty";
                        } else if (DateTime.tryParse(value) == null) {
                          return "Invalid Date";
                        } else if (!isDateWithinRange(
                            DateTime.tryParse(value) ??
                                DateTime(DateTime.now().year + 1))) {
                          return "Invalid Date";
                        } else {
                          return null;
                        }
                      },
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate:
                                chequeDeposit.depositDate ?? DateTime.now(),
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
                    child: DropdownButtonFormField<DepositStatus>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: depositStatuses.map((status) {
                        return DropdownMenuItem<DepositStatus>(
                          value: status,
                          child: Text(getStatusString(status)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          statusController.text = selectedStatus!.name;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Please select a status" : null,
                    ),
                  ),
                  if (selectedStatus == DepositStatus.cashedwithReturns) ...[
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cheque No: $chequeNo",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<ChequeStatus>(
                                    value:
                                        chequeStatusesMap[chequeNo.toString()],
                                    decoration: const InputDecoration(
                                      labelText: "Status",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: chequeStatuses.map((status) {
                                      return DropdownMenuItem<ChequeStatus>(
                                        value: status,
                                        child: Text(
                                            '${status.name[0].toUpperCase()}${status.name.substring(1)}'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        chequeStatusesMap[chequeNo.toString()] =
                                            value!;
                                      });
                                    },
                                    validator: (value) {
                                      if (selectedStatus ==
                                          DepositStatus.cashedwithReturns) {
                                        if (!anyReturned) {
                                          return 'At least one cheque must be returned';
                                        }
                                      }
                                      return value == null
                                          ? "Please select a status"
                                          : null;
                                    }),
                                const SizedBox(height: 16),
                                if (chequeStatusesMap[chequeNo.toString()] ==
                                    ChequeStatus.returned) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: TextFormField(
                                      controller: returnDateController,
                                      decoration: const InputDecoration(
                                        labelText: "Return Date (YYYY-MM-DD)",
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.edit),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Return Date cannot be empty";
                                        } else if (DateTime.tryParse(value) ==
                                            null) {
                                          return "Invalid Date";
                                        } else if (!isDateWithinRange(
                                            DateTime.tryParse(value) ??
                                                DateTime(
                                                    DateTime.now().year + 1))) {
                                          return "Invalid Date";
                                        } else {
                                          return null;
                                        }
                                      },
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate:
                                                    chequeDeposit.depositDate ??
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
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child:
                                        DropdownButtonFormField<ReturnReason>(
                                      value: selectedReason,
                                      decoration: const InputDecoration(
                                        labelText: "Return Reason",
                                        border: OutlineInputBorder(),
                                      ),
                                      items: ReturnReason.values
                                          .map((returnReason) {
                                        return DropdownMenuItem<ReturnReason>(
                                          value: returnReason,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 300),
                                            child: Text(
                                              Cheque.getReturnReasonString(
                                                  returnReason),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedReason = value!;
                                          reasonController.text =
                                              selectedReason!.name;
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? "Please select a return reason"
                                          : null,
                                    ),
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
                          backgroundColor: const Color.fromRGBO(8, 40, 65, 1),
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
                                  onPressed: () {
                                    context.pop();
                                    context.pop();
                                    chequeDeposits.updateDepositStatus(
                                        chequeDeposit,
                                        selectedStatus ?? chequeDeposit.status,
                                        cashedDateController.text);
                                    if (selectedStatus ==
                                        DepositStatus.cashed) {
                                      cheques.updateChequeListCashed(
                                          chequeDeposit.chequeNos ?? [],
                                          ChequeStatus.cashed,
                                          cashedDateController.text);
                                    } else if (selectedStatus ==
                                        DepositStatus.cashedwithReturns) {
                                      for (var c
                                          in chequeDeposit.chequeNos ?? []) {
                                        if (chequeStatusesMap[c.toString()] ==
                                            ChequeStatus.returned) {
                                          cheques.updateChequeReturn(
                                              cheques.findCheque(c),
                                              ChequeStatus.returned,
                                              selectedReason!,
                                              returnDateController.text);
                                        } else if (chequeStatusesMap[
                                                c.toString()] ==
                                            ChequeStatus.cashed) {
                                          cheques.updateChequeCashed(
                                              cheques.findCheque(c),
                                              ChequeStatus.cashed,
                                              cashedDateController.text);
                                        }
                                      }
                                      ;
                                    }
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                          );
                        }
                        ;
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
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
