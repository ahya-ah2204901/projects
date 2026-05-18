import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/customer_provider.dart';
import 'package:yala_pay/providers/customer_search_provider.dart';
import '../models/customer.dart';
import '../models/method_constants.dart';
import '../widgets/customer_tile.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  @override
  Widget build(BuildContext context) {
    final customerProvider = ref.watch(customerNotifierProvider);
    final customerNotifier = ref.read(customerNotifierProvider.notifier);
    final searchProvider = ref.watch(customerSearchNotifierProvider);
    final searchNotifier = ref.read(customerSearchNotifierProvider.notifier);

    return customerProvider.when(
        data: ((customers) {
          final isSearchEmpty = searchProvider.isEmpty;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: searchProvider,
                        decoration: InputDecoration(
                            prefixIconColor: primaryColor,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.search,
                            ),
                            hintText: "Search",
                            labelText: "Search Customers"),
                        onChanged: (s) {
                          searchNotifier.setSearch(s);
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: isSearchEmpty
                      ? ListView.builder(
                          itemCount: customers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final customer = customers[index];
                            return CustomerTile(customer: customer);
                          },
                        )
                      : StreamBuilder<List<Customer>>(
                          stream:
                              customerNotifier.searchCustomers(searchProvider),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            final filteredCustomers = snapshot.data ?? [];
                            return ListView.builder(
                                itemCount: filteredCustomers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final customer = filteredCustomers[index];
                                  return CustomerTile(customer: customer);
                                });
                          },
                        ),
                ),
              ],
            ),
          );
        }),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')));
  }
}
