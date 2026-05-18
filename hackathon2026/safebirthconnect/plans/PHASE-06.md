# PHASE-06: Flutter Features Implementation

## Objective
Implement inbox, dashboard, and settings features with full functionality.

## Status: 🟢 Completed

## Tasks

### 6.1 Case Model (Freezed)

**features/inbox/data/models/case_model.dart**:
```dart
@freezed
class CaseModel with _$CaseModel {
  const factory CaseModel({
    required String caseId,
    required String zone,
    required String requestType,
    required String status,
    String? riskLevel,
    String? dueDate,
    required String createdAt,
    String? acceptedAt,
    String? volunteerName,
  }) = _CaseModel;
  
  factory CaseModel.fromJson(Map<String, dynamic> json) => 
      _$CaseModelFromJson(json);
}
```

### 6.2 Case Repository

**features/inbox/data/repositories/case_repository.dart**:
```dart
@riverpod
CaseRepository caseRepository(CaseRepositoryRef ref) {
  return CaseRepository(
    ref.watch(dioClientProvider),
    ref.watch(databaseProvider).value!,
  );
}

class CaseRepository {
  final Dio _dio;
  final Database _db;
  
  // Fetch from server
  Future<List<CaseModel>> fetchCasesFromServer() async { ... }
  
  // Get from local DB
  Future<List<CaseModel>> getCases() async { ... }
  
  // Sync server → local
  Future<void> syncFromServer() async { ... }
  
  // Accept case (API call + local update)
  Future<void> acceptCase(String caseId) async { ... }
  
  // Complete case
  Future<void> completeCase(String caseId) async { ... }
}
```

### 6.3 Inbox Provider

**features/inbox/presentation/providers/inbox_provider.dart**:
```dart
@riverpod
class InboxNotifier extends _$InboxNotifier {
  @override
  Future<List<CaseModel>> build() async {
    final repository = ref.watch(caseRepositoryProvider);
    return repository.getCases();
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(caseRepositoryProvider);
      await repository.syncFromServer();
      return repository.getCases();
    });
  }
  
  Future<void> acceptCase(String caseId) async {
    await ref.read(caseRepositoryProvider).acceptCase(caseId);
    ref.invalidateSelf();
  }
  
  Future<void> completeCase(String caseId) async {
    await ref.read(caseRepositoryProvider).completeCase(caseId);
    ref.invalidateSelf();
  }
}
```

### 6.4 Inbox Screen

**features/inbox/presentation/screens/inbox_screen.dart**:
```dart
class InboxScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(inboxNotifierProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('inbox'))),
      body: casesAsync.when(
        loading: () => LoadingIndicator(),
        error: (error, stack) => ErrorWidget(error: error, onRetry: () => ref.refresh(inboxNotifierProvider)),
        data: (cases) {
          if (cases.isEmpty) {
            return EmptyState(message: l10n.translate('no_cases'));
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.read(inboxNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: cases.length,
              itemBuilder: (context, index) => CaseCard(
                caseModel: cases[index],
                onAccept: () => ref.read(inboxNotifierProvider.notifier).acceptCase(cases[index].caseId),
                onComplete: () => ref.read(inboxNotifierProvider.notifier).completeCase(cases[index].caseId),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 6.5 Case Card Widget

**features/inbox/presentation/widgets/case_card.dart**:
```dart
class CaseCard extends StatelessWidget {
  final CaseModel caseModel;
  final VoidCallback? onAccept;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEmergency = caseModel.requestType == 'EMERGENCY';
    final isPending = caseModel.status == 'PENDING';
    final isAccepted = caseModel.status == 'ACCEPTED';

    return Card(
      color: isEmergency ? Colors.red.shade50 : null,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type + Case ID
            _buildHeader(l10n, isEmergency),
            SizedBox(height: 12),
            
            // Details: Zone, Risk, Due Date
            _buildDetails(l10n),
            
            // Actions
            if (isPending && onAccept != null)
              _buildAcceptButton(l10n),
            if (isAccepted && onComplete != null)
              _buildCompleteButton(l10n),
          ],
        ),
      ),
    );
  }
  
  // ... helper methods
}
```

### 6.6 Dashboard Model

**features/dashboard/data/models/dashboard_stats_model.dart**:
```dart
@freezed
class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    required int totalMothers,
    required int totalVolunteers,
    required int activeVolunteers,
    required int pendingRequests,
    required int activeRequests,
    required int completedToday,
    required Map<String, int> mothersByZone,
    required Map<String, int> requestsByStatus,
    required Map<String, int> volunteersBySkill,
    required List<DueDateCluster> upcomingDueDates,
  }) = _DashboardStatsModel;
  
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
}

@freezed
class DueDateCluster with _$DueDateCluster {
  const factory DueDateCluster({
    required String date,
    required int count,
  }) = _DueDateCluster;
  
