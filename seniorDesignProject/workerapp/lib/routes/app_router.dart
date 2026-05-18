import 'package:go_router/go_router.dart';
import 'package:workerapp/screens/alert_details_screen.dart';
import 'package:workerapp/screens/alerts_screen.dart';
import 'package:workerapp/screens/data_screen.dart';
import 'package:workerapp/screens/supervisor_home_screen.dart';
import 'package:workerapp/screens/verify_email_screen.dart';
import 'package:workerapp/screens/worker_home_screen.dart';
import 'package:workerapp/screens/login_screen.dart';
import 'package:workerapp/screens/reading_details_screen.dart';
import 'package:workerapp/screens/shell_screen.dart';
import 'package:workerapp/screens/signup_screen.dart';
import 'package:workerapp/screens/worker_readings_screen.dart';
import 'package:workerapp/screens/workers_screen.dart';

class AppRouter {
  static const login = (name: 'login', path: '/');
  static const signup = (name: 'signup', path: '/signup');
  static const verifyEmail = (
    name: 'verify_email',
    path: '/signup/verify_email',
  );
  static const workerHome = (name: 'worker_home', path: '/worker_home');
  static const supervisorHome = (
    name: 'supervisor_home',
    path: '/supervisor_home',
  );
  static const alerts = (name: 'alerts', path: '/alerts');
  static const workers = (name: 'workers', path: '/workers');
  static const data = (name: 'data', path: '/data');

  static const workerReadings = (
    name: 'worker_readings',
    path: '/workers/worker_readings/:workerId',
  );

  static const alertDetails = (
    name: 'alert_details',
    path: '/alerts/alert_details/:alertId',
  );

  static const readingDetails = (
    name: 'reading_details',
    path: '/data/reading_details/:readingId',
  );

  static final router = GoRouter(
    initialLocation: login.path,
    routes: [
      GoRoute(
        path: login.path,
        name: login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup.path,
        name: signup.name,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: verifyEmail.path,
        name: verifyEmail.name,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(body: child),
        routes: [
          GoRoute(
            path: workerHome.path,
            name: workerHome.name,
            builder: (context, state) => const WorkerHomeScreen(),
          ),
          GoRoute(
            path: supervisorHome.path,
            name: supervisorHome.name,
            builder: (context, state) => const SupervisorHomeScreen(),
          ),
          GoRoute(
            path: alerts.path,
            name: alerts.name,
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: workers.path,
            name: workers.name,
            builder: (context, state) => const WorkersScreen(),
          ),
          GoRoute(
            path: data.path,
            name: data.name,
            builder: (context, state) => const DataScreen(),
          ),
        ],
      ),
      GoRoute(
        path: workerReadings.path,
        name: workerReadings.name,
        builder: (context, state) {
          final String id = state.pathParameters['workerId']!;
          return WorkerReadingsScreen(workerId: id);
        },
      ),
      GoRoute(
        path: alertDetails.path,
        name: alertDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['alertId']!;
          return AlertDetailsScreen(alertId: id);
        },
      ),
      GoRoute(
        path: readingDetails.path,
        name: readingDetails.name,
        builder: (context, state) {
          final String id = state.pathParameters['readingId']!;
          return ReadingDetailsScreen(readingId: id);
        },
      ),
    ],
  );
}
