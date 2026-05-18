import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/models/customer.dart';
import 'package:yala_pay/models/invoice.dart';
import 'package:yala_pay/repositories/yalaPay_app_repo.dart';

class InvoiceNotifier extends Notifier<List<Invoice>>{
  final _invoicesRepo = AppRepo();
  List<Invoice> _allInvoices = [];
  
  @override
  List<Invoice> build() {
    initializeInvoices();
    return [];
  }
  
  void initializeInvoices() async {
    List<Invoice> invoices = await _invoicesRepo.loadInvoices();
    _allInvoices = invoices;
    state = _allInvoices;
  }

  void setCustomerNames(List<Customer> customers){
    var invoices = [...state];
    for(var invoice in invoices){
      Customer customer = customers.firstWhere((cust) => cust.id == invoice.customerId);
      invoice.customerName = customer.companyName;
    }
    state = List.from(invoices);
  }


// void setCustomerNames(List<Customer> customers) {
//   // Create a new list of invoices with updated customer names
//   state = state.map((invoice) {
//     // Find the customer by id and get the company name
//     final customer = customers.firstWhere((cust) => cust.id == invoice.customerId, orElse: () => null);
//     return invoice.copyWith(customerName: customer?.companyName ?? invoice.customerName);
//   }).toList();
// }
  void deleteInvoice(Invoice invoice) {
    var invoices = [...state];
    // ignore: prefer_typing_uninitialized_variables
    var toBeRemoved; 
    for (var inv in invoices){
      if(invoice.id == inv.id){
        toBeRemoved = inv;
        break;
      }
    }
    invoices.remove(toBeRemoved);
    state = List.from(invoices);
  }
  void searchInvoice(String q) {
    if (q.isNotEmpty) {
      var startsWith = _allInvoices
          .where((i) =>
              (i.customerName.toLowerCase().startsWith(q.toLowerCase())) || 
              ("${i.amount}".startsWith(q)) ||
              ("${i.dueDate?.year}".startsWith(q)) ||
              ("${i.dueDate?.month}".startsWith(q)) ||
              ("${i.dueDate?.day}".startsWith(q))
            ).toList();
      var contains = _allInvoices
          .where((i) => 
              ((i.customerName.toLowerCase().contains(q.toLowerCase())) && 
              (!i.customerName.toLowerCase().startsWith(q.toLowerCase()))) ||
              (("${i.amount}".contains(q)) && (!"${i.amount}".startsWith(q))) ||
              (("${i.dueDate?.year}".contains(q)) && (!"${i.dueDate?.year}".startsWith(q))) ||
              (("${i.dueDate?.month}".contains(q)) && (!"${i.dueDate?.month}".startsWith(q))) ||
              (("${i.dueDate?.day}".contains(q)) && (!"${i.dueDate?.day}".startsWith(q)))
            ).toList();

      state = [...startsWith, ...contains];
    } else {
      state = _allInvoices;
    }
  }

  void addUpdateInvoice(
    {required id,
    required customerName,
    required amount,
    required invoiceDate,
    required dueDate,
    required List<Customer> customers,}) {
      final existingInvoiceIndex = state.indexWhere((i) => i.id == id);
      if (existingInvoiceIndex != -1) {
        final updatedInvoice = Invoice(
            id: id,
            customerId: customers.firstWhere((cust) => cust.companyName == customerName).id,
            customerName: customerName,
            amount: amount,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
          );
        state = [
          ...state.sublist(0, existingInvoiceIndex),
          updatedInvoice,
          ...state.sublist(existingInvoiceIndex + 1)
        ];
      } else {
        final newInvoice = Invoice(
            id: generateId(),
            customerId: customers.firstWhere((cust) => cust.companyName == customerName).id,
            customerName: customerName,
            amount: amount,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
          );
        state = [...state, newInvoice];
      }
  }

  String generateId() {
    int newId = int.parse(state[state.length - 1].id) + 1;
    return "$newId";
  }


}

final invoiceNotifierProvider = 
  NotifierProvider<InvoiceNotifier, List<Invoice>>(() => InvoiceNotifier());