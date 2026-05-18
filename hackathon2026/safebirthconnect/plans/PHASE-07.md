# PHASE-07: Integration & Testing

## Objective
End-to-end testing, Twilio live integration test, final polish, and launch readiness.

## Status: 🟢 Completed

## Tasks

### 7.1 Backend Integration Tests

**SmsIntegrationTest.java**:
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class SmsIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void testMotherRegistrationFlow_English() {
        var request = Map.of(
            "From", "+201234567890",
            "Body", "REG MOTHER\nCAMP A\nZONE 3\nDUE 15-02\nRISK HIGH"
        );
        
        var response = restTemplate.postForEntity(
            "/api/sms/incoming", 
            request, 
            String.class
        );
        
        assertThat(response.getBody()).contains("Registered");
        assertThat(response.getBody()).contains("M-");
    }
    
    @Test
    void testMotherRegistrationFlow_Arabic() {
        var request = Map.of(
            "From", "+201234567891",
            "Body", "تسجيل ام\nمخيم أ\nمنطقة 3\nموعد 15-02\nخطورة عالية"
        );
        
        var response = restTemplate.postForEntity(
            "/api/sms/incoming", 
            request, 
            String.class
        );
        
        assertThat(response.getBody()).contains("تم التسجيل");
    }
    
    @Test
    void testVolunteerRegistrationFlow() { ... }
    
    @Test
    void testEmergencyFlow_TriggersMatching() { ... }
    
    @Test
    void testAcceptCaseFlow() { ... }
    
    @Test
    void testCompleteCaseFlow() { ... }
}
```

**DashboardApiIntegrationTest.java**:
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class DashboardApiIntegrationTest {
    
    @Test
    void testGetStats_ReturnsAllMetrics() { ... }
    
    @Test
    void testGetCases_Paginated() { ... }
    
    @Test
    void testGetVolunteers_FilterByAvailability() { ... }
}
```

### 7.2 Flutter Widget Tests

**inbox_screen_test.dart**:
```dart
void main() {
  testWidgets('InboxScreen shows loading indicator', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inboxNotifierProvider.overrideWith((ref) => MockInboxNotifier()),
        ],
        child: MaterialApp(home: InboxScreen()),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  testWidgets('InboxScreen shows empty state when no cases', (tester) async {
    // ...
  });
  
  testWidgets('CaseCard displays correctly in Arabic', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: [AppLocalizations.delegate],
          home: CaseCard(
            caseModel: CaseModel(
              caseId: 'HR-0001',
              zone: '3',
              requestType: 'EMERGENCY',
              status: 'PENDING',
              riskLevel: 'HIGH',
              createdAt: '2024-01-01',
            ),
          ),
        ),
      ),
    );
    
    expect(find.text('HR-0001'), findsOneWidget);
    expect(find.text('طوارئ'), findsOneWidget);
  });
}
```

**dashboard_screen_test.dart**:
```dart
void main() {
  testWidgets('DashboardScreen shows stats cards', (tester) async { ... });
  testWidgets('StatsCard displays value correctly', (tester) async { ... });
  testWidgets('ZoneChart renders bars', (tester) async { ... });
}
```

**settings_screen_test.dart**:
```dart
void main() {
  testWidgets('Language toggle switches locale', (tester) async { ... });
}
```

### 7.3 Twilio Setup & Live Test

**Prerequisites**:
1. Create Twilio account (free trial)
2. Get phone number (sandbox number for trial)
3. Verify test phone numbers
4. Install ngrok: `npm install -g ngrok` or download from ngrok.com

**Setup Steps**:

1. **Start backend**:
```bash
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

2. **Start ngrok tunnel**:
```bash
ngrok http 8080
```
Note the HTTPS URL (e.g., `https://abc123.ngrok.io`)

3. **Configure Twilio webhook**:
   - Go to Twilio Console → Phone Numbers → Your Number
   - Set webhook URL: `https://abc123.ngrok.io/api/sms/incoming`
   - Method: POST

4. **Set environment variables**:
```bash
export TWILIO_ACCOUNT_SID=your_account_sid
export TWILIO_AUTH_TOKEN=your_auth_token
export TWILIO_PHONE_NUMBER=+1234567890
```

### 7.4 Live SMS Test Checklist

