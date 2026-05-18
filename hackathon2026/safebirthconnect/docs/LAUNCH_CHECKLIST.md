# SafeBirth Connect — Launch Readiness Checklist

Complete this checklist before demo or deployment.

---

## Backend Verification

### API Endpoints
- [ ] `GET /api/dashboard/stats` returns expected statistics
- [ ] `GET /api/dashboard/cases` returns case list with pagination
- [ ] `GET /api/dashboard/cases/{caseId}` returns case details
- [ ] `GET /api/dashboard/volunteers` returns volunteer list
- [ ] `GET /api/dashboard/zones` returns zone statistics
- [ ] `GET /api/volunteer/me` returns volunteer profile (with X-Phone-Number header)
- [ ] `GET /api/volunteer/me/cases` returns volunteer's assigned cases
- [ ] `PUT /api/volunteer/me/availability` updates availability status
- [ ] `POST /api/sms/incoming` processes Twilio webhook
- [ ] `POST /api/sms/simulate` processes simulated SMS
- [ ] `GET /api/sms/health` returns service status

### SMS Command Parsing
- [ ] Mother registration parses all fields (camp, zone, due date, risk)
- [ ] Volunteer registration parses all fields (name, camp, zone, skill)
- [ ] Emergency command triggers matching service
- [ ] Support command creates non-emergency request
- [ ] Accept command updates case and notifies mother
- [ ] Complete command marks case as completed
- [ ] Cancel command works for both mother and volunteer
- [ ] Availability commands (AVAILABLE, BUSY, OFFLINE) update status
- [ ] Status command returns appropriate info for user type
- [ ] Help command returns full command list
- [ ] Unknown commands return helpful error message

### Bilingual Support
- [ ] English commands parsed correctly
- [ ] Arabic commands parsed correctly
- [ ] Response messages bilingual (based on detected language)
- [ ] Error messages bilingual

### Matching Algorithm
- [ ] Priority 1: Certified (MIDWIFE, NURSE) + Same Zone + Available
- [ ] Priority 2: Trained Attendant + Same Zone + Available
- [ ] Priority 3: Any Volunteer + Same Zone + Available
- [ ] No matching volunteers handled gracefully
- [ ] Multiple volunteers notified for emergencies

### Error Handling
- [ ] Invalid phone number handled
- [ ] Missing required fields return clear error
- [ ] Database errors don't expose stack traces
- [ ] SMS delivery failures logged and handled
- [ ] Concurrent request handling works correctly

### Database
- [ ] H2 console accessible at `/h2-console` (dev mode)
- [ ] Sample data loads via DataInitializer (dev profile)
- [ ] All JPA entities persist correctly
- [ ] Foreign key relationships work

### Security
- [ ] No hardcoded secrets in code
- [ ] Twilio credentials in environment variables
- [ ] CORS configured appropriately
- [ ] Input validation on all endpoints

### Logging
- [ ] SMS inbound/outbound logged
- [ ] Command parsing logged
- [ ] Errors logged with stack traces
- [ ] Phone numbers masked in logs

### Tests
- [ ] All unit tests pass: `mvn test`
- [ ] All integration tests pass
- [ ] Test coverage acceptable

---

## Flutter App Verification

### Build
- [ ] `flutter analyze` passes with no errors
- [ ] `flutter build apk` succeeds
- [ ] `flutter build ios` succeeds (if applicable)
- [ ] No compiler warnings

### Screens
- [ ] **InboxScreen:** Displays case list correctly
- [ ] **InboxScreen:** Filter chips work (All/Pending/Accepted/Emergency)
- [ ] **InboxScreen:** Pull-to-refresh works
- [ ] **InboxScreen:** Accept case action works
- [ ] **InboxScreen:** Complete case action works
- [ ] **InboxScreen:** Navigation to case details works
- [ ] **DashboardScreen:** Stats cards display correctly
- [ ] **DashboardScreen:** Zone chart renders
- [ ] **DashboardScreen:** Status distribution renders
- [ ] **DashboardScreen:** Emergency alerts display
- [ ] **DashboardScreen:** Recent cases section works
- [ ] **SettingsScreen:** Language toggle works
- [ ] **SettingsScreen:** Availability toggle works
- [ ] **SettingsScreen:** Volunteer profile displays
- [ ] **SettingsScreen:** Logout works
- [ ] **CaseDetailsScreen:** Full case info displays
- [ ] **CaseDetailsScreen:** Timeline shows events
- [ ] **CaseDetailsScreen:** Action buttons work

