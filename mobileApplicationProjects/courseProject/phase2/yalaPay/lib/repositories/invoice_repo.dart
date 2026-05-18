import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:yala_pay/models/customer.dart';
import 'package:yala_pay/models/invoice.dart';

import '../models/payment.dart';

class InvoiceRepo {
  final CollectionReference invoiceRef;
  final CollectionReference customerRef;
  final CollectionReference paymentRef;
  final CollectionReference chequeRef;

  InvoiceRepo(
      {required this.invoiceRef,
      required this.customerRef,
      required this.paymentRef,
      required this.chequeRef});

  //reads from Json file
  Future<void> initializeInvoices() async {
    final snapshot = await invoiceRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/invoices.json');
        var invoiceJsonList = jsonDecode(data);

        String customerData =
            await rootBundle.loadString('assets/data/customers.json');
        var customerJsonList = jsonDecode(customerData);

        for (var invoiceMap in invoiceJsonList) {
          final docId = invoiceRef.doc().id;
          Invoice invoice = Invoice.fromMap(invoiceMap);

          Customer? matchedCustomer;

          for (var customerMap in customerJsonList) {
            Customer customer = Customer.fromMap(customerMap);
            if (customer.id == invoice.customerId) {
              final customerQuerySnapshot = await customerRef
                  .where("companyName", isEqualTo: customer.companyName)
                  .get();

              if (customerQuerySnapshot.docs.isNotEmpty) {
                final matchingCustomerDoc = customerQuerySnapshot.docs.first;
                matchedCustomer = Customer.fromMap(
                    matchingCustomerDoc.data() as Map<String, dynamic>);
                break;
              }
            }
          }
          final newInvoice = Invoice(
              id: docId,
              amount: invoice.amount,
              customerId: matchedCustomer != null
                  ? matchedCustomer.id
                  : invoice.customerId,
              customerName: invoice.customerName,
              dueDate: invoice.dueDate,
              invoiceDate: invoice.invoiceDate);
          await invoiceRef.doc(docId).set(newInvoice.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing invoices: $e');
      }
    }
  }

