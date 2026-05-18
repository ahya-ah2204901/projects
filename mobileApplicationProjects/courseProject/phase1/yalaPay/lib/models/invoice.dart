class Invoice {
  String id;
  String customerId;
  String customerName;
  double amount;
  DateTime? invoiceDate;
  DateTime? dueDate;

  Invoice(
      {this.id = '',
      this.customerId = '',
      this.customerName = '',
      this.amount = 0.0,
      this.invoiceDate,
      this.dueDate});

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      amount: map['amount'] ?? 0.0,
      invoiceDate: DateTime.parse(map['invoiceDate']),
      dueDate: DateTime.parse(map['dueDate']),
    );
  }
}
