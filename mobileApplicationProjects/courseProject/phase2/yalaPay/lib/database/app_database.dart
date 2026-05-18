import 'dart:async';

import 'package:floor/floor.dart';
import 'package:yala_pay/database/bank_account_dao.dart';
import 'package:yala_pay/database/bank_dao.dart';
import 'package:yala_pay/database/cheque_status_dao.dart';
import 'package:yala_pay/database/city_dao.dart';
import 'package:yala_pay/database/country_dao.dart';
import 'package:yala_pay/database/deposit_status_dao.dart';
import 'package:yala_pay/database/invoice_status_dao.dart';
import 'package:yala_pay/database/payment_mode_dao.dart';
import 'package:yala_pay/database/return_reason_dao.dart';

import '../models/enums/bank.dart';
import '../models/enums/bank_account.dart';
import '../models/enums/cheque_status.dart';
import '../models/enums/city.dart';
import '../models/enums/country.dart';
import '../models/enums/deposit_status.dart';
import '../models/enums/invoice_status.dart';
import '../models/enums/payment_mode.dart';
import '../models/enums/return_reason.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
part 'app_database.g.dart';

@Database(
  version: 1,
  entities: [
    Bank,
    BankAccount,
    ChequeStatus,
    DepositStatus,
    InvoiceStatus,
    PaymentMode,
    ReturnReason,
    Country,
    City
  ],
)
abstract class AppDatabase extends FloorDatabase {
  BankDao get bankDao;
  BankAccountDao get bankAccountDao;
  ChequeStatusDao get chequeStatusDao;
  DepositStatusDao get depositStatusDao;
  InvoiceStatusDao get invoiceStatusDao;
  PaymentModeDao get paymentModeDao;
  ReturnReasonDao get returnReasonDao;
  CountryDao get countryDao;
  CityDao get cityDao;
}
