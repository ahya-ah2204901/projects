import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:yala_pay/models/customer.dart';

class CustomerRepo {
  final CollectionReference customerRef;

  CustomerRepo({required this.customerRef});

  /// reads from customers json file
  Future<void> initializeCustomers() async {
    final snapshot = await customerRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/customers.json');
        var customerJsonList = jsonDecode(data);
        for (var customerMap in customerJsonList) {
          final docId = customerRef.doc().id; // empty doc
          // creating a new customer instead of changing the id as id is final
          Customer customer = Customer.fromMap(customerMap);
          final newCustomer = Customer(
              id: docId,
              companyName: customer.companyName,
              address: customer.address,
              contactDetails: customer.contactDetails);
          await customerRef.doc(docId).set(newCustomer.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing customers: $e');
      }
    }
  }

  /// observe all customers
  Stream<List<Customer>> observeCustomers() {
    return customerRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// get a customer by ID
  Future<Customer> getCustomerById(String id) async {
    final snapshot = await customerRef.doc(id).get();
    return Customer.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  /// add or update a customer
  Future<void> addUpdateCustomer(Customer customer) async {
    if (customer.id != '-1') {
      await customerRef.doc(customer.id).update(customer.toMap());
    } else {
      final docId = customerRef.doc().id; // empty doc
      // creating a new customer instead of changing the id as it is final
      final newCustomer = Customer(
        id: docId,
        companyName: customer.companyName,
        address: customer.address,
        contactDetails: customer.contactDetails,
      );
      await customerRef.doc(docId).set(newCustomer.toMap());
    }
  }

  /// delete a customer
  Future<void> deleteCustomer(Customer customer) async {
    await customerRef.doc(customer.id).delete();
  }

  /// search customers by (first) name or company name
  Stream<List<Customer>> searchCustomers(String q) {
    final query = q.toLowerCase();

    final filtered = customerRef.where(Filter.or(
      Filter.and(
        Filter("companyNameLower", isGreaterThanOrEqualTo: query),
        Filter("companyNameLower", isLessThan: "$query\uf8ff"),
      ),
      Filter.and(
        Filter("contactDetails.firstNameLower", isGreaterThanOrEqualTo: query),
        Filter("contactDetails.firstNameLower", isLessThan: "$query\uf8ff"),
      ),
    ));

    return filtered.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  
}
