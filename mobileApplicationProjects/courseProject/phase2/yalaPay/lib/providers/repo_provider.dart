import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/repositories/cheque_deposit_repo.dart';
import 'package:yala_pay/repositories/cheque_repo.dart';
import 'package:yala_pay/repositories/customer_repo.dart';
import 'package:yala_pay/repositories/image_repo.dart';
import 'package:yala_pay/repositories/invoice_repo.dart';
import 'package:yala_pay/repositories/localDB/bank_account_repo.dart';
import 'package:yala_pay/repositories/localDB/bank_repo.dart';
import 'package:yala_pay/repositories/localDB/cheque_status_repo.dart';
import 'package:yala_pay/repositories/localDB/country_city_repo.dart';
import 'package:yala_pay/repositories/localDB/deposit_status_repo.dart';
import 'package:yala_pay/repositories/localDB/invoice_status_repo.dart';
import 'package:yala_pay/repositories/localDB/payment_mode_repo.dart';
import 'package:yala_pay/repositories/localDB/return_reason_repo.dart';
import 'package:yala_pay/repositories/payment_repo.dart';
import 'package:yala_pay/repositories/user_repo.dart';

import '../database/app_database.dart';

/// firebase -------------------------------------------------------------------

final customerRepoProvider = FutureProvider<CustomerRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var customerRef = db.collection('customers');
  return CustomerRepo(customerRef: customerRef);
});

final chequeDepositRepoProvider =
    FutureProvider<ChequeDepositRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var chequeDepRef = db.collection('chequeDeposits');
  return ChequeDepositRepo(chequeDepRef: chequeDepRef);
});

final chequeRepoProvider = FutureProvider<ChequeRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var chequeRef = db.collection('cheques');
  print('chequeRef initialized: $chequeRef');
  return ChequeRepo(chequeRef: chequeRef);
});

final invoiceRepoProvider = FutureProvider<InvoiceRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var invoiceRef = db.collection('invoices');
  var customerRef = db.collection('customers');
  var paymentRef = db.collection('payments');
  var chequeRef = db.collection('cheques');
  return InvoiceRepo(
      invoiceRef: invoiceRef,
      customerRef: customerRef,
      paymentRef: paymentRef,
      chequeRef: chequeRef);
});

final paymentRepoProvider = FutureProvider<PaymentRepo>((ref) async {
  var db = FirebaseFirestore.instance;
  var paymentRef = db.collection('payments');
  var invoiceRef = db.collection('invoices');
  return PaymentRepo(paymentRef: paymentRef, invoiceRef: invoiceRef);
});

final usersRepoProvider = Provider<UserRepo>((ref) {
  var db = FirebaseFirestore.instance;
  var userRef = db.collection('users');
  return UserRepo(usersRef: userRef);
});

/// local database -------------------------------------------------------------

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return await $FloorAppDatabase.databaseBuilder('app_database.db').build();
});

final bankRepoProvider = FutureProvider<BankRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return BankRepo(bankDao: database.bankDao);
});

final bankAccountRepoProvider = FutureProvider<BankAccountRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return BankAccountRepo(bankAccountDao: database.bankAccountDao);
});

final chequeStatusRepoProvider = FutureProvider<ChequeStatusRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return ChequeStatusRepo(chequeStatusDao: database.chequeStatusDao);
});

final depositStatusRepoProvider =
    FutureProvider<DepositStatusRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return DepositStatusRepo(depositStatusDao: database.depositStatusDao);
});

final invoiceStatusRepoProvider =
    FutureProvider<InvoiceStatusRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return InvoiceStatusRepo(invoiceStatusDao: database.invoiceStatusDao);
});

final paymentModeRepoProvider = FutureProvider<PaymentModeRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return PaymentModeRepo(paymentModeDao: database.paymentModeDao);
});

final returnReasonRepoProvider = FutureProvider<ReturnReasonRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return ReturnReasonRepo(returnReasonDao: database.returnReasonDao);
});

final countryCityRepoProvider = FutureProvider<CountryCityRepo>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return CountryCityRepo(
      countryDao: database.countryDao, cityDao: database.cityDao);
});
