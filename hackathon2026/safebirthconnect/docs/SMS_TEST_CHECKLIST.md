# Live SMS Testing Checklist

Use this checklist to verify SMS functionality with real Twilio integration.

## Pre-Test Setup

### Infrastructure
- [ ] Twilio account created and verified
- [ ] Twilio phone number obtained
- [ ] Test phone numbers verified in Twilio console (required for trial accounts)
- [ ] ngrok installed and authenticated
- [ ] ngrok tunnel running and HTTPS URL noted
- [ ] Webhook URL configured in Twilio (`https://xxx.ngrok-free.app/api/sms/incoming`)
- [ ] Backend running with `prod` profile
- [ ] Environment variables set (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER)

### Verification
- [ ] Backend health check: `curl http://localhost:8080/api/sms/health`
- [ ] ngrok web interface accessible: http://127.0.0.1:4040
- [ ] Twilio webhook test successful (check ngrok inspector)

---

## Mother Registration Tests

### English Registration
- [ ] **Send:** `REG MOTHER CAMP A ZONE 3 DUE 15-02 RISK HIGH`
- [ ] **Expected Response:** `✅ Registered! Your ID: M-0001...`
- [ ] **Verify:** Mother appears in database/dashboard

### Arabic Registration
- [ ] **Send:** `تسجيل ام مخيم أ منطقة 3 موعد 15-02 خطورة عالية`
- [ ] **Expected Response:** `✅ تم التسجيل! رقمك: M-0002...`
- [ ] **Verify:** Mother saved with Arabic language preference

### Registration Variations
- [ ] **Send:** `REG MOTHER CAMP B ZONE 1` (minimal info)
- [ ] **Expected:** Successful registration with default risk level

### Registration Errors
- [ ] **Send:** `REG MOTHER ZONE 3` (missing camp)
- [ ] **Expected:** `❌ Camp is required. Example: REG MOTHER CAMP A ZONE 3`
- [ ] **Send:** `REG MOTHER CAMP A` (missing zone)
- [ ] **Expected:** `❌ Zone is required. Example: REG MOTHER CAMP A ZONE 3`

---

## Volunteer Registration Tests

### English Registration
- [ ] **Send:** `REG VOLUNTEER NAME Sarah CAMP A ZONE 3 SKILL MIDWIFE`
- [ ] **Expected Response:** `✅ Volunteer registered! Your ID: V-0001...`
- [ ] **Verify:** Volunteer appears in database with AVAILABLE status

### Arabic Registration
- [ ] **Send:** `تسجيل متطوع الاسم فاطمة مخيم أ منطقة 3,4 مهارة قابلة`
- [ ] **Expected Response:** `✅ تم تسجيل المتطوع! رقمك: V-0002...`
- [ ] **Verify:** Volunteer saved with Arabic language preference and multiple zones

### Skill Type Variations
- [ ] **MIDWIFE / قابلة** - Registered as MIDWIFE
- [ ] **NURSE / ممرضة** - Registered as NURSE
- [ ] **TRAINED / مدربة** - Registered as TRAINED_ATTENDANT
- [ ] **Default** - Registered as COMMUNITY_VOLUNTEER

---

## Emergency Flow Tests

### Emergency Request (English)
- [ ] **Pre-requisite:** Registered mother and available volunteer in same zone
- [ ] **Send (from mother phone):** `EMERGENCY`
- [ ] **Mother receives:** `🚨 EMERGENCY received! Case: HR-0001... ✅ X volunteer(s) have been alerted.`
- [ ] **Volunteer receives:** `🚨 EMERGENCY in Zone X... Mother ID: M-XXXX... Reply ACCEPT HR-0001 to respond.`

### Emergency Request (Arabic)
- [ ] **Send (from mother phone):** `طوارئ`
- [ ] **Mother receives:** `🚨 تم استلام الطوارئ! الحالة: HR-0002...`
- [ ] **Volunteer receives:** Arabic alert message

### No Volunteers Available
- [ ] **Send (from mother in zone with no volunteers):** `EMERGENCY`
- [ ] **Expected:** `🚨 EMERGENCY received!... ⚠️ No volunteers available in your zone.`

### Unregistered User Emergency
- [ ] **Send (from unregistered number):** `EMERGENCY`
- [ ] **Expected:** `❌ You are not registered. Please register first: REG MOTHER CAMP [name] ZONE [number]`

---

## Case Accept Flow Tests

### Accept Case (English)
- [ ] **Pre-requisite:** Pending help request HR-XXXX
- [ ] **Send (from volunteer phone):** `ACCEPT HR-0001`
- [ ] **Volunteer receives:** `✅ You have accepted case HR-0001... Send COMPLETE HR-0001 when finished.`
- [ ] **Mother receives:** `✅ Your request HR-0001 has been accepted! Volunteer: [name]...`
- [ ] **Verify:** Case status changed to ACCEPTED in database

### Accept Case (Arabic)
- [ ] **Send:** `قبول HR-0001`
- [ ] **Expected:** `✅ لقد قبلت الحالة HR-0001...`

### Invalid Case ID
- [ ] **Send:** `ACCEPT HR-9999`
- [ ] **Expected:** `❌ Case HR-9999 not found.`

### Non-Volunteer Accept
- [ ] **Send (from non-volunteer phone):** `ACCEPT HR-0001`
- [ ] **Expected:** `❌ You are not registered as a volunteer.`

---

## Case Complete Flow Tests

