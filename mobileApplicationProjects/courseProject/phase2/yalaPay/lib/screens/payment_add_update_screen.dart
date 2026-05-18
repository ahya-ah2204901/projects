import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/localDB/bank_provider.dart';
import 'package:yala_pay/providers/localDB/payment_mode_provider.dart';
import 'package:yala_pay/providers/payment_provider.dart';
import 'package:yala_pay/widgets/discard_changes_dialog.dart';

// original class commented out at the bottom

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

  double initialAmount = 0;
  final amountController = TextEditingController();
  late String selectedPaymentMode = '';
  var chequeNoController = TextEditingController();
  final drawerController = TextEditingController();
  late String selectedDrawerBank = '';
  late String chequeImage = '';
  final dueDateController = TextEditingController();
  final paymentDateController = TextEditingController();

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  Future<void> initializePaymentsData() async {
    final paymentProvider = await ref.read(paymentNotifierProvider.future);
    final existingPayment = paymentProvider.any(
      (payment) => payment.id == widget.paymentId,
    );
    Payment? payment;
    if (existingPayment) {
      payment = paymentProvider.firstWhere((pay) => pay.id == widget.paymentId);
    } else {
      payment = Payment(
        paymentMode: "",
        amount: 0,
        chequeNo: 0,
        id: "",
        invoiceNo: "",
        paymentDate: DateTime.now(),
      );
    }
    final chequesProvider = await ref.read(chequeNotifierProvider.future);

    setState(() {
      amountController.text = payment!.amount.toString();
      initialAmount = payment.amount;
      selectedPaymentMode = payment.paymentMode;
      paymentDateController.text =
          "${payment.paymentDate!.year}-${payment.paymentDate!.month.toString().padLeft(2, '0')}-${payment.paymentDate!.day.toString().padLeft(2, '0')}";
    });
    if (payment.paymentMode == 'Cheque' || payment.paymentMode == 'cheque') {
      final exitingCheque =
          chequesProvider.firstWhere((ch) => ch.chequeNo == payment?.chequeNo);
      setState(() {
        chequeNoController.text = payment!.chequeNo.toString();
        drawerController.text = exitingCheque.drawer;
        selectedDrawerBank = exitingCheque.bankName;
        chequeImage = exitingCheque.chequeImageUri ?? '';
        dueDateController.text =
            "${exitingCheque.dueDate!.year}-${exitingCheque.dueDate!.month.toString().padLeft(2, '0')}-${exitingCheque.dueDate!.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializePaymentsData();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = ref.watch(invoiceNotifierProvider);
    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);
    final paymentProvider = ref.watch(paymentNotifierProvider);
    final chequesNotifier = ref.read(chequeNotifierProvider.notifier);
    final chequesProvider = ref.watch(chequeNotifierProvider);

    final paymentModeProvider = ref.watch(paymentModeNotifierProvider);
    final paymentModes = paymentModeProvider.when(
        data: (paymentModes) => paymentModes,
        error: (error, stack) => [],
        loading: () => []);
    if (selectedPaymentMode == '' && widget.paymentId == '-1') {
      selectedPaymentMode = paymentModes[1];
    }

    final bankProvider = ref.watch(bankNotifierProvider);

    final chequesList = chequesProvider.when(
        data: (cheques) => cheques,
        error: (error, stack) => [],
        loading: () => []);

    final totalInvoicePayments = paymentProvider.when(
        data: (payments) {
          return payments
              .where((p) => p.invoiceNo == widget.invoiceId)
              .map((p) {
            if (p.paymentMode != 'Cheque' && p.paymentMode != 'cheques') {
              return p.amount;
            } else {
              final cheque = chequesList.firstWhere(
                  (c) => c.chequeNo == p.chequeNo,
                  orElse: () => Cheque(bankName: ''));
              return cheque.status != 'Returned' && cheque.status != 'returned'
                  ? cheque.amount
                  : 0.0;
            }
          }).fold(0.0, (x, y) => x + y);
        },
        error: (error, stack) => 0.0,
        loading: () => 0.0);

    final invoicePendingBalance = invoiceProvider.when(
        data: (invoices) {
          final invoice = invoices.firstWhere((i) => i.id == widget.invoiceId);
          return invoice != null ? invoice.amount - totalInvoicePayments : 0.0;
        },
        error: (error, stack) => 0.0,
        loading: () => 0.0);

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
                          : double.tryParse(value)! >
                                      (invoicePendingBalance + initialAmount) ||
                                  double.tryParse(value)! < 0
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
                    ? paymentModeProvider.when(
                        data: ((paymentModes) {
                          if (paymentModes.isNotEmpty) {
                            return DropdownButtonFormField<String>(
                              value: selectedPaymentMode,
                              decoration: const InputDecoration(
                                labelText: "Payment Mode",
                                border: OutlineInputBorder(),
                              ),
                              items: paymentModes.map((paymentMode) {
                                return DropdownMenuItem<String>(
                                  value: paymentMode,
                                  child: Text(paymentMode),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMode = value!;
                                });
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Please select a payment mode"
                                      : null,
                            );
                          }
                          return const SizedBox();
                        }),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Center(child: Text('Error: ${error.toString()}')))
                    : TextFormField(
                        enabled: false,
                        initialValue: selectedPaymentMode,
                        decoration: InputDecoration(
                          labelText: selectedPaymentMode,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                if (selectedPaymentMode == 'Cheque' ||
                    selectedPaymentMode == 'cheque')
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
                          validator: (value) => value == null || value.isEmpty
                              ? "Cheque No. is required"
                              : double.tryParse(value) == null ||
                                      value.length < 4 ||
                                      (chequesList.any((c) =>
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
                            ? bankProvider.when(
                                data: ((banks) {
                                  return DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: "Drawer Bank",
                                      border: OutlineInputBorder(),
                                    ),
                                    value: null,
                                    items: banks.map((bank) {
                                      return DropdownMenuItem<String>(
                                        value: bank,
                                        child: Text(bank),
                                      );
                                    }).toList(),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? "Select a bank."
                                            : null,
                                    onChanged: (String? value) {
                                      selectedDrawerBank = value!;
                                    },
                                  );
                                }),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Center(
                                    child: Text('Error: ${error.toString()}')))
                            : TextFormField(
                                enabled: false,
                                initialValue: selectedDrawerBank,
                                decoration: const InputDecoration(
                                  labelText: "Drawer Bank",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                        const SizedBox(
                          height: 16,
                        ),
                        (widget.paymentId == '-1')
                            ?
                            // ? DropdownButtonFormField<String>(
                            //     decoration: const InputDecoration(
                            //       labelText: "Cheque Image",
                            //       border: OutlineInputBorder(),
                            //     ),
                            //     value: null,
                            //     items: images.map((i) {
                            //       return DropdownMenuItem<String>(
                            //         value: i,
                            //         child: Text(i),
                            //       );
                            //     }).toList(),
                            //     validator: (value) =>
                            //         value == null || value.isEmpty
                            //             ? "Select a cheque image."
                            //             : null,
                            //     onChanged: (String? value) {
                            //       chequeImage = value!;
                            //     },
                            //   )

                            //should become add image, choose image
                            Column(
                                children: [
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          String? url = await chequesNotifier
                                              .uploadChequeImageFromGallery();
                                          print(
                                              "Received URL from uploadChequeImageFromCamera: $url");

                                          if (url != null) {
                                            setState(() {
                                              chequeImage = url;
                                              print(
                                                  "Updated chequeImage to: $chequeImage");
                                            });
                                          } else {
                                            print(
                                                "Failed to get URL. No image uploaded.");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    8, 40, 65, 1),
                                            elevation: 3,
                                            fixedSize: const Size(140.0, 40.0),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        child: const Text("Choose Image",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      ElevatedButton(
                                        onPressed: () async {
                                          print(
                                              "Button pressed to upload cheque image from camera.");
                                          String? url = await chequesNotifier
                                              .uploadChequeImageFromCamera();
                                          print(
                                              "Received URL from uploadChequeImageFromCamera: $url");

                                          if (url != null) {
                                            setState(() {
                                              chequeImage = url;
                                              print(
                                                  "Updated chequeImage to: $chequeImage");
                                            });
                                          } else {
                                            print(
                                                "Failed to get URL. No image uploaded.");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    8, 40, 65, 1),
                                            elevation: 3,
                                            fixedSize: const Size(140.0, 40.0),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        child: const Text("Take Photo",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  TextFormField(
                                    enabled: false,
                                    initialValue: chequeImage,
                                    decoration: const InputDecoration(
                                      labelText: "Cheque Image",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
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
                          validator: (value) => value == null || value.isEmpty
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
                        fixedSize: const Size(140.0, 40.0),
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
                                        if (selectedPaymentMode == 'Cheque') {
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
                                            Payment(
                                                id: widget.paymentId,
                                                invoiceNo: widget.invoiceId,
                                                amount: double.parse(
                                                    amountController.text),
                                                paymentDate: DateTime.parse(
                                                    paymentDateController.text),
                                                paymentMode:
                                                    selectedPaymentMode,
                                                chequeNo: selectedPaymentMode ==
                                                        'Cheque'
                                                    ? int.parse(
                                                        chequeNoController.text)
                                                    : null));
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
