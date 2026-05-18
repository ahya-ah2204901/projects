import 'package:yala_pay/models/enums/bank.dart';

class BankAccount {
  String accountNo;
  Bank? bank;

  BankAccount({this.accountNo = '', this.bank});

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      accountNo: map['accountNo'] ?? 0,
      bank: _mapBank(map['bank']),
    );
  }

  static Bank _mapBank(String bank) {
    switch (bank) {
      case "Qatar National Bank":
        return Bank.QatarNationalBank;
      case "Doha Bank":
        return Bank.DohaBank;
      case "Commercial Bank":
        return Bank.CommercialBank;
      case "Qatar International Islamic Bank":
        return Bank.QatarInternationalIslamicBank;
      case "Qatar Islamic Bank":
        return Bank.QatarIslamicBank;
      case "Qatar Development Bank":
        return Bank.QatarDevelopmentBank;
      case "Arab Bank":
        return Bank.ArabBank;
      case "Ahli bank":
        return Bank.Ahlibank;
      case "Mashreq Bank":
        return Bank.MashreqBank;
      case "HSBC Bank Middle East":
        return Bank.HSBCBankMiddleEast;
      case "BNP Paribas":
        return Bank.BNPParibas;
      case "Bank Saderat Iran":
        return Bank.BankSaderatIran;
      case "United Bank ltd.":
        return Bank.UnitedBankltd;
      case "Standard Chartered Bank":
        return Bank.StandardCharteredBank;
      case "Masraf Al Rayan":
        return Bank.MasrafAlRayan;
      case "International Bank of Qatar":
        return Bank.InternationalBankofQatar;
      case "Barwa Bank":
        return Bank.BarwaBank;
      default:
        throw Exception('Unknown status: $bank');
    }
  }
}
