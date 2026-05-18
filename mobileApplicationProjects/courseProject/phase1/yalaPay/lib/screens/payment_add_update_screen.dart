import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/payment_mode.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';
import 'package:yala_pay/widgets/discard_changes_dialog.dart';

class PaymentAddUpdateScreen extends ConsumerStatefulWidget {
  final String paymentId;
  final String invoiceId;
  const PaymentAddUpdateScreen(
      {super.key, required this.paymentId, required this.invoiceId});

  @override
  ConsumerState<PaymentAddUpdateScreen> createState() =>
      _PaymentAddUpdateScreenState();
}

class _PaymentAddUpdateScreenState
    extends ConsumerState<PaymentAddUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  // ignore: unused_field
  bool _showErrors = false;

  final amountController = TextEditingController();
  late PaymentMode selectedPaymentMode = PaymentMode.creditCard;
  var chequeNoController = TextEditingController();
  final drawerController = TextEditingController();
  late Bank selectedDrawerBank;
  late String chequeImage;
  final dueDateController = TextEditingController();
  final paymentDateController = TextEditingController();

  // temporary until we have real data
  final List<String> images = [
    "cheque1.jpg",
    "cheque2.jpg",
    "cheque3.jpg",
    "cheque4.jpg",
    "cheque5.jpg",
    "cheque6.jpg",
    "cheque7.jpg"
  ];

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
    if (widget.paymentId != '-1') {
      final paymentProvider = ref.read(paymentNotifierProvider);
      final existingPayment = paymentProvider.firstWhere(
        (payment) => payment.id == widget.paymentId,
      );

      amountController.text = existingPayment.amount.toString();
      selectedPaymentMode = existingPayment.paymentMode;
      paymentDateController.text = existingPayment.paymentDate.toString().split(' ')[0];
      if (existingPayment.paymentMode == PaymentMode.cheque) {
        final chequesProvider = ref.read(chequeNotifierProvider);
        final exitingCheque = chequesProvider
            .firstWhere((ch) => ch.chequeNo == existingPayment.chequeNo);
        chequeNoController.text = existingPayment.chequeNo.toString();
        drawerController.text = exitingCheque.drawer;
        selectedDrawerBank = exitingCheque.bankName;
        chequeImage = exitingCheque.chequeImageUri ?? '';
        dueDateController.text = exitingCheque.dueDate.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = ref.watch(invoiceNotifierProvider);
    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);
    final paymentProvider = ref.watch(paymentNotifierProvider);
    final chequesNotifier = ref.read(chequeNotifierProvider.notifier);
    final chequesProvider = ref.watch(chequeNotifierProvider);

    final totalInvoicePayments =
        paymentProvider.where((p) => p.invoiceNo == widget.invoiceId).map((p) {
      if (p.paymentMode != PaymentMode.cheque) {
        return p.amount;
      } else {
        final cheque = chequesProvider.firstWhere(
          (c) => c.chequeNo == p.chequeNo,
        );
        return cheque.status == ChequeStatus.cashed ? cheque.amount : 0.0;
      }
    }).fold(0.0, (x, y) => x + y);

    final invoicePendingBalance =
        invoiceProvider.firstWhere((i) => i.id == widget.invoiceId).amount -
            totalInvoicePayments;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => const DiscardChangesDialog());
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: widget.paymentId != '-1'
            ? const Text("Update Payment")
            : const Text("Add New Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.paymentId != '-1')
                  TextFormField(
                    enabled: false,
                    initialValue: "Payment ID: ${widget.paymentId}",
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: false,
                  initialValue: "For Invoice ID: ${widget.invoiceId}",
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.edit),
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Amount cannot be empty"
                      : double.tryParse(value) == null
                          ? "Enter a valid number"
                          : double.tryParse(value)! > invoicePendingBalance ||
                                  double.tryParse(value)! <= 0
                              ? "Invalid amount"
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: paymentDateController,
                  decoration: const InputDecoration(
                    labelText: "Payment Date (YYYY-MM-DD)",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.edit),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        paymentDateController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Deposit Date cannot be empty";
                    } else if (DateTime.tryParse(value) == null) {
                      return "Invalid Date";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 16),
                (widget.paymentId == '-1')
                    ? DropdownButtonFormField<PaymentMode>(
                        value: selectedPaymentMode,
                        decoration: const InputDecoration(
                          labelText: "Payment Mode",
                          border: OutlineInputBorder(),
                        ),
                        items: PaymentMode.values.map((paymentMode) {
                          return DropdownMenuItem<PaymentMode>(
                            value: paymentMode,
                            child: Text(
                              switch (paymentMode) {
                                PaymentMode.bankTransfer => "Bank Transfer",
                                PaymentMode.creditCard => "Credit Card",
                                PaymentMode.cheque => "Cheque",
                              },
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMode = value!;
                          });
                        },
                        validator: (value) => value == null
                            ? "Please select a payment mode"
                            : null,
                      )
                    : TextFormField(
                        enabled: false,
                        initialValue: selectedPaymentMode.name,
                        decoration: const InputDecoration(
                          labelText: "Payment Mode",
                          border: OutlineInputBorder(),
                        ),
                      ),
                if (selectedPaymentMode == PaymentMode.cheque)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        TextFormField(
                          enabled: widget.paymentId != '-1' ? false : true,
                          controller: chequeNoController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Cheque No.",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Cheque No. is required"
                              : double.tryParse(value) == null ||
                                      value.length < 4 ||
                                      (chequesProvider.any((c) =>
                                              c.chequeNo.toString() == value) &&
                                          widget.paymentId == '-1')
                                  ? "Enter a valid Cheque No."
                                  : null,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          enabled: widget.paymentId != '-1' ? false : true,
                          controller: drawerController,
                          decoration: const InputDecoration(
                            labelText: "Drawer Name",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Drawer Name is required"
                              : null,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        (widget.paymentId == '-1')
                            ? DropdownButtonFormField<Bank>(
                                decoration: const InputDecoration(
                                  labelText: "Drawer Bank",
                                  border: OutlineInputBorder(),
                                ),
                                value: null,
                                items: Bank.values.map((bank) {
                                  return DropdownMenuItem<Bank>(
                                    value: bank,
                                    child: Text(Cheque.getBankString(bank)),
                                  );
                                }).toList(),
                                validator: (value) =>
                                    value == null ? "Select a bank." : null,
                                onChanged: (Bank? value) {
                                  selectedDrawerBank = value!;
                                },
                              )
                            : TextFormField(
                                enabled: false,
                                initialValue: selectedDrawerBank.name,
                                decoration: const InputDecoration(
                                  labelText: "Drawer Bank",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                        const SizedBox(
                          height: 16,
                        ),
                        (widget.paymentId == '-1')
                            ? DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: "Cheque Image",
                                  border: OutlineInputBorder(),
                                ),
                                value: null,
                                items: images.map((i) {
                                  return DropdownMenuItem<String>(
                                    value: i,
                                    child: Text(i),
                                  );
                                }).toList(),
                                validator: (value) => value == null
                                    ? "Select a cheque image."
                                    : null,
                                onChanged: (String? value) {
                                  chequeImage = value!;
                                },
                              )
                            : TextFormField(
                                enabled: false,
                                initialValue: chequeImage,
                                decoration: const InputDecoration(
                                  labelText: "Cheque Image",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          enabled: widget.paymentId != '-1' ? false : true,
                          controller: dueDateController,
                          decoration: const InputDecoration(
                            labelText: "Cheque Due Date (YYYY-MM-DD)",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.edit),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Please pick a due date for the cheque"
                              : null,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              initialDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 5),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dueDateController.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(8, 40, 65, 1),
                        elevation: 3,
                        fixedSize: Size(140.0, 40.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      _validateForm();
                      if (_isValidForm) {
                        showDialog(
                            barrierDismissible: false,
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
                                        child: const Text("Continue Editing")),
                                    TextButton(
                                      onPressed: () {
                                        if (selectedPaymentMode ==
                                            PaymentMode.cheque) {
                                          chequesNotifier.addChequeAsPayment(
                                              int.tryParse(
                                                  chequeNoController.text)!,
                                              double.tryParse(
                                                  amountController.text)!,
                                              drawerController.text,
                                              selectedDrawerBank,
                                              DateTime.now(),
                                              DateTime.parse(
                                                  dueDateController.text),
                                              chequeImage);
                                        }
                                        paymentNotifier.addUpdatePayment(
                                            id: widget.paymentId,
                                            invoiceNo: widget.invoiceId,
                                            amount: double.parse(
                                                amountController.text),
                                            paymentDate: DateTime.parse(
                                                paymentDateController.text),
                                            paymentMode: selectedPaymentMode,
                                            invoices: invoiceProvider,
                                            chequeNo: selectedPaymentMode ==
                                                    PaymentMode.cheque
                                                ? int.parse(
                                                    chequeNoController.text)
                                                : null);
                                        context.pop();
                                        context.pop();
                                      },
                                      child: const Text("Confirm"),
                                    )
                                  ],
                                ));
                      }
                    },
                    child: Text(
                      widget.paymentId == '-1'
                          ? "Add Payment"
                          : "Apply Changes",
                      style: const TextStyle(color: Colors.white),
                    ),
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
