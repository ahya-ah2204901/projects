import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yala_pay/models/bank_account.dart';
import 'package:yala_pay/models/cheque.dart';
import 'package:yala_pay/models/cheque_deposit.dart';
import 'package:yala_pay/models/customer.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/models/payment.dart';
import 'package:yala_pay/models/user.dart';

class AppRepo {
  //reads from Customer Json File
  Future<List<Customer>> loadCustomers() async {
    String data = await rootBundle.loadString('assets/data/customers.json');
    var customerList = jsonDecode(data);
    List<Customer>? customers = [];
    for (var customerMap in customerList) {
      customers.add(Customer.fromMap(customerMap));
    }
    return customers;
  }

  //reads from User Json File
  Future<List<User>> loadUsers() async {
    String data = await rootBundle.loadString('assets/data/users.json');
    var userList = jsonDecode(data);
    List<User>? users = [];
    for (var userMap in userList) {
      users.add(User.fromMap(userMap));
    }
    return users;
  }

  //reads from Invoices Json File
  Future<List<Invoice>> loadInvoices() async {
    String data = await rootBundle.loadString('assets/data/invoices.json');
    var invoiceList = jsonDecode(data);
    List<Invoice>? invoices = [];
    for (var invoiceMap in invoiceList) {
      invoices.add(Invoice.fromMap(invoiceMap));
    }
    return invoices;
  }

  //reads from Payments Json File
  Future<List<Payment>> loadPayments() async {
    String data = await rootBundle.loadString('assets/data/payments.json');
    var paymentList = jsonDecode(data);
    List<Payment>? payments = [];
    for (var paymentMap in paymentList) {
      payments.add(Payment.fromMap(paymentMap));
    }
    return payments;
  }

  //reads from bank accounts Json File
  Future<List<BankAccount>> loadAccounts() async {
    String data = await rootBundle.loadString('assets/data/bank-accounts.json');
    var accountsList = jsonDecode(data);
    List<BankAccount>? accounts = [];
    for (var accountMap in accountsList) {
      accounts.add(BankAccount.fromMap(accountMap));
    }
    return accounts;
  }

  //reads from cheques Json File
  Future<List<Cheque>> loadCheques() async {
    String data = await rootBundle.loadString('assets/data/cheques.json');
    var chequeList = jsonDecode(data);
    List<Cheque>? cheques = [];
    for (var chequeMap in chequeList) {
      cheques.add(Cheque.fromMap(chequeMap));
    }
    return cheques;
  }

  //reads from cheque deposits Json File
  Future<List<ChequeDeposit>> loadChequeDeposits() async {
    String data =
        await rootBundle.loadString('assets/data/cheque-deposits.json');
    var chequeDepositList = jsonDecode(data);
    List<ChequeDeposit>? chequeDeposits = [];
    for (var chequeDepMap in chequeDepositList) {
      chequeDeposits.add(ChequeDeposit.fromMap(chequeDepMap));
    }
    return chequeDeposits;
  }
}
