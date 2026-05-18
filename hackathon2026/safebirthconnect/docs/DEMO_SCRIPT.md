# SafeBirth Connect — Demo Script

This script walks through a complete demonstration of SafeBirth Connect's capabilities.

## Setup Before Demo

### Prerequisites
1. Backend running: `cd backend && mvn spring-boot:run`
2. ngrok running: `ngrok http 8080`
3. Twilio webhook configured with ngrok URL
4. Flutter app running on device/emulator: `cd mobile && flutter run`
5. Two test phones ready (or use SMS simulator for demo without real phones)

### URLs to Have Open
- Backend: http://localhost:8080
- Swagger UI: http://localhost:8080/swagger-ui.html
- H2 Console: http://localhost:8080/h2-console
- ngrok Inspector: http://127.0.0.1:4040

---

## Demo Script

### Introduction (1 minute)

> "SafeBirth Connect is an SMS-first maternal support coordination system designed for crisis settings like refugee camps. In environments where internet is unreliable, mothers can still access life-saving support through simple SMS messages."

### Part 1: Show Empty System (1 minute)

1. Open Flutter app - show empty dashboard
   > "The NGO coordinator sees a clean dashboard. No mothers registered, no cases yet."

2. Show Swagger UI briefly
   > "The system exposes a REST API for the mobile app and supports SMS webhooks from Twilio."

### Part 2: Mother Registration via SMS (2 minutes)

1. **Send SMS from Phone 1:**
   ```
   REG MOTHER CAMP A ZONE 3 DUE 15-02 RISK HIGH
   ```

2. **Show Response:**
   > "The mother receives confirmation with her unique ID. She can now request help."

3. **Refresh Flutter Dashboard:**
   > "The coordinator immediately sees the new mother registered in their zone."

4. **Try Arabic Registration (optional):**
   ```
   تسجيل ام مخيم ب منطقة 5 خطورة عالية
   ```
   > "The system is fully bilingual - mothers can use Arabic commands."

### Part 3: Volunteer Registration via SMS (2 minutes)

1. **Send SMS from Phone 2:**
   ```
   REG VOLUNTEER NAME Fatima CAMP A ZONE 3 SKILL MIDWIFE
   ```

2. **Show Response:**
   > "The volunteer is registered with their skills and coverage zones. They're automatically set to AVAILABLE."

3. **Refresh Flutter App:**
   > "The coordinator sees the new volunteer in the system. They can see skills and availability."

### Part 4: Emergency Flow (3 minutes) ⭐ Key Demo

1. **Mother Sends Emergency (Phone 1):**
   ```
   EMERGENCY
   ```

2. **Show Mother's Response:**
   > "The mother gets immediate confirmation. The system is matching her with nearby volunteers."

3. **Show Volunteer's Alert (Phone 2):**
   > "All available volunteers in Zone 3 receive an alert with case details. They can respond by SMS."

4. **Show Flutter Inbox:**
   > "The case appears in the coordinator's inbox as PENDING EMERGENCY. They have full visibility."

5. **Volunteer Accepts (Phone 2):**
   ```
   ACCEPT HR-0001
   ```

6. **Show Mother's Notification:**
   > "The mother is notified that help is on the way. She knows someone is coming."

7. **Show Flutter App:**
   > "The case status updates to ACCEPTED. The coordinator can track progress."

### Part 5: Case Completion (1 minute)

1. **Volunteer Completes (Phone 2):**
   ```
   COMPLETE HR-0001
   ```

2. **Show Response:**
   > "The volunteer marks the case complete. Their completed cases count increases."

3. **Show Dashboard:**
   > "The coordinator sees updated statistics. One more successful intervention."

### Part 6: Flutter App Features (2 minutes)

1. **Show Dashboard:**
   - Total mothers, volunteers
   - Pending emergencies alert
   - Zone distribution chart
   - Recent cases

2. **Show Inbox:**
   - Filter by status (Pending, Accepted, Emergency)
   - Pull to refresh
   - Case details

3. **Show Settings:**
   - Language toggle (switch to Arabic)
   > "The entire app switches to Arabic with RTL layout."
   - Volunteer availability toggle

4. **Show Offline Mode:**
   > "Even without internet, coordinators can view cached cases. Actions queue and sync when back online."

### Part 7: Arabic Demo (Optional - 1 minute)

1. Switch app to Arabic
2. Show RTL layout
3. Send Arabic emergency:
   ```
   طوارئ
   ```
4. Show Arabic notifications

### Part 8: Q&A / Technical Deep Dive

**If asked about architecture:**
> "The backend is Spring Boot with H2 database. SMS comes through Twilio webhooks. The parser handles both Arabic and English commands. The matching service prioritizes certified midwives, then nurses, then trained attendants."

**If asked about scalability:**
> "For production, we'd use PostgreSQL, add Redis for caching, and deploy to AWS/GCP with auto-scaling. The SMS gateway is abstracted, so we could add other providers."

**If asked about security:**
> "This is a POC. Production would add JWT authentication, rate limiting, phone number verification, and encrypted data at rest."

---

## Backup Plans

### If Twilio/SMS isn't working:

1. Use SMS Simulator:
   ```powershell
   # PowerShell
   Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/sms/simulate" `
     -ContentType "application/json" `
     -Body '{"from": "+201234567890", "body": "REG MOTHER CAMP A ZONE 3"}'
   ```

2. Use Swagger UI:
   - Navigate to `/api/sms/simulate`
   - Execute with test data
   - Show the response

### If Flutter app has issues:

1. Use Swagger UI to show API working
2. Show API responses directly
3. Explain what the app would display

### If demo data is messy:

1. Stop backend
2. Delete H2 database file
3. Restart backend (fresh database)
4. Proceed with demo

---

## Key Messages to Emphasize

1. **SMS-First Design**
   > "Internet isn't required. A basic phone with SMS is all mothers need."

2. **Bilingual Support**
   > "Arabic and English, with automatic language detection."

3. **Real-Time Coordination**
   > "From emergency to help arriving - tracked every step."

4. **Offline Capable**
   > "Coordinators can work even without internet."

5. **Simple Commands**
   > "One word - 'EMERGENCY' - can save a life."

---

## Demo Commands Quick Reference

| Action | English | Arabic |
|--------|---------|--------|
| Register Mother | `REG MOTHER CAMP A ZONE 3` | `تسجيل ام مخيم أ منطقة 3` |
| Register Volunteer | `REG VOLUNTEER NAME X CAMP A ZONE 3 SKILL MIDWIFE` | `تسجيل متطوع الاسم فاطمة مخيم أ منطقة 3 مهارة قابلة` |
| Emergency | `EMERGENCY` | `طوارئ` |
| Accept Case | `ACCEPT HR-0001` | `قبول HR-0001` |
| Complete Case | `COMPLETE HR-0001` | `انهاء HR-0001` |
| Set Available | `AVAILABLE` | `متاح` |
| Set Busy | `BUSY` | `مشغول` |
| Check Status | `STATUS` | `حالة` |
| Get Help | `HELP` | `مساعدة` |

---

## Timing Summary

| Section | Duration |
|---------|----------|
| Introduction | 1 min |
| Empty System | 1 min |
| Mother Registration | 2 min |
| Volunteer Registration | 2 min |
| Emergency Flow | 3 min |
| Case Completion | 1 min |
| Flutter Features | 2 min |
| Arabic Demo | 1 min |
| Q&A | Variable |
| **Total** | ~13 min + Q&A |