```markdown
## Live SMS Testing Checklist

### Setup
- [ ] Twilio account created
- [ ] Phone number obtained
- [ ] Test phones verified in Twilio console
- [ ] ngrok running and URL noted
- [ ] Webhook URL configured in Twilio
- [ ] Backend running with prod profile

### Mother Registration Tests
- [ ] Send: "REG MOTHER CAMP A ZONE 3 DUE 15-02 RISK HIGH"
      Expected: "✅ Registered! Your ID: M-0001..."
- [ ] Send: "تسجيل ام مخيم أ منطقة 3 موعد 15-02 خطورة عالية"
      Expected: "✅ تم التسجيل! رقمك: M-0002..."

### Volunteer Registration Tests
- [ ] Send: "REG VOLUNTEER NAME Test SKILL MIDWIFE ZONE 3"
      Expected: "✅ Registered as volunteer!..."
- [ ] Send: "تسجيل متطوع الاسم فاطمة مهارة قابلة منطقة 3,4"
      Expected: "✅ تم تسجيلك كمتطوع!..."

### Emergency Flow Tests
- [ ] Send "EMERGENCY" from registered mother
      Expected: Mother gets "✅ Help request sent! ID: HR-0001..."
      Expected: Volunteer gets "🚨 EMERGENCY Zone 3..."
- [ ] Volunteer sends "ACCEPT HR-0001"
      Expected: Volunteer gets "✅ Case HR-0001 accepted!..."
      Expected: Mother gets "✅ Help is on the way!..."
- [ ] Volunteer sends "COMPLETE HR-0001"
      Expected: "✅ Case HR-0001 completed..."

### Status Tests
- [ ] Send "STATUS" → Get current status
- [ ] Send "AVAILABLE" → "✅ Status updated to Available"
- [ ] Send "BUSY" → "✅ Status updated to Busy"

### Error Handling Tests
- [ ] Send "EMERGENCY" from unregistered number
      Expected: "❌ You're not registered..."
- [ ] Send "ACCEPT HR-9999" (invalid case)
      Expected: "❌ Could not accept case..."
- [ ] Send gibberish
      Expected: Help message with valid commands
```

### 7.5 Flutter + Backend Integration Test

**Test Flow**:
1. Start backend with sample data
2. Run Flutter app on emulator
3. Verify:
   - [ ] Inbox loads cases from backend
   - [ ] Dashboard shows correct stats
   - [ ] Accept case updates backend
   - [ ] Complete case updates backend
   - [ ] Pull-to-refresh fetches new data
   - [ ] Offline mode shows cached data

### 7.6 Final Checklist

```markdown
## Launch Readiness Checklist

### Backend
- [ ] All endpoints return expected data
- [ ] SMS parsing handles edge cases
- [ ] Matching algorithm tested with various scenarios
- [ ] Error messages are bilingual
- [ ] H2 console accessible for debugging
- [ ] Logging is comprehensive
- [ ] No hardcoded secrets in code

### Flutter App
- [ ] App builds for Android without errors
- [ ] App builds for iOS without errors (if applicable)
- [ ] Offline mode works correctly
- [ ] Sync when online works correctly
- [ ] Arabic RTL layout is correct throughout
- [ ] English LTR layout is correct throughout
- [ ] No hardcoded strings (all localized)
- [ ] Error states handled gracefully
- [ ] Loading states shown appropriately

### Integration
- [ ] Full SMS flow works end-to-end
- [ ] Flutter app receives data from backend
- [ ] ngrok + Twilio integration verified
- [ ] Latency is acceptable

### Documentation
- [ ] README.md is complete
- [ ] API endpoints documented
- [ ] SMS commands documented
- [ ] Setup instructions clear
- [ ] Environment variables documented

### Code Quality
- [ ] No compiler warnings
- [ ] No linter errors
- [ ] Tests pass
- [ ] Code is properly formatted
```

### 7.7 Create Final Documentation

**Update README.md**:
```markdown
# SafeBirth Connect

SMS-first maternal support coordination system for crisis settings.

## Quick Start

### Backend
```bash
cd backend
mvn spring-boot:run
```
Access: http://localhost:8080
H2 Console: http://localhost:8080/h2-console

### Flutter App
```bash
cd mobile
flutter pub get
flutter run
```

### SMS Testing (Development)
```bash
curl -X POST http://localhost:8080/api/sms/simulate \
  -H "Content-Type: application/json" \
  -d '{"from": "+1234567890", "body": "REG MOTHER CAMP A ZONE 3"}'
```

## SMS Commands

| Action | English | Arabic |
|--------|---------|--------|
| Register Mother | REG MOTHER CAMP x ZONE x | تسجيل ام مخيم x منطقة x |
| Emergency | EMERGENCY | طوارئ |
| Accept Case | ACCEPT HR-xxxx | قبول xxxx |

## Architecture

[Link to ARCHITECTURE.md]

## Contributing

[Contribution guidelines]
```

### 7.8 Demo Preparation

Prepare demo script:
1. Show empty system
2. Register a mother via SMS
3. Register a volunteer via SMS
4. Send emergency from mother
5. Show volunteer receives alert
6. Accept case via SMS
7. Show Flutter app with case in inbox
8. Complete case via SMS
9. Show dashboard with updated stats

## Completion Criteria
- [ ] All backend integration tests pass
- [ ] All Flutter widget tests pass
- [ ] Twilio live test successful (all checklist items)
- [ ] Flutter ↔ Backend integration verified
- [ ] Final checklist complete
- [ ] Documentation complete
- [ ] Demo script prepared
- [ ] PROGRESS.md shows all phases 🟢

## Dependencies
- All previous phases completed

## Notes
- Keep Twilio test phone numbers whitelisted
- Document any known issues
- Prepare fallback plan for demo
- Have mock gateway as backup if Twilio fails
