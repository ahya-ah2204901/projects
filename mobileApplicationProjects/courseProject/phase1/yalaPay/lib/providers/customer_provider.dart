import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';
import '../models/customer.dart';

class CustomerNotifier extends Notifier<List<Customer>> {
  final _customersRepo = AppRepo();
  List<Customer> _allCustomers = [];

  @override
  List<Customer> build() {
    initializeCustomers();
    return [];
  }

  void initializeCustomers() async {
    List<Customer> customers = await _customersRepo.loadCustomers();
    _allCustomers = customers;
    state = _allCustomers;
  }

  void searchCustomers(String q) {
    if (q.isNotEmpty) {
      var startsWith = _allCustomers
          .where((c) =>
              (c.companyName.toLowerCase().startsWith(q.toLowerCase()) ||
                  c.contactDetails.firstName
                      .toLowerCase()
                      .startsWith(q.toLowerCase())))
          .toList();
      var contains = _allCustomers
          .where((c) => (c.companyName
                      .toLowerCase()
                      .contains(q.toLowerCase()) &&
                  (!c.companyName.toLowerCase().startsWith(q.toLowerCase())) ||
              c.contactDetails.firstName
                      .toLowerCase()
                      .contains(q.toLowerCase()) &&
                  (!c.contactDetails.firstName
                      .toLowerCase()
                      .startsWith(q.toLowerCase()))))
          .toList();

      state = [...startsWith, ...contains];
    } else {
      state = _allCustomers;
    }
  }

  void deleteCustomer(Customer customer) {
    _allCustomers = _allCustomers.where((c) => c.id != customer.id).toList();
    state = state.where((c) => c.id != customer.id).toList();
  }

  String generateId() {
    // will fix later
    int newId = int.parse(state[state.length - 1].id) + 1;
    return "$newId";
  }

  void addUpdateCustomer(
      {required id,
      required companyName,
      required country,
      required city,
      required street,
      required firstName,
      required lastName,
      required email,
      required mobile}) {
    final existingCustomerIndex = state.indexWhere((c) => c.id == id);
    if (existingCustomerIndex != -1) {
      final updatedCustomer = Customer(
          id: id,
          companyName: companyName,
          address: Address(street: street, city: city, country: country),
          contactDetails: ContactDetails(
            firstName: firstName,
            lastName: lastName,
            email: email,
            mobile: mobile,
          ));
      state = [
        ...state.sublist(0, existingCustomerIndex),
        updatedCustomer,
        ...state.sublist(existingCustomerIndex + 1)
      ];
    } else {
      final newCustomer = Customer(
          id: generateId(),
          companyName: companyName,
          address: Address(street: street, city: city, country: country),
          contactDetails: ContactDetails(
              firstName: firstName,
              lastName: lastName,
              email: email,
              mobile: mobile));
      state = [...state, newCustomer];
    }
  }
}

final customerNotifierProvider =
    NotifierProvider<CustomerNotifier, List<Customer>>(
        () => CustomerNotifier());
