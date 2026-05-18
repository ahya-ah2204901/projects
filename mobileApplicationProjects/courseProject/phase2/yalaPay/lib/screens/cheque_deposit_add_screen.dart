import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/providers/localDB/bank_account_provider.dart';
import 'package:yala_pay/providers/cheque_deposit_provider.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/routes/app_router.dart';
import 'package:yala_pay/widgets/discard_changes_dialog.dart';


class ChequeDepositAddScreen extends ConsumerStatefulWidget {
  final String chequeDepId;

  const ChequeDepositAddScreen({super.key, required this.chequeDepId});

  @override
  ConsumerState<ChequeDepositAddScreen> createState() =>
      _ChequeDepsoitAddScreenState();
}

class _ChequeDepsoitAddScreenState
    extends ConsumerState<ChequeDepositAddScreen> {
  String selectedBankAccount = '';
  List<bool> selectedCheques = [];

  final depositDateController = TextEditingController();

  //late final int awaitingChequesLength;

  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  // ignore: unused_field
  bool _showErrors = false;

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  Future<void> initializeSelectedCheques() async {
    final awaitingCheques =
        ref.read(chequeNotifierProvider.notifier).getAwaitingCheques();
    final awaitingChequesLength = await awaitingCheques.length;
    setState(() {
      selectedCheques = List<bool>.filled(awaitingChequesLength, false);
    });
  }

  @override
  void initState() {
    super.initState();
    initializeSelectedCheques();
    depositDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
  }

  List<Cheque> getSelectedCheques(List<Cheque> awaitingCheques) {
    List<Cheque> selected = [];
    for (int i = 0; i < awaitingCheques.length; i++) {
      if (selectedCheques[i]) {
        selected.add(awaitingCheques[i]);
      }
    }
    return selected;
  }

  bool get isAnyChequeSelected {
    return selectedCheques.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final cheques = ref.watch(chequeNotifierProvider);
    final chequesProvider = ref.read(chequeNotifierProvider.notifier);
    final chequeDepositsProvider =
        ref.read(chequeDepositNotifierProvider.notifier);
    final accounts = ref.watch(bankAccountNotifierProvider);
    // ignore: unused_local_variable
    final chequeDeposits = ref.watch(chequeDepositNotifierProvider);
    final awaitingCheques =
        ref.read(chequeNotifierProvider.notifier).getAwaitingCheques();

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
        title: const Text("Add Cheque Deposit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: depositDateController,
                decoration: const InputDecoration(
                  labelText: "Deposit Date (YYYY-MM-DD)",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Deposit Date cannot be empty";
                  } else if (DateTime.tryParse(value) == null) {
                    return "Invalid Date";
                  } else if (!isDateWithinRange(DateTime.tryParse(value) ??
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
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      depositDateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: accounts.when(
                  data: ((accounts) {
                    return DropdownButtonFormField<String>(
                      value: selectedBankAccount.isNotEmpty
                          ? selectedBankAccount
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Select Bank Account",
                        border: OutlineInputBorder(),
                      ),
                      items: accounts.map((account) {
                        return DropdownMenuItem<String>(
                          value: account.accountNo,
                          child: Text(account.accountNo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBankAccount = value!;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? "Please select a Bank Account"
                          : null,
                    );
                  }),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error: ${error.toString()}'))),
            ),
            Expanded(
                child: StreamBuilder<List<Cheque>>(
              stream: awaitingCheques,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final awaitingCheques = snapshot.data!;
                  if (selectedCheques.length != awaitingCheques.length) {
                    selectedCheques =
                        List<bool>.filled(awaitingCheques.length, false);
                  }
                  return ListView.builder(
                    itemCount: awaitingCheques.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          context.pushNamed(AppRouter.chequeDetails.name,
                              pathParameters: {
                                'chequeNo':
                                    awaitingCheques[index].chequeNo.toString()
                              });
                        },
                        child: ListTile(
                          title: Text(
                            'Cheque No.: ${awaitingCheques[index].chequeNo}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(text: 'Due date: '),
                                TextSpan(
                                  text:
                                      '${awaitingCheques[index].dueDate!.year}-${awaitingCheques[index].dueDate!.month}-${awaitingCheques[index].dueDate!.day} ',
                                ),
                                TextSpan(
                                    text:
                                        '(${awaitingCheques[index].dueDate!.difference(DateTime.now()).inDays})\n',
                                    style: awaitingCheques[index]
                                                .dueDate!
                                                .difference(DateTime.now())
                                                .inDays >=
                                            0
                                        ? TextStyle(color: Colors.green[600])
                                        : TextStyle(color: Colors.red[900])),
                                const TextSpan(text: 'Amount: '),
                                TextSpan(
                                    text: '${awaitingCheques[index].amount}\n'),
                                const TextSpan(text: 'Drawer: '),
                                TextSpan(
                                    text: '${awaitingCheques[index].drawer}\n'),
                                const TextSpan(text: 'Bank: '),
                                TextSpan(
                                  text: awaitingCheques[index].bankName,
                                ),
                              ],
                            ),
                          ),
                          trailing: Checkbox(
                            value: selectedCheques[index],
                            onChanged: (bool? selected) {
                              setState(() {
                                selectedCheques[index] = selected ?? false;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            )),
          ]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Cheque>>(
          stream:
              ref.read(chequeNotifierProvider.notifier).getAwaitingCheques(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Add Cheque Deposit"),
              );
            } else if (snapshot.hasError) {
              return ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              final awaitingCheques = snapshot.data!;
              return ElevatedButton(
                onPressed: (selectedBankAccount.isEmpty || !isAnyChequeSelected)
                    ? null
                    : () {
                        var selCheques = getSelectedCheques(awaitingCheques);
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
                                    chequeDepositsProvider.addChequeDeposit(
                                        selectedBankAccount,
                                        selCheques,
                                        depositDateController.text);
                                    for (var c in selCheques) {
                                      chequesProvider.updateChequeStatus(
                                          c, 'Deposited');
                                    }
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Add Cheque Deposit"),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

bool isDateWithinRange(DateTime date) {
  final oneYearAgo = DateTime(DateTime.now().year - 1);
  final today = DateTime.now();
  return date.isAfter(oneYearAgo) ||
      date.isAtSameMomentAs(oneYearAgo) && date.isBefore(today) ||
      date.isAtSameMomentAs(today);
}
