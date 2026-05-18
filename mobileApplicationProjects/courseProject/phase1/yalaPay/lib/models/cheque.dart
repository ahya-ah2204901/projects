import 'package:yala_pay/models/enums/bank.dart';
import 'package:yala_pay/models/enums/cheque_status.dart';
import 'package:yala_pay/models/enums/return_reason.dart';

class Cheque {
  int chequeNo;
  double amount;
  String drawer;
  late Bank bankName;
  ChequeStatus status;
  DateTime? receivedDate;
  DateTime? dueDate;
  String? chequeImageUri;
  ReturnReason? returnReason;
  DateTime? returnDate;
  DateTime? cashedDate;

  Cheque(
      {this.chequeNo = 0,
      this.amount = 0.0,
      this.drawer = '',
      required this.bankName,
      this.status = ChequeStatus.awaiting,
      this.receivedDate,
      this.dueDate,
      this.chequeImageUri = '',
      this.returnReason,
      this.returnDate,
      this.cashedDate});

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

  factory Cheque.fromMap(Map<String, dynamic> map) {
    return Cheque(
      chequeNo: map['chequeNo'] ?? 0,
      amount: map['amount'] ?? 0.0,
      drawer: map['drawer'] ?? '',
      bankName: _mapBank(map['bankName']),
      status: parseStatus(map['status']),
      receivedDate: DateTime.parse(map['receivedDate']),
      dueDate: DateTime.parse(map['dueDate']),
      chequeImageUri: map['chequeImageUri'] ?? '',
      returnReason: map['returnReason'] != null
          ? _mapReturnReason(map['returnReason'])
          : null,
      returnDate: map['returnDate'] != null
          ? DateTime.tryParse(map['returnDate'])
          : null,
      cashedDate: map['cashedDate'] != null
          ? DateTime.tryParse(map['cashedDate'])
          : null,
    );
  }

  static ChequeStatus parseStatus(String status) {
    return ChequeStatus.values.firstWhere(
      (s) => s.toString().split('.').last.toLowerCase() == status.toLowerCase(),
      orElse: () => ChequeStatus.awaiting,
    );
  }

  static ReturnReason? _mapReturnReason(String reason) {
    switch (reason) {
      case "No funds/insufficient funds":
        return ReturnReason.No_funds_insufficient_funds;
      case "Cheque post-dated, please represent on due date":
        return ReturnReason.Cheque_postdated_please_represent_on_due_date;
      case "Drawer's signature differs":
        return ReturnReason.Drawers_signature_differs;
      case "Alteration in date/words/figures requires drawer's full signature":
        return ReturnReason
            .Alteration_in_date_words_figures_requires_drawers_full_signature;
      case "Order cheque requires payee's endorsement":
        return ReturnReason.Order_cheque_requires_payees_endorsement;
      case "Not drawn on us":
        return ReturnReason.Not_drawn_on_us;
      case "Drawer deceased/bankrupt":
        return ReturnReason.Drawer_deceased_bankrupt;
      case "Account closed":
        return ReturnReason.Account_closed;
      case "Stopped by drawer due to cheque lost, bearer's bankruptcy or a judicial order":
        return ReturnReason
            .Stopped_by_drawer_due_to_cheque_lost_bearers_bankruptcy_or_a_judicial_order;
      case "Date/beneficiary name is required":
        return ReturnReason.Date_beneficiary_name_is_required;
      case "Presentment cycle expired":
        return ReturnReason.Presentment_cycle_expired;
      case "Already paid":
        return ReturnReason.Already_paid;
      case "Requires drawer's signature":
        return ReturnReason.Requires_drawers_signature;
      case "Cheque information and electronic data mismatch":
        return ReturnReason.Cheque_information_and_electronic_data_mismatch;
      default:
        return null;
    }
  }

  static String getBankString(Bank bankName) {
    switch (bankName) {
      case Bank.QatarNationalBank:
        return "Qatar National Bank";
      case Bank.DohaBank:
        return "Doha Bank";
      case Bank.CommercialBank:
        return "Commercial Bank";
      case Bank.QatarInternationalIslamicBank:
        return "Qatar International Islamic Bank";
      case Bank.QatarIslamicBank:
        return "Qatar Islamic Bank";
      case Bank.QatarDevelopmentBank:
        return "Qatar Development Bank";
      case Bank.ArabBank:
        return "Arab Bank";
      case Bank.Ahlibank:
        return "Ahli bank";
      case Bank.MashreqBank:
        return "Mashreq Bank";
      case Bank.HSBCBankMiddleEast:
        return "HSBC Bank Middle East";
      case Bank.BNPParibas:
        return "BNP Paribas";
      case Bank.BankSaderatIran:
        return "Bank Saderat Iran";
      case Bank.UnitedBankltd:
        return "United Bank ltd.";
      case Bank.StandardCharteredBank:
        return "Standard Chartered Bank";
      case Bank.MasrafAlRayan:
        return "Masraf Al Rayan";
      case Bank.InternationalBankofQatar:
        return "International Bank of Qatar";
      case Bank.BarwaBank:
        return "Barwa Bank";
      default:
        throw Exception('Unknown bank: $bankName');
    }
  }

  static String getReturnReasonString(ReturnReason reason) {
    switch (reason) {
      case ReturnReason.No_funds_insufficient_funds:
        return "No funds/insufficient funds";
      case ReturnReason.Cheque_postdated_please_represent_on_due_date:
        return "Cheque post-dated, please represent on due date";
      case ReturnReason.Drawers_signature_differs:
        return "Drawer's signature differs";
      case ReturnReason
            .Alteration_in_date_words_figures_requires_drawers_full_signature:
        return "Alteration in date/words/figures requires drawer's full signature";
      case ReturnReason.Order_cheque_requires_payees_endorsement:
        return "Order cheque requires payee's endorsement";
      case ReturnReason.Not_drawn_on_us:
        return "Not drawn on us";
      case ReturnReason.Drawer_deceased_bankrupt:
        return "Drawer deceased/bankrupt";
      case ReturnReason.Account_closed:
        return "Account closed";
      case ReturnReason
            .Stopped_by_drawer_due_to_cheque_lost_bearers_bankruptcy_or_a_judicial_order:
        return "Stopped by drawer due to cheque lost, bearer's bankruptcy or a judicial order";
      case ReturnReason.Date_beneficiary_name_is_required:
        return "Date/beneficiary name is required";
      case ReturnReason.Presentment_cycle_expired:
        return "Presentment cycle expired";
      case ReturnReason.Already_paid:
        return "Already paid";
      case ReturnReason.Requires_drawers_signature:
        return "Requires drawer's signature";
      case ReturnReason.Cheque_information_and_electronic_data_mismatch:
        return "Cheque information and electronic data mismatch";
      default:
        throw Exception('Unknown return reason: $reason');
    }
  }
}