  factory DueDateCluster.fromJson(Map<String, dynamic> json) =>
      _$DueDateClusterFromJson(json);
}
```

### 6.7 Dashboard Provider

**features/dashboard/presentation/providers/dashboard_provider.dart**:
```dart
@riverpod
Future<DashboardStatsModel> dashboardStats(DashboardStatsRef ref) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get(ApiEndpoints.stats);
  return DashboardStatsModel.fromJson(response.data);
}
```

### 6.8 Dashboard Screen

**features/dashboard/presentation/screens/dashboard_screen.dart**:
```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('dashboard'))),
      body: statsAsync.when(
        loading: () => LoadingIndicator(),
        error: (error, stack) => ErrorWidget(error: error),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardStatsProvider.future),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary cards row 1
                Row(children: [
                  Expanded(child: StatsCard(title: 'Mothers', value: '${stats.totalMothers}', icon: Icons.pregnant_woman, color: Colors.pink)),
                  SizedBox(width: 12),
                  Expanded(child: StatsCard(title: 'Volunteers', value: '${stats.activeVolunteers}/${stats.totalVolunteers}', icon: Icons.people, color: Colors.blue)),
                ]),
                SizedBox(height: 12),
                
                // Summary cards row 2
                Row(children: [
                  Expanded(child: StatsCard(title: 'Pending', value: '${stats.pendingRequests}', icon: Icons.pending_actions, color: Colors.orange)),
                  SizedBox(width: 12),
                  Expanded(child: StatsCard(title: 'Active', value: '${stats.activeRequests}', icon: Icons.local_hospital, color: Colors.green)),
                ]),
                SizedBox(height: 24),
                
                // Zone distribution chart
                _buildZoneSection(stats),
                SizedBox(height: 24),
                
                // Upcoming due dates
                _buildDueDatesSection(stats),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 6.9 Stats Card Widget

**features/dashboard/presentation/widgets/stats_card.dart**:
```dart
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                Spacer(),
                Text(value, style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
              ],
            ),
            SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
```

### 6.10 Zone Chart Widget

**features/dashboard/presentation/widgets/zone_chart.dart**:
```dart
class ZoneChart extends StatelessWidget {
  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sortedEntries.isEmpty ? 1 : sortedEntries.first.value;

    return Column(
      children: sortedEntries.map((entry) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 60, child: Text('Zone ${entry.key}')),
            Expanded(
              child: LinearProgressIndicator(
                value: entry.value / maxValue,
                backgroundColor: Colors.grey[200],
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Text('${entry.value}'),
          ],
        ),
      )).toList(),
    );
  }
}
```

### 6.11 Settings Screen

**features/settings/presentation/screens/settings_screen.dart**:
```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('settings'))),
      body: ListView(
        children: [
          // Language toggle
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language / اللغة'),
            subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
            trailing: Switch(
              value: locale.languageCode == 'ar',
              onChanged: (isArabic) {
                ref.read(localeProvider.notifier).setLocale(
                  Locale(isArabic ? 'ar' : 'en'),
                );
              },
            ),
          ),
          Divider(),
          
          // Volunteer status (if logged in)
          _buildVolunteerStatusTile(ref),
          Divider(),
          
          // About
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('SafeBirth Connect v1.0.0'),
          ),
        ],
      ),
    );
  }
}
```

### 6.12 Volunteer Status Tile

Add availability toggle in settings:
```dart
Widget _buildVolunteerStatusTile(WidgetRef ref) {
  final volunteerAsync = ref.watch(volunteerProfileProvider);
  
  return volunteerAsync.when(
    loading: () => ListTile(
      leading: Icon(Icons.person),
      title: Text('My Status'),
      trailing: CircularProgressIndicator(),
    ),
    error: (_, __) => SizedBox.shrink(),
    data: (volunteer) => ListTile(
      leading: Icon(Icons.person),
      title: Text('My Status'),
      subtitle: Text(volunteer.availability),
      trailing: Switch(
        value: volunteer.availability == 'AVAILABLE',
        onChanged: (available) {
          ref.read(volunteerProfileProvider.notifier).updateAvailability(
            available ? 'AVAILABLE' : 'BUSY',
          );
        },
      ),
    ),
  );
}
```

### 6.13 Run Code Generation

```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
```

## Completion Criteria
- [ ] Inbox displays cases from API
- [ ] Inbox shows loading/error/empty states
- [ ] Pull-to-refresh works on inbox
- [ ] Accept case button works
- [ ] Complete case button works
- [ ] Inbox works offline with cached data
- [ ] Dashboard shows all statistics
- [ ] Dashboard charts render correctly
- [ ] Settings language toggle works
- [ ] Settings volunteer status toggle works
- [ ] RTL layout correct for Arabic throughout
- [ ] No hardcoded strings (all localized)
- [ ] Code generation completes
- [ ] PROGRESS.md updated to 🟢

## Dependencies
- Phase 05 completed (core setup)
- Phase 04 completed (backend API)

## Notes
- Test both online and offline scenarios
- Verify Arabic text renders correctly
- Test on physical device if possible
- Handle API errors gracefully
