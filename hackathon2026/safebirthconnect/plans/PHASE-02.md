# PHASE-02: Backend Core Entities & SMS Parsing

## Objective
Implement domain entities, repositories, and SMS command parsing with full Arabic + English support.

## Status: 🟢 Completed

## Tasks

### 2.1 Create Shared Enums

**Location**: `com.safebirth.domain/`

Create the following enums:
- `RiskLevel`: LOW, MEDIUM, HIGH
- `Language`: ARABIC, ENGLISH
- `SkillType`: MIDWIFE, NURSE, TRAINED, COMMUNITY
- `AvailabilityStatus`: AVAILABLE, BUSY, OFFLINE
- `RequestType`: EMERGENCY, SUPPORT
- `RequestStatus`: PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
- `CommandType`: REG_MOTHER, REG_VOLUNTEER, EMERGENCY, SUPPORT, ACCEPT, COMPLETE, CANCEL, STATUS, AVAILABLE, BUSY, UNKNOWN

### 2.2 Create Domain Entities

**Mother.java** (`com.safebirth.domain.mother/`):
- Fields: id, phoneNumber (unique), camp, zone, dueDate, riskLevel, preferredLanguage, registeredAt, updatedAt
- Annotations: @Entity, @Data, @Builder, Lombok
- Timestamps: @CreationTimestamp, @UpdateTimestamp

**Volunteer.java** (`com.safebirth.domain.volunteer/`):
- Fields: id, phoneNumber (unique), name, skillType, zones (Set<String>), availability, preferredLanguage, registeredAt, updatedAt
- Use @ElementCollection for zones
- Default availability: AVAILABLE

**HelpRequest.java** (`com.safebirth.domain.helprequest/`):
- Fields: id, caseId (unique, e.g., "HR-0001"), mother (ManyToOne), acceptedBy (ManyToOne, nullable), requestType, status, zone, riskLevel, dueDate, createdAt, acceptedAt, closedAt, notes
- Default status: PENDING

### 2.3 Create Repositories

Create JPA repositories for each entity:
- `MotherRepository`: findByPhoneNumber
- `VolunteerRepository`: 
  - findByPhoneNumber
  - findByZonesContainingAndAvailability
  - findByZonesContainingAndAvailabilityAndSkillType
  - findByZonesContainingAndAvailabilityAndSkillTypeIn
- `HelpRequestRepository`: 
  - findByCaseId
  - findByStatus
  - findByAcceptedBy
  - countByStatus

### 2.4 Create SMS Parser

**SmsCommand.java** (`com.safebirth.sms.parser/`):
DTO to hold parsed command data:
- type, senderPhone, language
- Registration: name, camp, zone, zones, dueDate, riskLevel, skillType
- Action: caseId
- rawMessage

**SmsParser.java** (`com.safebirth.sms.parser/`):
Service to parse SMS messages:

1. **Arabic-to-English mapping**:
```java
Map.ofEntries(
    entry("تسجيل", "REG"),
    entry("ام", "MOTHER"),
    entry("متطوع", "VOLUNTEER"),
    entry("طوارئ", "EMERGENCY"),
    entry("مساعدة", "SUPPORT"),
    entry("قبول", "ACCEPT"),
    entry("انهاء", "COMPLETE"),
    entry("الغاء", "CANCEL"),
    entry("متاح", "AVAILABLE"),
    entry("مشغول", "BUSY"),
    // ... field names and values
)
```

2. **Methods**:
   - `parse(phoneNumber, message)` → SmsCommand
   - `normalizeMessage(message)` → Convert Arabic keywords to English
   - `detectLanguage(message)` → Check for Arabic Unicode block
   - `detectCommandType(normalized)` → Match command patterns
   - `extractField(normalized, fieldName)` → Regex extraction
   - `extractZones(normalized)` → Comma-separated zones
   - `extractDueDate(normalized)` → Parse dd-mm or dd/mm format
   - `extractRiskLevel(normalized)` → HIGH, MEDIUM, LOW
   - `extractSkillType(normalized)` → MIDWIFE, NURSE, TRAINED, COMMUNITY
   - `extractCaseId(normalized)` → HR-xxxx pattern

### 2.5 Create Basic Services

**MotherService.java**:
- register(phone, camp, zone, dueDate, riskLevel, language)
- findByPhone(phone)
- update(mother)

**VolunteerService.java**:
- register(phone, name, skillType, zones, language)
- findByPhone(phone)
- updateAvailability(phone, status)

**HelpRequestService.java**:
- create(mother, requestType)
- generateCaseId() → Sequential HR-xxxx
- findByCaseId(caseId)
- accept(caseId, volunteer)
- complete(caseId)
- cancel(caseId)

### 2.6 SMS Examples to Support

**Mother Registration**:
```
English: REG MOTHER CAMP A ZONE 3 DUE 15-02 RISK HIGH
Arabic:  تسجيل ام مخيم أ منطقة 3 موعد 15-02 خطورة عالية
```

**Volunteer Registration**:
```
English: REG VOLUNTEER NAME FATIMA SKILL MIDWIFE ZONE 3,4,5
Arabic:  تسجيل متطوعة الاسم فاطمة مهارة قابلة منطقة 3,4,5
```

**Emergency**:
```
English: EMERGENCY or SOS
Arabic:  طوارئ
```

**Accept Case**:
```
English: ACCEPT HR-0042 or ACCEPT 0042
Arabic:  قبول 0042
```

### 2.7 Write Unit Tests

**SmsParserTest.java**:
- testParseMotherRegistration_English
- testParseMotherRegistration_Arabic
- testParseVolunteerRegistration_English
- testParseVolunteerRegistration_Arabic
- testParseEmergency_English
- testParseEmergency_Arabic
- testParseAccept_English
- testParseAccept_Arabic
- testDetectLanguage_Arabic
- testDetectLanguage_English
- testExtractDueDate_Various_Formats

**ServiceTests**:
- MotherServiceTest
- VolunteerServiceTest
- HelpRequestServiceTest

## Completion Criteria
- [x] All enums created
- [x] All entities created with proper JPA annotations
- [x] All repositories created with custom query methods
- [x] SmsParser handles all command types
- [x] Arabic AND English commands parse correctly
- [x] Services implement core business logic
- [x] H2 console shows tables correctly
- [x] Unit tests pass (142 tests, 100% pass rate)
- [x] PROGRESS.md updated to 🟢

## Dependencies
- Phase 01 completed (project structure in place)

## Notes
- Use Lombok to reduce boilerplate
- Add @Slf4j for logging
- Handle edge cases (missing fields, malformed dates)
- Arabic text direction doesn't affect parsing