### Localization
- [ ] All strings localized (no hardcoded text)
- [ ] English translations complete
- [ ] Arabic translations complete
- [ ] Language switch works at runtime
- [ ] App title localized

### RTL Support (Arabic)
- [ ] Layout mirrors correctly in RTL
- [ ] Text alignment correct
- [ ] Icons positioned correctly
- [ ] Navigation direction correct
- [ ] Charts readable in RTL

### Offline Mode
- [ ] Cases cached to SQLite
- [ ] Cached data displays when offline
- [ ] Sync queue stores pending actions
- [ ] Actions sync when back online
- [ ] Error states handle offline gracefully

### Network
- [ ] API base URL configured correctly
- [ ] Timeout handling works
- [ ] Network errors show user-friendly messages
- [ ] Retry mechanism works

### State Management
- [ ] Providers initialize correctly
- [ ] State persists across navigation
- [ ] Refresh triggers re-fetch
- [ ] Error states display correctly
- [ ] Loading states display correctly

### UI/UX
- [ ] Sage green (#81B29A) theme applied
- [ ] Cairo font loads for Arabic
- [ ] Material 3 design consistent
- [ ] Status badges color-coded
- [ ] Risk levels color-coded
- [ ] Emergency cases highlighted
- [ ] Buttons responsive
- [ ] Scroll behavior smooth

### Tests
- [ ] `flutter test` passes
- [ ] Widget tests pass
- [ ] Model tests pass

---

## Integration Verification

### Flutter ↔ Backend
- [ ] Inbox loads cases from `/api/dashboard/cases`
- [ ] Dashboard loads stats from `/api/dashboard/stats`
- [ ] Volunteer profile loads from `/api/volunteer/me`
- [ ] Accept case calls backend and updates
- [ ] Complete case calls backend and updates
- [ ] Availability toggle updates backend
- [ ] Pull-to-refresh fetches new data

### SMS ↔ Backend
- [ ] Twilio webhook receives SMS
- [ ] TwiML response sent back correctly
- [ ] Volunteers notified via SMS on emergency
- [ ] Mother notified via SMS on case acceptance

### End-to-End Flow
- [ ] Register mother via SMS → Appears in dashboard
- [ ] Register volunteer via SMS → Appears in volunteers list
- [ ] Mother sends emergency → Volunteer receives SMS alert
- [ ] Volunteer accepts via SMS → Mother notified, case in Flutter inbox
- [ ] Volunteer completes via SMS → Stats updated in dashboard

---

## Documentation

- [ ] README.md updated with quick start
- [ ] SMS commands documented
- [ ] API endpoints documented (Swagger UI)
- [ ] Architecture reference linked
- [ ] Setup instructions clear
- [ ] Environment variables documented
- [ ] Twilio setup guide complete

---

## Code Quality

- [ ] No compiler warnings (Java)
- [ ] No analyzer warnings (Dart)
- [ ] Code formatted (Java: spotless, Dart: flutter format)
- [ ] No TODO comments in critical paths
- [ ] Consistent naming conventions
- [ ] SOLID principles applied
- [ ] Exception handling comprehensive

---

## Demo Preparation

- [ ] Demo script prepared
- [ ] Sample data ready
- [ ] Test phone numbers available
- [ ] ngrok URL configured
- [ ] Fallback plan ready (mock gateway)
- [ ] Presentation slides (if needed)

---

## Final Sign-Off

| Area | Status | Notes |
|------|--------|-------|
| Backend API | ☐ Ready | |
| SMS Integration | ☐ Ready | |
| Flutter App | ☐ Ready | |
| Localization | ☐ Ready | |
| Documentation | ☐ Ready | |
| Tests | ☐ Ready | |

**Reviewed by:** ________________  
**Date:** ________________  
**Version:** ________________

---

## Known Issues / Limitations

Document any known issues that won't be fixed before launch:

1. 
2. 
3. 

---

## Post-Launch Tasks

- [ ] Monitor Twilio logs for errors
- [ ] Monitor backend logs for exceptions
- [ ] Collect user feedback
- [ ] Plan for Phase 8 (if applicable)
