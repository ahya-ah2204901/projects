import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/customer_provider.dart';
import 'package:yala_pay/providers/invoice_provider.dart';

// original class commented out at the bottom

class InvoiceAddUpdateScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceAddUpdateScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceAddUpdateScreen> createState() =>
      _InvoiceAddUpdateScreenState();
}

class _InvoiceAddUpdateScreenState
    extends ConsumerState<InvoiceAddUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  // ignore: unused_field
  bool _showErrors = false;

  final amountController = TextEditingController();
  final dueDateController = TextEditingController();
  String selectedCustomerName = '';
  DateTime invoiceDate = DateTime.now();

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  Future<void> initializeInvoicesData() async {
    final invoiceProvider = await ref.read(invoiceNotifierProvider.future);
    final existingInvoice =
        invoiceProvider.any((invoice) => invoice.id == widget.invoiceId);
    Invoice? invoice;
    if (existingInvoice) {
      invoice = invoiceProvider
          .firstWhere((invoice) => invoice.id == widget.invoiceId);
    } else {
      invoice = Invoice(
        amount: 0,
        customerId: "",
        customerName: "",
        dueDate: DateTime.now(),
        id: "",
        invoiceDate: DateTime.now(),
      );
    }
    selectedCustomerName = invoice.customerName;
    amountController.text = invoice.amount.toString();
    dueDateController.text =
        "${invoice.dueDate?.year}-${invoice.dueDate?.month.toString().padLeft(2, '0')}-${invoice.dueDate?.day.toString().padLeft(2, '0')}";
    invoiceDate = invoice.invoiceDate!;
  }

  @override
  void initState() {
    super.initState();
    initializeInvoicesData();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = ref.watch(customerNotifierProvider);
    final invoiceNotifier = ref.read(invoiceNotifierProvider.notifier);
    // ignore: unused_local_variable
    final invoiceProvider = ref.watch(invoiceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Discard Changes"),
                      content: const Text(
                          "Do you want to discard the changes or continue editing?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: const Text("Continue Editing")),
                        TextButton(
                            onPressed: () {
                              context.pop();
                              context.pop();
                            },
                            child: const Text("Discard"))
                      ],
                    ));
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        title: widget.invoiceId != '-1'
            ? const Text("Update Invoice")
            : const Text("Add New Invoice"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.invoiceId != '-1')
                Column(
                  children: [
                    TextFormField(
                      enabled: false,
                      initialValue: "Invoice ID: ${widget.invoiceId}",
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextFormField(
                        enabled: false,
                        initialValue: "Customer: $selectedCustomerName",
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              // TextFormField(
              //   enabled: false,
              //   initialValue: "Customer ID: ${existingInvoice.customerId}",
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              const SizedBox(height: 16),

              if (widget.invoiceId == '-1')
                customerProvider.when(
                    data: ((customers) {
                      return DropdownButtonFormField<String>(
                        value: selectedCustomerName.isNotEmpty
                            ? selectedCustomerName
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Customer Name",
                          border: OutlineInputBorder(),
                        ),
                        items: customers.map((customer) {
                          return DropdownMenuItem<String>(
                            value: customer.companyName,
                            child: Text(customer.companyName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCustomerName = value!;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Please select a customer"
                            : null,
                      );
                    }),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: ${error.toString()}'))),
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
                    : double.tryParse(value) == null ||
                            double.tryParse(value)! < 0
                        ? "Enter a valid number"
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                initialValue:
                    "${invoiceDate.year}-${invoiceDate.month}-${invoiceDate.day}",
                decoration: const InputDecoration(
                  labelText: "Invoice Date (Auto-assigned)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dueDateController,
                decoration: const InputDecoration(
                  labelText: "Due Date (YYYY-MM-DD)",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.edit),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Due Date cannot be empty" : null,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
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

              const Expanded(child: SizedBox()),

              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
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
                                    customerProvider.when(
                                        data: ((customers) {
                                          return TextButton(
                                            onPressed: () {
                                              invoiceNotifier
                                                  .addUpdateInvoice(Invoice(
                                                customerId: customers
                                                    .firstWhere((cust) =>
                                                        cust.companyName ==
                                                        selectedCustomerName)
                                                    .id,
                                                id: widget.invoiceId,
                                                customerName:
                                                    selectedCustomerName,
                                                amount: double.parse(
                                                    amountController.text),
                                                invoiceDate: invoiceDate,
                                                dueDate: DateTime.parse(
                                                    dueDateController.text),
                                              ));
                                              context.pop();
                                              context.pop();
                                            },
                                            child: const Text("Confirm"),
                                          );
                                        }),
                                        loading: () => const Center(
                                            child: CircularProgressIndicator()),
                                        error: (error, stack) => Center(
                                            child: Text(
                                                'Error: ${error.toString()}')))
                                  ],
                                ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 3,
                        fixedSize: const Size(139, 30),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text(
                      widget.invoiceId == '-1'
                          ? "Add Invoice"
                          : "Apply Changes",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
