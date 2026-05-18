import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/customer_provider.dart';
import 'package:yala_pay/providers/customer_search_provider.dart';
import '../models/color_constants.dart';
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
                    customerNotifier.searchCustomers(s);
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customerProvider.length,
              itemBuilder: (BuildContext context, int index) {
                final customer = customerProvider[index];
                return CustomerTile(customer: customer);
              },
            ),
          ),
        ],
      ),
    );
  }
}
