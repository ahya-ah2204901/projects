import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/color_constants.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/widgets/discard_changes_dialog.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_text_form_feild.dart';

class CustomerAddUpdateScreen extends ConsumerStatefulWidget {
  final String customerId;
  const CustomerAddUpdateScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerAddUpdateScreen> createState() =>
      _CustomerUpdateScreenState();
}

class _CustomerUpdateScreenState
    extends ConsumerState<CustomerAddUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValidForm = false;
  bool _showErrors = false;

  final companyNameController = TextEditingController();
  final streetController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  String? selectedCountry;
  String? selectedCity;
  List<String> countries = [];
  Map<String, List<String>> countryCityMap = {};

  Future<void> loadCountryData() async {
    final String response =
        await rootBundle.loadString('assets/data/countries.json');
    final data = json.decode(response);

    setState(() {
      countryCityMap = (data as Map<String, dynamic>).map((key, value) =>
          MapEntry(key, List<String>.from(value as List<dynamic>)));
      countries = countryCityMap.keys.toList();
    });
  }

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
    loadCountryData();
    final customerProvider = ref.read(customerNotifierProvider);
    final existingCustomer =
        customerProvider.any((c) => c.id == widget.customerId);
    Customer? customer;
    if (existingCustomer) {
      customer = customerProvider.firstWhere((c) => c.id == widget.customerId);
    } else {
      customer = Customer(
          id: "",
          companyName: "",
          address: Address(street: "", city: "", country: ""),
          contactDetails: ContactDetails(
              firstName: "", lastName: "", email: "", mobile: ""));
    }
    companyNameController.text = customer.companyName;
    selectedCountry = customer.address.country;
    selectedCity = customer.address.city;
    streetController.text = customer.address.street;
    firstNameController.text = customer.contactDetails.firstName;
    lastNameController.text = customer.contactDetails.lastName;
    emailController.text = customer.contactDetails.email;
    mobileController.text = customer.contactDetails.mobile;
  }

  String _formatMobileNumber(String mobileNum) {
    if (mobileNum.length == 8 && !mobileNum.contains('-')) {
      return '${mobileNum.substring(0, 4)}-${mobileNum.substring(4)}';
    }
    return mobileNum;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    ref.watch(invoiceNotifierProvider);
    // ignore: unused_local_variable
    final customerProvider = ref.watch(customerNotifierProvider);
    final customerNotifier = ref.read(customerNotifierProvider.notifier);

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
        title: widget.customerId != '-1'
            ? const Text("Update Customer Details")
            : const Text("Add New Customer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.customerId != '-1')
                        TextFormField(
                          enabled: false,
                          initialValue: "ID: ${widget.customerId}",
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        )
                      else
                        const Text("Enter New Customer Details"),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomerTextFormField(
                        controller: companyNameController,
                        label: "Company Name",
                        autovalidate: _showErrors,
                        validator: (value) => value!.isEmpty
                            ? "Company Name cannot be empty"
                            : null,
                      ),
                      const Text("Address (Country, City, Street)"),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Country",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCountry == '' ? null : selectedCountry,
                        items: countries
                            .map((c) => DropdownMenuItem<String>(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                            selectedCity = null;
                          });
                        },
                        validator: (value) =>
                            value == '' ? "Country is required" : null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCity == '' ? null : selectedCity,
                        items: selectedCountry != null &&
                                countryCityMap[selectedCountry] != null
                            ? countryCityMap[selectedCountry]!.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList()
                            : [],
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "City is required" : null,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomerTextFormField(
                        controller: streetController,
                        label: "Street",
                        autovalidate: _showErrors,
                        validator: (value) =>
                            value!.isEmpty ? "Street cannot be empty" : null,
                      ),
                      CustomerTextFormField(
                        controller: firstNameController,
                        label: "First Name",
                        autovalidate: _showErrors,
                        validator: (value) => value!.isEmpty
                            ? "First Name cannot be empty"
                            : null,
                      ),
                      CustomerTextFormField(
                        controller: lastNameController,
                        label: "Last Name",
                        autovalidate: _showErrors,
                        validator: (value) =>
                            value!.isEmpty ? "Last Name cannot be empty" : null,
                      ),
                      CustomerTextFormField(
                        controller: emailController,
                        label: "Email",
                        autovalidate: _showErrors,
                        // validator: (value) =>
                        //     value!.isEmpty ? "Email cannot be empty" : null,
                        validator: (value) {
                          final emailRegEx =
                              RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (value!.isEmpty) {
                            return "Email cannot be empty";
                          } else if (!emailRegEx.hasMatch(value)) {
                            return "Invalid Email Address";
                          } else {
                            return null;
                          }
                        },
                      ),
                      CustomerTextFormField(
                          controller: mobileController,
                          label: "Mobile Number",
                          autovalidate: _showErrors,
                          validator: (value) {
                            final mobileRegEx = RegExp(r'^\d{4}-?\d{4}$');
                            if (value!.isEmpty) {
                              return "Mobile Number cannot be empty";
                            } else if (!mobileRegEx.hasMatch(value)) {
                              return "Invalid Mobile Number";
                            } else {
                              return null;
                            }
                          }),
                    ],
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 3,
                      fixedSize: Size(145, 30),
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
                                        customerNotifier.addUpdateCustomer(
                                            id: widget.customerId,
                                            companyName:
                                                companyNameController.text,
                                            country: selectedCountry,
                                            city: selectedCity,
                                            street: streetController.text,
                                            firstName: firstNameController.text,
                                            lastName: lastNameController.text,
                                            email: emailController.text,
                                            mobile: _formatMobileNumber(
                                                mobileController.text));
                                        final updatedCustomerList =
                                            ref.watch(customerNotifierProvider);
                                        ref
                                            .read(invoiceNotifierProvider
                                                .notifier)
                                            .setCustomerNames(
                                                updatedCustomerList);
                                        context.pop();
                                        context.pop();
                                      },
                                      child: const Text("Confirm"))
                                ],
                              ));
                    }
                  },
                  child: Text(
                    widget.customerId == '-1'
                        ? "Add Customer"
                        : "Apply Changes",
                    style: const TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
