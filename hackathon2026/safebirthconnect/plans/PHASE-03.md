# PHASE-03: Backend Twilio Integration & Matching

## Objective
Implement SMS gateway abstraction, Twilio integration, volunteer matching algorithm, and command handler.

## Status: 🟢 Completed

## Tasks

### 3.1 Create SMS Gateway Abstraction

**SmsGateway.java** (`com.safebirth.sms.gateway/`):
```java
public interface SmsGateway {
    void sendSms(String to, String message);
    String generateTwimlResponse(String message);
}
```

### 3.2 Implement Mock SMS Gateway

**MockSmsGateway.java** (Profile: dev):
- Log outbound SMS to console with 📤 emoji
- Store messages in memory list for testing
- Provide `getOutbox()` method for test assertions
- Provide `clearOutbox()` method
- Generate TwiML XML response manually

### 3.3 Implement Twilio SMS Gateway

**TwilioSmsGateway.java** (Profile: prod):
- Initialize Twilio SDK in constructor
- Inject credentials from `@Value`:
  - `${twilio.account-sid}`
  - `${twilio.auth-token}`
  - `${twilio.phone-number}`
- Implement `sendSms()` using `Message.creator()`
- Implement `generateTwimlResponse()` using TwiML SDK
- Handle TwilioException → throw SmsDeliveryException

### 3.4 Create Custom Exceptions

**SmsDeliveryException.java** (`com.safebirth.exception/`):
- Extends RuntimeException
- Constructor with message and cause

**GlobalExceptionHandler.java**:
- @RestControllerAdvice
- Handle SmsDeliveryException
- Handle validation exceptions
- Return appropriate error responses

### 3.5 Create SMS Webhook Controller

**SmsWebhookController.java** (`com.safebirth.sms.handler/`):

1. **Main Webhook** (POST `/api/sms/incoming`):
   - Accept Twilio parameters: From, Body, To (optional)
   - Parse message using SmsParser
   - Route to SmsCommandHandler
   - Return TwiML response (XML)
   - Log incoming messages with 📥 emoji
   - Handle errors gracefully with user-friendly messages

2. **Simulator** (POST `/api/sms/simulate`, Profile: dev):
   - Accept JSON body: { from, body }
   - Process same as webhook
   - Return JSON response instead of TwiML
   - Useful for testing without Twilio

### 3.6 Create Matching Service

**MatchingService.java** (`com.safebirth.matching/`):

**Matching Algorithm**:
```
1. Find certified volunteers (MIDWIFE, NURSE) in same zone + AVAILABLE
2. If none, find TRAINED volunteers in same zone + AVAILABLE
3. If none, find any COMMUNITY volunteers in same zone + AVAILABLE
4. If still none, log warning and return empty list
```

**Methods**:
- `matchAndNotify(HelpRequest)` → List<Volunteer>
- `findMatchingVolunteers(HelpRequest)` → List<Volunteer>
- `notifyVolunteer(Volunteer, HelpRequest)` → Send SMS alert
- `buildAlertMessage(Volunteer, HelpRequest)` → Bilingual message

**Alert Message Format**:
```
English:
🚨 EMERGENCY Zone 3
Risk: HIGH | Due: Tomorrow
Reply: ACCEPT HR-0042

Arabic:
🚨 طوارئ منطقة 3
الخطورة: عالية | الموعد: غداً
للقبول أرسل: قبول HR-0042
```

### 3.7 Create SMS Command Handler

**SmsCommandHandler.java** (`com.safebirth.sms.handler/`):

Main routing method:
```java
public String handle(SmsCommand command) {
    return switch (command.getType()) {
        case REG_MOTHER -> handleMotherRegistration(command);
        case REG_VOLUNTEER -> handleVolunteerRegistration(command);
        case EMERGENCY -> handleEmergencyRequest(command);
        case SUPPORT -> handleSupportRequest(command);
        case ACCEPT -> handleAcceptCase(command);
        case COMPLETE -> handleCompleteCase(command);
        case CANCEL -> handleCancelCase(command);
        case STATUS -> handleStatusRequest(command);
        case AVAILABLE -> handleAvailabilityChange(command, AVAILABLE);
        case BUSY -> handleAvailabilityChange(command, BUSY);
        case UNKNOWN -> handleUnknownCommand(command);
    };
}
```

**Handler Methods**:

1. `handleMotherRegistration`:
   - Register mother via MotherService
   - Return confirmation with ID: "✅ Registered! Your ID: M-0001"
   - Handle errors: "❌ Registration failed..."

2. `handleVolunteerRegistration`:
   - Register volunteer via VolunteerService
   - Return confirmation with details
   - Handle missing required fields

3. `handleEmergencyRequest`:
   - Verify sender is registered mother
   - Create help request with RequestType.EMERGENCY
   - Call matchingService.matchAndNotify()
   - Return confirmation with case ID and volunteer count

4. `handleSupportRequest`:
   - Same as emergency but RequestType.SUPPORT

5. `handleAcceptCase`:
   - Verify sender is registered volunteer
   - Call helpRequestService.accept()
   - Notify mother of acceptance
   - Return confirmation to volunteer

6. `handleCompleteCase`:
   - Verify volunteer owns the case
   - Call helpRequestService.complete()
   - Return confirmation

7. `handleCancelCase`:
   - Call helpRequestService.cancel()
   - Notify relevant parties

8. `handleStatusRequest`:
   - Return case status or user status

9. `handleAvailabilityChange`:
   - Update volunteer availability
   - Return confirmation

10. `handleUnknownCommand`:
    - Return help message with valid commands

**Helper Methods**:
- `formatResponse(Language, englishTemplate, arabicTemplate, args...)` → Format bilingual response

### 3.8 Configure Twilio Settings

**application-prod.yml**:
```yaml
twilio:
  account-sid: ${TWILIO_ACCOUNT_SID}
  auth-token: ${TWILIO_AUTH_TOKEN}
  phone-number: ${TWILIO_PHONE_NUMBER}

safebirth:
  sms:
    gateway: twilio
```

**TwilioConfig.java** (`com.safebirth.config/`):
- @Configuration
- @ConfigurationProperties(prefix = "twilio")
- Properties: accountSid, authToken, phoneNumber

### 3.9 Write Integration Tests

**SmsWebhookControllerTest.java**:
- testIncomingSms_MotherRegistration
- testIncomingSms_EmergencyTriggersMatching
- testSimulateSms_ReturnsJsonResponse
- testIncomingSms_Error_ReturnsErrorTwiml

**MatchingServiceTest.java**:
- testMatch_PrioritizesCertified
- testMatch_FallsBackToTrained
- testMatch_NoMatchReturnsEmpty
- testNotify_SendsBilingualMessages

## Completion Criteria
- [x] SMS Gateway interface created
- [x] MockSmsGateway works for development
- [x] TwilioSmsGateway configured (not tested with live Twilio yet)
- [x] Webhook endpoint receives and responds correctly
- [x] Matching algorithm prioritizes certified volunteers
- [x] All command handlers implemented
- [x] Arabic responses working correctly
- [x] Error handling returns user-friendly messages
- [x] Integration tests pass
- [x] PROGRESS.md updated to 🟢

## Dependencies
- Phase 02 completed (entities and parser)

## Notes
- ngrok will be needed to test live Twilio (Phase 07)
- Mock gateway enables full flow testing without Twilio
- Consider rate limiting for production
- Log all SMS interactions for debugging
