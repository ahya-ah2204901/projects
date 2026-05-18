import 'package:go_router/go_router.dart';
import 'package:yala_pay/screens/cheque_deposit_add_screen.dart';
import 'package:yala_pay/screens/cheque_deposit_details_screen.dart';
import 'package:yala_pay/screens/cheque_deposit_update_screen.dart';
import 'package:yala_pay/screens/cheque_details_screen.dart';
import 'package:yala_pay/screens/cheque_image_screen.dart';
import 'package:yala_pay/screens/cheque_report_screen.dart';
import 'package:yala_pay/screens/customer_add_update_screen.dart';
import 'package:yala_pay/screens/customer_details_screen.dart';
import 'package:yala_pay/screens/customers_screen.dart';
import 'package:yala_pay/screens/dashboard_screen.dart';
import 'package:yala_pay/screens/invoice_add_update_screen.dart';
import 'package:yala_pay/screens/invoice_details_screen.dart';
import 'package:yala_pay/screens/invoices_report_screen.dart';
import 'package:yala_pay/screens/invoices_screen.dart';
import 'package:yala_pay/screens/login_screen.dart';
import 'package:yala_pay/screens/payments_details_screens.dart';
import 'package:yala_pay/screens/signup_screen.dart';
import '../screens/cheques_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/payment_add_update_screen.dart';

class AppRouter {
  static const login = (name: 'login', path: '/');
  static const signup = (name: 'signup', path: '/signup');
  static const dashboard = (name: 'dashboard', path: '/dashboard');
  static const customers = (name: 'customers', path: '/customers');
  static const invoices = (name: 'invoices', path: '/invoices');
  static const cheques = (name: 'cheques', path: '/cheques');

  static const customerDetails = (
    name: 'customer_details',
    path: '/customers/customer_details/:customerId'
  );
  static const customerAddUpdate = (
    name: 'customer_add_update',
    path: '/customers/customer_details/customer_add_update/:customerId'
  );
  static const invoiceDetails =
      (name: 'invoice_details', path: '/invoices/invoice_details/:invoiceId');
  static const paymentDetails = (
    name: 'payment_details',
    path: '/invoices/invoice_details/:invoiceId/payment_details/:paymentId'
  );
  static const invoiceAddUpdate = (
    name: 'invoice_add_update',
    path: '/invoices/invoice_details/invoice_add_update/:invoiceId'
  );
  static const chequeDetails =
      (name: 'cheque_details', path: '/cheques/cheque_details/:chequeNo');
  static const chequeDepositDetails = (
    name: 'cheque_deposit_details',
    path: '/cheques/cheque_deposit_details/:chequeDepId'
  );
  static const chequeDepositAdd = (
    name: 'cheque_deposit_add',
    path: '/cheques/cheque_deposit_add/:chequeDepId'
  );
  static const chequeDepositUpdate = (
    name: 'cheque_deposit_update',
    path: '/cheques/cheque_deposit_details/cheque_deposit_update/:chequeDepId'
  );
  // static const paymentAddUpdate = (
  //   name: 'payment_add_update',
  //   path:
  //       '/invoices/invoice_details/:invoiceId/payment_details/payment_add_update/:paymentId'
  // );
  static const paymentAddUpdate = (
    name: 'payment_add_update',
    path:
        '/invoices/invoice_details/:invoiceId/payment_details/payment_add_update/:paymentId'
  );
  static const chequeImage = (
    name: 'cheque_image',
    path: '/invoices/invoice_details/payment_details/cheque_image/:chequeFilePath'
  );
  static const invoicesReport =
      (name: 'invoices_report', path: '/invoices/invoices_report');

  static const chequeReport =
      (name: 'cheque_report', path: '/invoices/cheque_report');

  static final router = GoRouter(initialLocation: login.path, routes: [
    GoRoute(
        path: login.path,
        name: login.name,
        builder: (context, state) => const LoginScreen()),
    GoRoute(
        path: signup.path,
        name: signup.name,
        builder: (context, state) => const SignUpScreen()),
    ShellRoute(
        builder: (context, state, child) => ShellScreen(body: child),
        routes: [
          GoRoute(
              path: dashboard.path,
              name: dashboard.name,
              builder: (context, state) => const DashboardScreen()),
          GoRoute(
              path: customers.path,
              name: customers.name,
              builder: (context, state) => const CustomersScreen()),
          GoRoute(
              path: invoices.path,
              name: invoices.name,
              builder: (context, state) => const InvoicesScreen()),
          GoRoute(
              path: cheques.path,
              name: cheques.name,
              builder: (context, state) => const ChequesScreen())
        ]),
    GoRoute(
        path: customerDetails.path,
        name: customerDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['customerId']!;
          return CustomerDetailsScreen(customerId: id);
        }),
    GoRoute(
        path: customerAddUpdate.path,
        name: customerAddUpdate.name,
        builder: (context, state) {
          final String id = state.pathParameters['customerId']!;
          return CustomerAddUpdateScreen(customerId: id);
        }),
    GoRoute(
        path: invoiceDetails.path,
        name: invoiceDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['invoiceId']!;
          return InvoiceDetailsScreen(invoiceId: id);
        }),
    GoRoute(
        path: paymentDetails.path,
        name: paymentDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['paymentId']!;
          return PaymentDetailsScreen(paymentId: id);
        }),
    GoRoute(
        path: invoiceAddUpdate.path,
        name: invoiceAddUpdate.name,
        builder: (context, state) {
          final String id = state.pathParameters['invoiceId']!;
          return InvoiceAddUpdateScreen(invoiceId: id);
        }),
    GoRoute(
        path: chequeDetails.path,
        name: chequeDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['chequeNo']!;
          return ChequeDetailsScreen(chequeNo: int.parse(id));
        }),
    GoRoute(
        path: chequeDepositDetails.path,
        name: chequeDepositDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['chequeDepId']!;
          return ChequeDepositDetailsScreen(chequeDepId: id);
        }),
    GoRoute(
        path: chequeDepositAdd.path,
        name: chequeDepositAdd.name,
        builder: (context, state) {
          final String id = state.pathParameters['chequeDepId']!;
          return ChequeDepositAddScreen(chequeDepId: id);
        }),
    GoRoute(
        path: chequeDepositUpdate.path,
        name: chequeDepositUpdate.name,
        builder: (context, state) {
          final String id = state.pathParameters['chequeDepId']!;
          return ChequeDepositUpdateScreen(chequeDepId: id);
        }),
    GoRoute(
        path: chequeReport.path,
        name: chequeReport.name,
        builder: (context, state) => const ChequeReportScreen()),
    GoRoute(
        path: paymentAddUpdate.path,
        name: paymentAddUpdate.name,
        builder: (context, state) {
          final String id = state.pathParameters['paymentId']!;
          final String invoiceId = state.pathParameters['invoiceId']!;
          return PaymentAddUpdateScreen(
            paymentId: id,
            invoiceId: invoiceId,
          );
        }),
    GoRoute(
        path: chequeImage.path,
        name: chequeImage.name,
        builder: (context, state) {
          final String? uri = state.pathParameters['chequeFilePath']!;
          return ChequeImageScreen(
            chequeFilePath: uri,
          );
        }),
    GoRoute(
        path: invoicesReport.path,
        name: invoicesReport.name,
        builder: (context, state) => const InvoicesReportScreen()),
  ]);
}
