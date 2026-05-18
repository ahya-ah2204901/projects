import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/enums/invoice_status.dart';
import 'package:yala_pay/providers/localDB/invoice_status_provider.dart';
import 'package:yala_pay/widgets/invoice_report_info.dart';

// original class commented out at the bottom

class InvoicesReportScreen extends ConsumerStatefulWidget {
  const InvoicesReportScreen({super.key});

  @override
  ConsumerState<InvoicesReportScreen> createState() =>
      _InvoicesReportScreenState();
}

class _InvoicesReportScreenState extends ConsumerState<InvoicesReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  // ignore: unused_field
  bool _showErrors = false;
  bool _showReportInfo = false;

  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  late String selectedStatus = 'All';

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
    fromDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    toDateController.text =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    selectedStatus = 'All';
  }

  @override
  Widget build(BuildContext context) {
    final invoiceStatusProvider = ref.watch(invoiceStatusNotifierProvider);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(CupertinoIcons.back),
          ),
          title: const Text("Invoices Report"),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextFormField(
                    controller: fromDateController,
                    decoration: const InputDecoration(
                      labelText: "From Due Date (YYYY-MM-DD)",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.edit),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "From Date cannot be empty" : null,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().month - 12),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          fromDateController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextFormField(
                    controller: toDateController,
                    decoration: const InputDecoration(
                      labelText: "To Due Date (YYYY-MM-DD)",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.edit),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "To Date cannot be empty" : null,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(fromDateController.text),
                        firstDate: DateTime.parse(fromDateController.text),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          toDateController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: invoiceStatusProvider.when(
                      data: ((invoiceStatuses) {
                        if (!["All", ...invoiceStatuses].contains(selectedStatus)) {
                          selectedStatus = "All";
                        }
                        return DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: "Status",
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: "All",
                              child: const Text("All"),
                            ),
                            ...invoiceStatuses.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList()],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Please select a status" : null,
                        );
                      }),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: ${error.toString()}'))),
                ),
                Stack(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 3.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 3,
                                fixedSize: const Size(70, 30),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              setState(() {
                                _showReportInfo = !_showReportInfo;
                              });
                            },
                            child: Text(
                              (_showReportInfo) ? "Hide" : "Show",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    if (_showReportInfo)
                      InvoiceReportInfo(
                        startDate: DateTime.parse(fromDateController.text),
                        endDate: DateTime.parse(toDateController.text),
                        status: selectedStatus,
                      )
                  ],
                ),
              ],
            )));
  }
}
