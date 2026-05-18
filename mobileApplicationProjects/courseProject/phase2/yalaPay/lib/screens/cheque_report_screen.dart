import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/providers/cheque_provider.dart';
import 'package:yala_pay/providers/localDB/cheque_status_provider.dart';
import 'package:yala_pay/widgets/cheque_report_info.dart';

class ChequeReportScreen extends ConsumerStatefulWidget {
  const ChequeReportScreen({super.key});

  @override
  ConsumerState<ChequeReportScreen> createState() =>
      _InvoicesReportScreenState();
}

class _InvoicesReportScreenState extends ConsumerState<ChequeReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  bool _showReportInfo = false;
  // ignore: unused_field
  bool _showErrors = false;

  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final statusController = TextEditingController();

  // Change selectedStatus to directly hold a ChequeStatus value
  String selectedStatus = 'All';

  double totalAmount = 0.0;
  int count = 0;

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
    statusController.text = 'all';
  }

  @override
  Widget build(BuildContext context) {
    final chequeStatusProvider = ref.watch(chequeStatusNotifierProvider);

    statusController.text = selectedStatus;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(CupertinoIcons.back),
          ),
          title: const Text("Cheque Report"),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                      firstDate: DateTime(DateTime.now().year - 1),
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
                padding: const EdgeInsets.only(bottom: 16),
                child: chequeStatusProvider.when(
                    data: ((chequeStatuses) {
                      if (!["All", ...chequeStatuses]
                          .contains(selectedStatus)) {
                        selectedStatus = "All";
                      }
                      return DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: "All",
                            child: Text("All"),
                          ),
                          ...chequeStatuses.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                  '${status[0].toUpperCase()}${status.substring(1)}'),
                            );
                          })
                        ].toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                            statusController.text = selectedStatus;
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
                    ChequeReportInfo(
                      startDate: DateTime.parse(fromDateController.text),
                      endDate: DateTime.parse(toDateController.text),
                      status: statusController.text,
                    ),
                ],
              ),
            ],
          ),
        ));
  }
}

