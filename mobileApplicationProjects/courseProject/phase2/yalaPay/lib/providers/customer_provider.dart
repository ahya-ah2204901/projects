import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/customer_repo.dart';
import '../models/customer.dart';

class CustomerNotifier extends AsyncNotifier<List<Customer>> {
  late final CustomerRepo _customerRepo;

  /// observe the list of all customers, after initializing
  @override
  Future<List<Customer>> build() async {
    _customerRepo = await ref.watch(customerRepoProvider.future);
    await _customerRepo.initializeCustomers();
    _customerRepo.observeCustomers().listen((customers) {
      state = AsyncValue.data(customers);
    }).onError((e) {
      print('Error building customer provider: $e');
    });
    return [];
  }

  /// get a customer by ID
  Future<Customer> getCustomerById(String id) async {
    return await _customerRepo.getCustomerById(id);
  }

  /// add or update a customer
  Future<void> addUpdateCustomer(Customer customer) async {
    await _customerRepo.addUpdateCustomer(customer);
  }

  /// delete a customer
  Future<void> deleteCustomer(Customer customer) async {
    await _customerRepo.deleteCustomer(customer);
  }

  /// search customers by (first) name or company name
  Stream<List<Customer>> searchCustomers(String q) {
    return _customerRepo.searchCustomers(q);
  }

}

final customerNotifierProvider =
AsyncNotifierProvider<CustomerNotifier, List<Customer>>(
        () => CustomerNotifier());


