import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/method_constants.dart';
import 'package:yala_pay/providers/invoice_provider.dart';
import 'package:yala_pay/providers/localDB/country_city_provider.dart';
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

  void _validateForm() {
    setState(() {
      _showErrors = true;
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
    if (_isValidForm) {
      _formKey.currentState!.save();
    }
  }

  Future<void> _initializeCustomerData() async {
    final customerNotifier = ref.read(customerNotifierProvider.notifier);

    Customer? customer;
    if (widget.customerId == '-1') {
      customer = Customer(
          id: "",
          companyName: "",
          address: Address(street: "", city: "", country: ""),
          contactDetails: ContactDetails(
              firstName: "", lastName: "", email: "", mobile: ""));
    } else {
      try {
        customer = await customerNotifier.getCustomerById(widget.customerId);
      } catch (e) {
        print("Error fetching customer data: $e");
      }
    }

    setState(() {
      companyNameController.text = customer!.companyName;
      selectedCountry = customer.address.country;
      selectedCity = customer.address.city;
      streetController.text = customer.address.street;
      firstNameController.text = customer.contactDetails.firstName;
      lastNameController.text = customer.contactDetails.lastName;
      emailController.text = customer.contactDetails.email;
      mobileController.text = customer.contactDetails.mobile;
    });
  }

  @override
  void initState() {
    super.initState();
    // loadCountryData();
    _initializeCustomerData();
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
    final invoicesProvider = ref.watch(invoiceNotifierProvider);
    // ignore: unused_local_variable
    final customerProvider = ref.watch(customerNotifierProvider);
    final customerNotifier = ref.read(customerNotifierProvider.notifier);

    final invoicesNotifier = ref.read(invoiceNotifierProvider.notifier);

    final countryProvider = ref.watch(countryCityNotifierProvider);
    final countryNotifier = ref.read(countryCityNotifierProvider.notifier);
    Future<List<String>> citiesInCountry =
        countryNotifier.getCitiesForCountry(selectedCountry ?? "");

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
                        autoValidate: _showErrors,
                        validator: (value) => value!.isEmpty
                            ? "Company Name cannot be empty"
                            : null,
                      ),
                      const Text("Address (Country, City, Street)"),
                      const SizedBox(
                        height: 20,
                      ),
                      countryProvider.when(
                          data: (countries) {
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Country",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedCountry == ''
                                  ? null
                                  : selectedCountry,
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
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                              child: Text('Error: ${error.toString()}'))),
                      const SizedBox(
                        height: 20,
                      ),
                      FutureBuilder<List<String>>(
                        future: citiesInCountry,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final cities = snapshot.data!;
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "City",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedCity == '' ? null : selectedCity,
                              items: cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = value;
                                });
                              },
                              validator: (value) =>
                                  value == null ? "City is required" : null,
                            );
                          } else {
                            return const Text('No data available');
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomerTextFormField(
                        controller: streetController,
                        label: "Street",
                        autoValidate: _showErrors,
                        validator: (value) =>
                            value!.isEmpty ? "Street cannot be empty" : null,
                      ),
                      CustomerTextFormField(
                        controller: firstNameController,
                        label: "First Name",
                        autoValidate: _showErrors,
                        validator: (value) => value!.isEmpty
                            ? "First Name cannot be empty"
                            : null,
                      ),
                      CustomerTextFormField(
                        controller: lastNameController,
                        label: "Last Name",
                        autoValidate: _showErrors,
                        validator: (value) =>
                            value!.isEmpty ? "Last Name cannot be empty" : null,
                      ),
                      CustomerTextFormField(
                        controller: emailController,
                        label: "Email",
                        autoValidate: _showErrors,
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
                          autoValidate: _showErrors,
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
                      fixedSize: const Size(145, 30),
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
                                        Customer cust = Customer(
                                            id: widget.customerId,
                                            companyName:
                                                companyNameController.text,
                                            address: Address(
                                                street: streetController.text,
                                                city: selectedCity!,
                                                country: selectedCountry!),
                                            contactDetails: ContactDetails(
                                                firstName:
                                                    firstNameController.text,
                                                lastName:
                                                    lastNameController.text,
                                                email: emailController.text,
                                                mobile: _formatMobileNumber(
                                                    mobileController.text)));
                                        customerNotifier
                                            .addUpdateCustomer(cust);

                                        invoicesProvider.when(
                                            data: (invoices) {
                                              List<Invoice> validInvoices =
                                                  invoices
                                                      .where((inv) =>
                                                          inv.customerId ==
                                                          cust.id)
                                                      .toList();
                                              for (Invoice invoice
                                                  in validInvoices) {
                                                Invoice newInvoice = Invoice(
                                                  amount: invoice.amount,
                                                  customerId:
                                                      invoice.customerId,
                                                  customerName:
                                                      cust.companyName,
                                                  dueDate: invoice.dueDate,
                                                  id: invoice.id,
                                                  invoiceDate:
                                                      invoice.invoiceDate,
                                                );
                                                invoicesNotifier
                                                    .addUpdateInvoice(
                                                        newInvoice);
                                              }
                                            },
                                            error: (error, stack) => Center(
                                                child: Text(
                                                    'Error: ${error.toString()}')),
                                            loading: () => const Center(
                                                child:
                                                    CircularProgressIndicator()));
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
