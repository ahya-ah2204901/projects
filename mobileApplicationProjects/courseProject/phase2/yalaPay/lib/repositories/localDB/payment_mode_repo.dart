import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/database/payment_mode_dao.dart';
import 'package:yala_pay/models/enums/payment_mode.dart';

class PaymentModeRepo {
  final PaymentModeDao paymentModeDao;

  PaymentModeRepo({required this.paymentModeDao});

  /// initialize payment modes
  Future<void> initializeData() async {
    final existingPaymentModes = await paymentModeDao.getPaymentModes();
    if (existingPaymentModes.isEmpty) {
      try {
        final String jsonData =
            await rootBundle.loadString('assets/data/payment-modes.json');
        final List<dynamic> paymentModeList = jsonDecode(jsonData);
        for (var mode in paymentModeList) {
          final paymentMode = PaymentMode(mode: mode as String);
          await paymentModeDao.addPaymentMode(paymentMode);
        }
        print('Successfully loaded payment modes');
      } on Exception catch (e) {
        print('Error initializing payment modes: $e');
      }
    }
  }

  /// get all payment modes
  Future<List<String>> getPaymentModes() => paymentModeDao.getPaymentModes();
}
