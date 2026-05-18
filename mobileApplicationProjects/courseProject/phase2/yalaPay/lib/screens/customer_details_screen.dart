import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yala_pay/routes/app_router.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerDetailsScreen extends ConsumerStatefulWidget {
  final String customerId;
  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends ConsumerState<CustomerDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final customerProvider = ref.watch(customerNotifierProvider);
    final customerNotifier = ref.read(customerNotifierProvider.notifier);
    Future<Customer> customer =
        customerNotifier.getCustomerById(widget.customerId);
    return customerProvider.when(
        data: ((customers) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(CupertinoIcons.back),
              ),
              title: const Text("Customer Details"),
              actions: [
                IconButton(
                    onPressed: () {
                      context.pushNamed(AppRouter.customerAddUpdate.name,
                          pathParameters: {'customerId': widget.customerId});
                    },
                    icon: const Icon(Icons.edit))
              ],
            ),
            body: FutureBuilder(
                future: customer,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final customer = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 70,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    customer.companyName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("ID: ${customer.id}")
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Address",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customerDetailsColumn(
                                          "Street", customer.address.street),
                                      customerDetailsColumn(
                                          "City", customer.address.city),
                                      customerDetailsColumn(
                                          "Country", customer.address.country),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Contact Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customerDetailsColumn("Name",
                                          "${customer.contactDetails.firstName} ${customer.contactDetails.lastName}"),
                                      customerDetailsColumn("Email",
                                          customer.contactDetails.email),
                                      customerDetailsColumn("Mobile",
                                          customer.contactDetails.mobile),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Text('No data available');
                  }
                }),
          );
        }),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')));
  }

  Widget customerDetailsColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
