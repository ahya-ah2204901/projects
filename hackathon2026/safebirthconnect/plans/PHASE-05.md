# PHASE-05: Flutter Project Setup & Core

## Objective
Set up Flutter project with Riverpod, localization (Arabic + English), and core infrastructure (network, database, routing).

## Status: 🟢 Completed

## Tasks

### 5.1 Main App Entry Point

**main.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: SafeBirthApp(),
    ),
  );
}
```

### 5.2 App Configuration

**app.dart**:
```dart
class SafeBirthApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SafeBirth Connect',
      debugShowCheckedModeBanner: false,
      
      // Localization
      locale: locale,
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [...],
      
      // Theme (Sage green primary)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF81B29A),
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      
      // Router
      routerConfig: router,
    );
  }
}
```

### 5.3 Localization Setup

**core/localization/app_localizations.dart**:

1. Create `AppLocalizations` class with:
   - Constructor taking `Locale`
   - Static `of(context)` method
   - Static `delegate` property
   - Map of translations (ar, en)
   - `translate(key)` method

2. Create `_AppLocalizationsDelegate`:
   - `isSupported` for ar, en
   - `load` async method
   - `shouldReload` returns false

3. Create extension for easy access:
```dart
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isRtl => Localizations.localeOf(this).languageCode == 'ar';
}
```

**Translation Keys** (minimum required):
```dart
{
  'en': {
    'app_title': 'SafeBirth Connect',
    'inbox': 'Case Inbox',
    'dashboard': 'Dashboard',
    'settings': 'Settings',
    'emergency': 'Emergency',
    'support': 'Support Request',
    'accept': 'Accept',
    'complete': 'Complete',
    'cancel': 'Cancel',
    'available': 'Available',
    'busy': 'Busy',
    'zone': 'Zone',
    'risk_level': 'Risk Level',
    'due_date': 'Due Date',
    'high': 'High',
    'medium': 'Medium',
    'low': 'Low',
    'pending': 'Pending',
    'accepted': 'Accepted',
    'completed': 'Completed',
    'no_cases': 'No cases yet',
    'pull_to_refresh': 'Pull to refresh',
    // ... more
  },
  'ar': {
    'app_title': 'سيف بيرث كونكت',
    'inbox': 'صندوق الحالات',
    'dashboard': 'لوحة التحكم',
    'settings': 'الإعدادات',
    'emergency': 'طوارئ',
    // ... Arabic translations
  }
}
```

### 5.4 Network Layer

**core/network/dio_client.dart**:
```dart
@riverpod
Dio dioClient(DioClientRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api',  // Android emulator
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  
  return dio;
}
```

**core/network/api_exceptions.dart**:
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
}

class NetworkException extends ApiException {
  NetworkException() : super('No internet connection');
}

class ServerException extends ApiException {
  ServerException([String? message]) 
      : super(message ?? 'Server error');
}
```

### 5.5 Local Database

**core/database/database_helper.dart**:
```dart
@riverpod
Future<Database> database(DatabaseRef ref) async {
  final path = join(await getDatabasesPath(), 'safebirth.db');
  
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Cases table
      await db.execute('''
        CREATE TABLE cases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          case_id TEXT UNIQUE NOT NULL,
          zone TEXT NOT NULL,
          request_type TEXT NOT NULL,
          status TEXT NOT NULL,
          risk_level TEXT,
          due_date TEXT,
          created_at TEXT NOT NULL,
          accepted_at TEXT,
          synced INTEGER DEFAULT 0
        )
      ''');
      
      // Volunteer profile cache
      await db.execute('''
        CREATE TABLE volunteer_profile (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          skill_type TEXT NOT NULL,
          availability TEXT NOT NULL,
          zones TEXT NOT NULL
        )
      ''');
    },
  );
}
```

### 5.6 Router Setup

**core/router/app_router.dart**:
```dart
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/inbox',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/inbox',
            builder: (context, state) => const InboxScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
```

### 5.7 Locale Provider

**shared/providers/locale_provider.dart**:
```dart
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Default to Arabic (primary user base)
    return const Locale('ar');
  }
  
  void setLocale(Locale locale) {
    state = locale;
  }
  
  void toggleLocale() {
    state = state.languageCode == 'ar' 
        ? const Locale('en') 
        : const Locale('ar');
  }
}
```

### 5.8 Main Scaffold with Bottom Navigation

**shared/widgets/main_scaffold.dart**:
```dart
class MainScaffold extends ConsumerWidget {
  final Widget child;
  
  const MainScaffold({required this.child});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.inbox),
            label: l10n.translate('inbox'),
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: l10n.translate('dashboard'),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: l10n.translate('settings'),
          ),
        ],
      ),
    );
  }
}
```

### 5.9 Shared Widgets

**shared/widgets/app_button.dart**:
- Primary button with loading state
- Support for icons
- Full width option

**shared/widgets/loading_indicator.dart**:
- Centered CircularProgressIndicator
- Optional message

**shared/widgets/error_widget.dart**:
- Display error message
- Retry button

### 5.10 Constants

**core/constants/app_colors.dart**:
```dart
class AppColors {
  static const primary = Color(0xFF81B29A);      // Sage green
  static const secondary = Color(0xFFF4A261);    // Sandy orange
  static const emergency = Color(0xFFE63946);    // Red
  static const success = Color(0xFF2A9D8F);      // Teal
  static const warning = Color(0xFFF4A261);      // Orange
  static const background = Color(0xFFF8F9FA);   // Light gray
}
```

**core/constants/api_endpoints.dart**:
```dart
class ApiEndpoints {
  static const stats = '/dashboard/stats';
  static const cases = '/dashboard/cases';
  static const volunteers = '/dashboard/volunteers';
  static const zones = '/dashboard/zones';
  static const volunteerMe = '/volunteer/me';
  static const volunteerCases = '/volunteer/me/cases';
  static const volunteerAvailability = '/volunteer/me/availability';
}
```

### 5.11 Run Code Generation

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 5.12 Create Placeholder Screens

Create minimal placeholder screens for:
- `InboxScreen` - "Inbox - Coming in Phase 06"
- `DashboardScreen` - "Dashboard - Coming in Phase 06"
- `SettingsScreen` - Basic language toggle

## Completion Criteria
- [ ] App runs without errors (`flutter run`)
- [ ] Arabic locale displays RTL correctly
- [ ] English locale displays LTR correctly
- [ ] Language switching works in settings
- [ ] Dio client configured and tested
- [ ] SQLite database initializes correctly
- [ ] Router navigates between placeholder screens
- [ ] Bottom navigation works
- [ ] Code generation completes without errors
- [ ] PROGRESS.md updated to 🟢

## Dependencies
- Phase 01 completed (Flutter project initialized)

## Notes
- Test on both Android emulator and physical device if possible
- Use 10.0.2.2 for Android emulator localhost
- Arabic font (Cairo) should be added to pubspec.yaml
- RTL support is automatic with MaterialApp locale
