import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/payment.dart';

class PaymentRepo {
  final CollectionReference paymentRef;
  final CollectionReference invoiceRef;

  PaymentRepo({required this.paymentRef, required this.invoiceRef});

  Future<void> initializePayments() async {
    final snapshot = await paymentRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      try {
        String data = await rootBundle.loadString('assets/data/payments.json');
        var paymentJsonList = jsonDecode(data);

        String invoiceData =
            await rootBundle.loadString('assets/data/invoices.json');
        var invoiceJsonList = jsonDecode(invoiceData);

        for (var paymentMap in paymentJsonList) {
          final docId = paymentRef.doc().id;
          Payment payment = Payment.fromMap(paymentMap);

          Invoice? matchedInvoice;

          for (var invoiceMap in invoiceJsonList) {
            Invoice invoice = Invoice.fromMap(invoiceMap);
            if (invoice.id == payment.invoiceNo) {
              final invoiceQuerySnapshot = await invoiceRef
                  .where("customerName", isEqualTo: invoice.customerName)
                  .where("amount", isEqualTo: invoice.amount)
                  .get();

              if (invoiceQuerySnapshot.docs.isNotEmpty) {
                final matchingInvoiceDoc = invoiceQuerySnapshot.docs.first;
                matchedInvoice = Invoice.fromMap(
                    matchingInvoiceDoc.data() as Map<String, dynamic>);
                print(matchedInvoice.customerName);
                break;
              }
            }
          }

          final newPayment = Payment(
              id: docId,
              paymentMode: payment.paymentMode,
              amount: payment.amount,
              chequeNo:
                  payment.paymentMode == 'Cheque' ? payment.chequeNo : null,
              invoiceNo: matchedInvoice != null
                  ? matchedInvoice.id
                  : payment.invoiceNo,
              paymentDate: payment.paymentDate);
          await paymentRef.doc(docId).set(newPayment.toMap());
        }
      } on Exception catch (e) {
        print('Error occurred while initializing payments: $e');
      }
    }
  }

  Stream<List<Payment>> observePayments() {
    return paymentRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  //add and update
  Future<void> addUpdatePayment(Payment payment) async {
    if (payment.id != '-1') {
      await paymentRef.doc(payment.id).update(payment.toMap());
    } else {
      final docId = paymentRef.doc().id;
      final newPayment = Payment(
          id: docId,
          paymentMode: payment.paymentMode,
          amount: payment.amount,
          chequeNo: payment.paymentMode == 'Cheque' ? payment.chequeNo : null,
          invoiceNo: payment.invoiceNo,
          paymentDate: payment.paymentDate);
      await paymentRef.doc(docId).set(newPayment.toMap());
    }
  }

  //delete
  Future<void> deletePayment(Payment payment) async {
    await paymentRef.doc(payment.id).delete();
  }

  Stream<List<Payment>> searchPayment(String query) {
    final q = query.toLowerCase();
    
    final filtered = paymentRef.where(Filter.and(
        Filter("paymentModeLower", isGreaterThanOrEqualTo: query),
        Filter("paymentModeLower", isLessThan: '$query\uf8ff')));
    return filtered.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  

  //get by ID
  Future<Payment?> getPaymentById(String id) async {
    try {
      final snapshot = await paymentRef.doc(id).get();
      if (snapshot.exists) {
        return Payment.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } on Exception catch (e) {
      print('Error occurred while getting payment: $e');
      return null;
    }
  }
}