### Complete Case (English)
- [ ] **Pre-requisite:** Accepted case assigned to volunteer
- [ ] **Send (from assigned volunteer):** `COMPLETE HR-0001`
- [ ] **Volunteer receives:** `✅ Case HR-0001 marked as COMPLETE. Thank you for your help!`
- [ ] **Verify:** Case status changed to COMPLETED

### Complete Case (Arabic)
- [ ] **Send:** `انهاء HR-0001`
- [ ] **Expected:** `✅ تم وضع علامة اكتمال على الحالة HR-0001...`

### Wrong Volunteer Complete
- [ ] **Send (from different volunteer):** `COMPLETE HR-0001`
- [ ] **Expected:** `❌ You are not assigned to case HR-0001.`

---

## Availability Status Tests

### Set Available (English)
- [ ] **Send:** `AVAILABLE`
- [ ] **Expected:** `✅ You are now AVAILABLE. You will receive alerts...`
- [ ] **Verify:** Volunteer status changed to AVAILABLE

### Set Available (Arabic)
- [ ] **Send:** `متاح`
- [ ] **Expected:** `✅ أنت الآن متاح...`

### Set Busy
- [ ] **Send:** `BUSY`
- [ ] **Expected:** `✅ You are now BUSY. You will not receive new alerts...`

### Set Busy (Arabic)
- [ ] **Send:** `مشغول`
- [ ] **Expected:** `✅ أنت الآن مشغول...`

### Non-Volunteer Status Change
- [ ] **Send (from non-volunteer):** `AVAILABLE`
- [ ] **Expected:** `❌ You are not registered as a volunteer.`

---

## Status Query Tests

### Mother Status
- [ ] **Send (from registered mother):** `STATUS`
- [ ] **Expected:** `📊 Your Status: ID: M-XXXX, Camp: X, Zone: X, Risk: X...`

### Volunteer Status
- [ ] **Send (from registered volunteer):** `STATUS`
- [ ] **Expected:** `📊 Your Status: ID: V-XXXX, Status: AVAILABLE, Active cases: X, Completed: X`

### Unregistered Status
- [ ] **Send (from unregistered number):** `STATUS`
- [ ] **Expected:** `❓ You are not registered. Register as: • Mother: REG MOTHER...`

---

## Help Command Tests

### Help (English)
- [ ] **Send:** `HELP`
- [ ] **Expected:** Full command list in English

### Help (Arabic)
- [ ] **Send:** `مساعدة`
- [ ] **Expected:** Full command list in Arabic

### Unknown Command
- [ ] **Send:** `RANDOM GIBBERISH XYZ123`
- [ ] **Expected:** `❓ Unknown command. Send HELP for available commands.`

---

## Cancel Case Tests

### Cancel by Mother
- [ ] **Send (from mother with pending case):** `CANCEL HR-0001`
- [ ] **Expected:** `✅ Case HR-0001 has been cancelled.`
- [ ] **Volunteer receives:** `ℹ️ Case HR-0001 has been cancelled by the mother.`

### Cancel by Volunteer
- [ ] **Send (from assigned volunteer):** `CANCEL HR-0001`
- [ ] **Expected:** `✅ Case HR-0001 has been cancelled.`
- [ ] **Mother receives:** `ℹ️ Your case HR-0001 has been cancelled...`

### Cancel (Arabic)
- [ ] **Send:** `الغاء HR-0001`
- [ ] **Expected:** `✅ تم إلغاء الحالة HR-0001.`

---

## Edge Cases

### Special Characters
- [ ] **Send:** `REG MOTHER CAMP A-1 ZONE 3B`
- [ ] **Expected:** Handles alphanumeric camp/zone names

### Case ID Formats
- [ ] **Send:** `ACCEPT 0001` (without HR- prefix)
- [ ] **Expected:** Normalizes to HR-0001 and processes

### Mixed Language
- [ ] **Send:** `REG MOTHER مخيم A ZONE 3`
- [ ] **Expected:** Handles mixed Arabic/English gracefully

### Whitespace
- [ ] **Send:** `  REG   MOTHER   CAMP A   ZONE 3  ` (extra spaces)
- [ ] **Expected:** Parses correctly

### Newlines
- [ ] **Send:** Messages with `\n` between fields
- [ ] **Expected:** Parses correctly (supports multi-line SMS)

---

## Performance Tests

### Response Time
- [ ] Average SMS response time < 3 seconds
- [ ] Emergency alerts sent within 5 seconds

### Concurrent Requests
- [ ] System handles multiple simultaneous SMS
- [ ] No data corruption with concurrent writes

---

## Post-Test Cleanup

- [ ] Document any issues found
- [ ] Reset test data if needed
- [ ] Stop ngrok tunnel
- [ ] Stop backend server
- [ ] Review Twilio logs for errors

---

## Test Summary

| Category | Tests Passed | Tests Failed | Notes |
|----------|-------------|--------------|-------|
| Mother Registration | /4 | | |
| Volunteer Registration | /3 | | |
| Emergency Flow | /4 | | |
| Accept Flow | /4 | | |
| Complete Flow | /3 | | |
| Availability | /4 | | |
| Status Query | /3 | | |
| Help Commands | /3 | | |
| Cancel | /3 | | |
| Edge Cases | /5 | | |
| **TOTAL** | /36 | | |

**Tester:** ________________  
**Date:** ________________  
**Twilio Number:** ________________  
**Backend Version:** ________________