  Stream<List<Invoice>> observeInvoices() {
    return invoiceRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  //add and update
  Future<void> addUpdateInvoice(Invoice invoice) async {
    if (invoice.id != '-1') {
      await invoiceRef.doc(invoice.id).update(invoice.toMap());
    } else {
      final docId = invoiceRef.doc().id;
      final newInvoice = Invoice(
          id: docId,
          amount: invoice.amount,
          customerId: invoice.customerId,
          customerName: invoice.customerName,
          dueDate: invoice.dueDate,
          invoiceDate: invoice.invoiceDate);
      await invoiceRef.doc(docId).set(newInvoice.toMap());
    }
  }

  //delete
  Future<void> deleteInvoice(Invoice invoice) async {
    await invoiceRef.doc(invoice.id).delete();
  }

  //search

  Stream<List<Invoice>> searchInvoice(String query) {
    final q = query.toLowerCase();

    final filtered = invoiceRef.where(Filter.or(
      Filter.and(Filter("customerNameLower", isGreaterThanOrEqualTo: q),
          Filter("customerNameLower", isLessThan: '$q\uf8ff')),
      Filter("customerNameArray", arrayContains: q),
    ));
    return filtered.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  //get by ID
  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final snapshot = await invoiceRef.doc(id).get();
      if (snapshot.exists) {
        return Invoice.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } on Exception catch (e) {
      print('Error occurred while getting invoices: $e');
      return null;
    }
  }

  Future<List<double>> totalInvoicesAllByDues() async {
    List<double> total = [0.0, 0.0, 0.0]; // [overall, 30, 60] days

    DateTime now = DateTime.now();
    DateTime dueIn30Days = now.add(const Duration(days: 30));
    DateTime dueIn60Days = now.add(const Duration(days: 60));

    final snapshotsDueResults = await Future.wait([
      invoiceRef.where('dueDate', isGreaterThanOrEqualTo: now.toString()).get(),
      invoiceRef
          .where('dueDate', isGreaterThanOrEqualTo: now.toString())
          .where('dueDate', isLessThanOrEqualTo: dueIn30Days.toString())
          .get(),
      invoiceRef
          .where('dueDate', isGreaterThanOrEqualTo: now.toString())
          .where('dueDate', isLessThanOrEqualTo: dueIn60Days.toString())
          .get()
    ]);
    //dueOverall
    for (final data in snapshotsDueResults[0].docs) {
      total[0] += (data['amount'] ?? 0).toDouble();
    }
    //duein30
    for (final data in snapshotsDueResults[1].docs) {
      total[1] += (data['amount'] ?? 0).toDouble();
    }
    //duein60
    for (final data in snapshotsDueResults[2].docs) {
      total[2] += (data['amount'] ?? 0).toDouble();
    }

    return total;
  }

// filter invoices for report, returns the invoices & the totals
  Future<Map<String, dynamic>> filterInvoices(
      String startDate, String endDate, String status) async {
    try {
      // get invoices in the date range
      final invSnapshot = await invoiceRef
          .where("dueDate", isLessThanOrEqualTo: endDate)
          .where("dueDate", isGreaterThanOrEqualTo: startDate)
          .get();

      // map to invoice objects
      List<Invoice> invoices = invSnapshot.docs
          .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // make a list of their ids
      List<String> invoiceIds = invoices.map((invoice) => invoice.id).toList();

      // get only payments that relate to these invoices
      final pySnapshot =
          await paymentRef.where("invoiceNo", whereIn: invoiceIds).get();

      // map to payment objects
      List<Payment> payments = pySnapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // make a list of the cheque numbers that are included in the payments
      List<int> chequeNos = payments
          .where((payment) => payment.paymentMode == 'Cheque')
          .map((payment) => payment.chequeNo!)
          .toSet()
          .toList();

      // get only relevant cheques & their status
      Map<int, String> chequeStatusMap = {};
      if (chequeNos.isNotEmpty) {
        final chequeSnapshot =
            await chequeRef.where("chequeNo", whereIn: chequeNos).get();
        chequeStatusMap = {
          for (var doc in chequeSnapshot.docs)
            (int.tryParse((doc.data() as Map<String, dynamic>)['chequeNo']
                    .toString()) ??
                -1): (doc.data() as Map<String, dynamic>)['status']
        };
      }

      // filter payments, exclude invalid cheques
      List<Payment> validPayments = payments.where((payment) {
        if (payment.paymentMode == 'Cheque') {
          return chequeStatusMap[payment.chequeNo] != 'Returned';
        }
        return true;
      }).toList();

      double totalAmount = 0.0;
      double paidTotal = 0.0;
      double unpaidTotal = 0.0;
      double partiallyPaidTotal = 0.0;

      // filter based on status & calculate totals
      List<Invoice> filteredInvoices = [];
      for (var invoice in invoices) {
        // total payments for this invoice
        double totalPayments = validPayments
            .where((payment) => payment.invoiceNo == invoice.id)
            .fold(0.0, (x, y) => x + y.amount);

        // add to totals
        totalAmount = totalAmount + invoice.amount;
        if (totalPayments == invoice.amount) {
          paidTotal = paidTotal + invoice.amount;
        } else if (totalPayments == 0) {
          unpaidTotal = unpaidTotal + invoice.amount;
        } else if (totalPayments > 0 && totalPayments < invoice.amount) {
          partiallyPaidTotal = partiallyPaidTotal + invoice.amount;
        }

        // filter based on status
        if (status == 'All' ||
            (status == 'Paid' && totalPayments == invoice.amount) ||
            (status == 'Partially Paid' &&
                totalPayments > 0 &&
                totalPayments < invoice.amount) ||
            (status == 'Unpaid' && totalPayments == 0)) {
          filteredInvoices.add(invoice);
        }
      }

      // return filtered invoices and totals
      return {
        "filteredInvoices": filteredInvoices,
        "totals": {
          "totalAmount": totalAmount,
          "paidTotal": paidTotal,
          "unpaidTotal": unpaidTotal,
          "partiallyPaidTotal": partiallyPaidTotal,
          "invoiceCount": filteredInvoices.length
        }
      };
    } catch (e) {
      print('Error filtering invoices: $e');
      return {
        "filteredInvoices": [],
        "totals": {
          "totalAmount": 0.0,
          "paidTotal": 0.0,
          "unpaidTotal": 0.0,
          "partiallyPaidTotal": 0.0,
          "invoiceCount": 0
        }
      };
    }
  }

  Future<double> getPendingBalance(Invoice invoice) async {
    try {
      // get all payments related to the invoice
      final pySnapshot =
          await paymentRef.where("invoiceNo", isEqualTo: invoice.id).get();

      // map payments to payment objects
      List<Payment> payments = pySnapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // get cheque numbers used in payments
      List<int> chequeNos = payments
          .where((payment) => payment.paymentMode == 'Cheque')
          .map((payment) => payment.chequeNo!)
          .toSet()
          .toList();

      // map of each cheque no. and status
      Map<int, String> chequeStatusMap = {};
      if (chequeNos.isNotEmpty) {
        final chSnapshot =
            await chequeRef.where("chequeNo", whereIn: chequeNos).get();
        chequeStatusMap = {
          for (var doc in chSnapshot.docs)
            int.tryParse((doc.data() as Map<String, dynamic>)['chequeNo']
                    .toString()) ??
                -1: (doc.data() as Map<String, dynamic>)['status']
        };
      }

      // filter valid payments based on cheque status
      List<Payment> validPayments = payments.where((payment) {
        if (payment.paymentMode == 'Cheque') {
          return chequeStatusMap[payment.chequeNo] != 'Returned';
        }
        return true;
      }).toList();

      // calculate total payments for the invoice
      double totalPayments = validPayments
          .where((payment) => payment.invoiceNo == invoice.id)
          .fold(0.0, (x, y) => x + y.amount);

      // calculate pending balance
      double pendingBalance = invoice.amount - totalPayments;

      // ensure pending balance is not negative (shouldn't happen but just in case)
      return pendingBalance >= 0 ? pendingBalance : 0.0;
    } catch (e) {
      print('Error calculating pending balance: $e');
      return -1.0; // Return -1 to indicate an error
    }
  }
}
