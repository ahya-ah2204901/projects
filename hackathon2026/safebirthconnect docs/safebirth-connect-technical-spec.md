# SafeBirth Connect — Technical Specification for AI Agent

> **Document Purpose**: This document provides complete technical specifications for an AI coding agent (Cursor) to build the SafeBirth Connect MVP. Follow all instructions precisely.

---

## 🚨 CRITICAL: Planning Protocol

**BEFORE writing any code, you MUST:**

1. **Read this entire document**
2. **Create the planning structure** in `plans/` directory
3. **Generate phase files** (PHASE-01.md, PHASE-02.md, etc.)
4. **Create PROGRESS.md** to track status
5. **Execute phases sequentially**, updating PROGRESS.md after each phase

### Planning Directory Structure

```
safebirth-connect/
├── plans/
│   ├── PROGRESS.md          # Track status of all phases
│   ├── PHASE-01.md          # Project setup & structure
│   ├── PHASE-02.md          # Backend: Core entities & SMS parsing
│   ├── PHASE-03.md          # Backend: Twilio integration & matching
│   ├── PHASE-04.md          # Backend: REST API for Flutter
│   ├── PHASE-05.md          # Flutter: Project setup & core
│   ├── PHASE-06.md          # Flutter: Features implementation
│   ├── PHASE-07.md          # Integration & testing
│   └── ARCHITECTURE.md      # High-level architecture reference
├── backend/                  # Spring Boot application
├── mobile/                   # Flutter application
└── .cursor/
    └── rules                 # Cursor-specific rules
```

---

## 📋 PROGRESS.md Template

Create this file first and update after completing each phase:

```markdown
# SafeBirth Connect — Development Progress

## Overall Status: 🔴 Not Started

| Phase | Description | Status | Started | Completed |
|-------|-------------|--------|---------|-----------|
| 01 | Project Setup & Structure | 🔴 Not Started | - | - |
| 02 | Backend: Core Entities & SMS Parsing | 🔴 Not Started | - | - |
| 03 | Backend: Twilio Integration & Matching | 🔴 Not Started | - | - |
| 04 | Backend: REST API for Flutter | 🔴 Not Started | - | - |
| 05 | Flutter: Project Setup & Core | 🔴 Not Started | - | - |
| 06 | Flutter: Features Implementation | 🔴 Not Started | - | - |
| 07 | Integration & Testing | 🔴 Not Started | - | - |

## Status Legend
- 🔴 Not Started
- 🟡 In Progress
- 🟢 Completed
- 🔵 Blocked

## Change Log
| Date | Phase | Action | Notes |
|------|-------|--------|-------|
| | | | |
```

---

## 🏗️ Project Overview

### What We're Building

**SafeBirth Connect** is an SMS-first maternal support coordination system for crisis settings:

- **Primary Channel**: SMS (works on any phone, no internet required)
- **SMS Gateway**: Twilio (free tier for POC)
- **Tunnel**: ngrok (exposes localhost to Twilio webhooks)
- **Backend**: Spring Boot (processes SMS, matching logic, REST API)
- **Mobile App**: Flutter (volunteer case inbox + dashboard)
- **Bilingual**: Arabic + English throughout

### Core User Flows

1. **Mother Registration** → Sends SMS → Gets confirmation with ID
2. **Volunteer Registration** → Sends SMS → Tagged by skill/zone
3. **Emergency Request** → Mother sends SMS → System matches volunteers → Alerts sent
4. **Case Acceptance** → Volunteer accepts → Mother notified → Case tracked

---

## 🔧 Technical Stack

### Backend

| Component | Technology | Version |
|-----------|------------|---------|
| Language | Java | 21 |
| Framework | Spring Boot | 3.2.x |
| Build Tool | Maven | 3.9.x |
| Database | H2 | Embedded |
| SMS Gateway | Twilio Java SDK | 9.x |

### Mobile

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | Latest stable |
| State Management | Riverpod 2.x | With code generation |
| Local DB | sqflite | Latest |
| HTTP Client | dio | Latest |
| Architecture | Feature-first | - |

### Infrastructure (POC)

| Component | Technology | Cost |
|-----------|------------|------|
| SMS | Twilio Free Trial | $0 |
| Tunnel | ngrok Free | $0 |
| Hosting | Local laptop | $0 |

---

## 📁 PHASE-01: Project Setup & Structure

### Objective
Set up monorepo structure, initialize both projects, configure Cursor rules.

### Tasks

#### 1.1 Create Monorepo Structure
```
safebirth-connect/
├── backend/
├── mobile/
├── plans/
├── .cursor/
│   └── rules
├── .gitignore
└── README.md
```

#### 1.2 Initialize Spring Boot Project

**Location**: `backend/`

```bash
# Use Spring Initializr or create manually
```

**pom.xml dependencies**:
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.5</version>
</parent>

<properties>
    <java.version>21</java.version>
</properties>

<dependencies>
    <!-- Core -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    
    <!-- Database -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Twilio -->
    <dependency>
        <groupId>com.twilio.sdk</groupId>
        <artifactId>twilio</artifactId>
        <version>9.14.0</version>
    </dependency>
    
    <!-- Utilities -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    
    <!-- Test -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

**Package structure**:
```
com.safebirth/
├── SafeBirthApplication.java
├── config/
│   └── TwilioConfig.java
├── sms/
│   ├── gateway/
│   │   ├── SmsGateway.java           # Interface
│   │   ├── TwilioSmsGateway.java     # Production impl
│   │   └── MockSmsGateway.java       # Dev/test impl
│   ├── parser/
│   │   ├── SmsCommand.java           # Parsed command DTO
│   │   ├── SmsParser.java            # Parser service
│   │   └── CommandType.java          # Enum
│   └── handler/
│       ├── SmsCommandHandler.java    # Routes to services
│       └── SmsWebhookController.java # Twilio webhook endpoint
├── domain/
│   ├── mother/
│   │   ├── Mother.java               # Entity
│   │   ├── MotherRepository.java
│   │   └── MotherService.java
│   ├── volunteer/
│   │   ├── Volunteer.java
│   │   ├── VolunteerRepository.java
│   │   ├── VolunteerService.java
│   │   ├── SkillType.java            # Enum
│   │   └── AvailabilityStatus.java   # Enum
│   └── helprequest/
│       ├── HelpRequest.java
│       ├── HelpRequestRepository.java
│       ├── HelpRequestService.java
│       ├── RequestType.java          # Enum
│       └── RequestStatus.java        # Enum
├── matching/
│   └── MatchingService.java          # Volunteer matching logic
└── api/
    ├── dto/
    │   ├── DashboardStatsDto.java
    │   ├── CaseDto.java
    │   └── VolunteerDto.java
    └── DashboardController.java      # REST API for Flutter
```

**application.yml**:
```yaml
spring:
  application:
    name: safebirth-connect
  profiles:
    active: dev
  datasource:
    url: jdbc:h2:file:./data/safebirth;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  h2:
    console:
      enabled: true
      path: /h2-console
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true

server:
  port: 8080

# Twilio (override in application-prod.yml or env vars)
twilio:
  account-sid: ${TWILIO_ACCOUNT_SID:mock}
  auth-token: ${TWILIO_AUTH_TOKEN:mock}
  phone-number: ${TWILIO_PHONE_NUMBER:+1234567890}

# App config
safebirth:
  sms:
    gateway: mock  # Options: mock, twilio
```

#### 1.3 Initialize Flutter Project

**Location**: `mobile/`

```bash
flutter create --org com.safebirth safebirth_connect
```

**pubspec.yaml dependencies**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Network
  dio: ^5.4.3+1
  
  # Local Database
  sqflite: ^2.3.3+1
  path: ^1.9.0
  
  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # UI
  go_router: ^14.0.2
  flutter_svg: ^2.0.10+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  
  # Code Generation
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.7.1
```

**Folder structure** (feature-first):
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart       # Arabic + English
│   │   └── api_endpoints.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── api_exceptions.dart
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── tables.dart
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── ar.dart
│   │   └── en.dart
│   └── utils/
│       └── sms_helper.dart        # SMS intent bridge
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── inbox/                     # Volunteer case inbox
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── case_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── case_repository.dart
│   │   │   └── datasources/
│   │   │       ├── case_local_datasource.dart
│   │   │       └── case_remote_datasource.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── case_entity.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── inbox_provider.dart
│   │       ├── screens/
│   │       │   └── inbox_screen.dart
│   │       └── widgets/
│   │           └── case_card.dart
│   ├── dashboard/                 # NGO dashboard
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── registration/              # Volunteer registration
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/
    │   ├── app_button.dart
    │   ├── app_text_field.dart
    │   └── loading_indicator.dart
    └── providers/
        └── locale_provider.dart
```

#### 1.4 Create .cursor/rules

```
# SafeBirth Connect — Cursor Rules

## Project Context
This is a humanitarian SMS-based maternal support system. Quality and reliability are critical.

## Code Style

### Java (Backend)
- Use Java 21 features (records, pattern matching, etc.)
- Follow Spring Boot best practices
- Use Lombok for boilerplate reduction
- Write meaningful Javadoc for public APIs
- Use constructor injection (not @Autowired on fields)

### Dart (Flutter)
- Use Riverpod 2.x with code generation (@riverpod annotations)
- Follow feature-first architecture
- Use freezed for immutable models
- Support RTL (Arabic) in all UI components
- Always handle loading/error states

## Naming Conventions

### Java
- Entities: `Mother`, `Volunteer`, `HelpRequest`
- DTOs: `MotherDto`, `CaseDto`
- Services: `MotherService`, `MatchingService`
- Repositories: `MotherRepository`

### Dart
- Files: snake_case (inbox_screen.dart)
- Classes: PascalCase (InboxScreen)
- Providers: camelCase with Provider suffix (inboxProvider)
- Features folders: lowercase (inbox, dashboard)

## Planning Protocol
1. Always check plans/PROGRESS.md before starting work
2. Update PROGRESS.md status when starting a phase
3. Update PROGRESS.md when completing a phase
4. Add notes about any blockers or changes

## Testing
- Write unit tests for services
- Write integration tests for API endpoints
- Test both Arabic and English SMS commands

## Bilingual Support
- All SMS commands must work in Arabic AND English
- Flutter UI must support RTL layout
- Use localization files for all user-facing strings

## Git Commits
- Use conventional commits: feat:, fix:, docs:, refactor:
- Reference phase number: "feat(phase-02): add Mother entity"
```

#### 1.5 Completion Criteria
- [ ] Monorepo structure created
- [ ] Spring Boot project compiles
- [ ] Flutter project runs
- [ ] .cursor/rules in place
- [ ] PROGRESS.md updated to 🟢

---

## 📁 PHASE-02: Backend Core Entities & SMS Parsing

### Objective
Implement domain entities, repositories, and SMS command parsing.

### Tasks

#### 2.1 Domain Entities

**Mother.java**:
```java
@Entity
@Table(name = "mothers")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Mother {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String phoneNumber;
    
    @Column(nullable = false)
    private String camp;
    
    @Column(nullable = false)
    private String zone;
    
    private LocalDate dueDate;
    
    @Enumerated(EnumType.STRING)
    private RiskLevel riskLevel;
    
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Language preferredLanguage = Language.ARABIC;
    
    @CreationTimestamp
    private LocalDateTime registeredAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}

public enum RiskLevel {
    LOW, MEDIUM, HIGH
}

public enum Language {
    ARABIC, ENGLISH
}
```

**Volunteer.java**:
```java
@Entity
@Table(name = "volunteers")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Volunteer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String phoneNumber;
    
    @Column(nullable = false)
    private String name;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SkillType skillType;
    
    @ElementCollection
    @CollectionTable(name = "volunteer_zones")
    private Set<String> zones = new HashSet<>();
    
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private AvailabilityStatus availability = AvailabilityStatus.AVAILABLE;
    
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private Language preferredLanguage = Language.ARABIC;
    
    @CreationTimestamp
    private LocalDateTime registeredAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}

public enum SkillType {
    MIDWIFE,      // Certified midwife
    NURSE,        // Certified nurse
    TRAINED,      // Trained birth attendant
    COMMUNITY     // Community volunteer (no certification)
}

public enum AvailabilityStatus {
    AVAILABLE,
    BUSY,
    OFFLINE
}
```

**HelpRequest.java**:
```java
@Entity
@Table(name = "help_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HelpRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String caseId;  // e.g., "HR-0001"
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mother_id", nullable = false)
    private Mother mother;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "accepted_by_id")
    private Volunteer acceptedBy;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestType requestType;
    
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RequestStatus status = RequestStatus.PENDING;
    
    @Column(nullable = false)
    private String zone;
    
    @Enumerated(EnumType.STRING)
    private RiskLevel riskLevel;
    
    private LocalDate dueDate;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    private LocalDateTime acceptedAt;
    
    private LocalDateTime closedAt;
    
    private String notes;
}

public enum RequestType {
    EMERGENCY,    // Urgent: labor, complications
    SUPPORT       // Non-urgent: check-in, preparation
}

public enum RequestStatus {
    PENDING,      // Waiting for volunteer
    ACCEPTED,     // Volunteer assigned
    IN_PROGRESS,  // Volunteer with mother
    COMPLETED,    // Successfully resolved
    CANCELLED     // Cancelled by system or user
}
```

#### 2.2 SMS Parser

**CommandType.java**:
```java
public enum CommandType {
    // Registration
    REG_MOTHER,
    REG_VOLUNTEER,
    
    // Help Requests
    EMERGENCY,
    SUPPORT,
    
    // Volunteer Actions
    ACCEPT,
    COMPLETE,
    CANCEL,
    
    // Status
    STATUS,
    AVAILABLE,
    BUSY,
    
    // Unknown
    UNKNOWN
}
```

**SmsCommand.java**:
```java
@Data
@Builder
public class SmsCommand {
    private CommandType type;
    private String senderPhone;
    private Language language;
    
    // Registration fields
    private String name;
    private String camp;
    private String zone;
    private Set<String> zones;
    private LocalDate dueDate;
    private RiskLevel riskLevel;
    private SkillType skillType;
    
    // Action fields
    private String caseId;
    
    // Raw message
    private String rawMessage;
}
```

**SmsParser.java**:
```java
@Service
@Slf4j
public class SmsParser {
    
    // Arabic keywords mapping
    private static final Map<String, String> ARABIC_TO_ENGLISH = Map.ofEntries(
        // Commands
        entry("تسجيل", "REG"),
        entry("ام", "MOTHER"),
        entry("متطوع", "VOLUNTEER"),
        entry("متطوعة", "VOLUNTEER"),
        entry("طوارئ", "EMERGENCY"),
        entry("مساعدة", "SUPPORT"),
        entry("قبول", "ACCEPT"),
        entry("انهاء", "COMPLETE"),
        entry("الغاء", "CANCEL"),
        entry("حالة", "STATUS"),
        entry("متاح", "AVAILABLE"),
        entry("متاحة", "AVAILABLE"),
        entry("مشغول", "BUSY"),
        entry("مشغولة", "BUSY"),
        
        // Fields
        entry("مخيم", "CAMP"),
        entry("منطقة", "ZONE"),
        entry("الاسم", "NAME"),
        entry("موعد", "DUE"),
        entry("خطورة", "RISK"),
        entry("مهارة", "SKILL"),
        
        // Values
        entry("عالية", "HIGH"),
        entry("متوسطة", "MEDIUM"),
        entry("منخفضة", "LOW"),
        entry("قابلة", "MIDWIFE"),
        entry("ممرضة", "NURSE"),
        entry("مدربة", "TRAINED"),
        entry("مجتمعية", "COMMUNITY")
    );
    
    public SmsCommand parse(String phoneNumber, String message) {
        String normalized = normalizeMessage(message);
        Language language = detectLanguage(message);
        
        log.info("Parsing SMS from {}: {}", phoneNumber, normalized);
        
        CommandType type = detectCommandType(normalized);
        
        return SmsCommand.builder()
            .type(type)
            .senderPhone(phoneNumber)
            .language(language)
            .rawMessage(message)
            .name(extractField(normalized, "NAME"))
            .camp(extractField(normalized, "CAMP"))
            .zone(extractField(normalized, "ZONE"))
            .zones(extractZones(normalized))
            .dueDate(extractDueDate(normalized))
            .riskLevel(extractRiskLevel(normalized))
            .skillType(extractSkillType(normalized))
            .caseId(extractCaseId(normalized))
            .build();
    }
    
    private String normalizeMessage(String message) {
        String normalized = message.toUpperCase().trim();
        
        // Replace Arabic keywords with English equivalents
        for (Map.Entry<String, String> entry : ARABIC_TO_ENGLISH.entrySet()) {
            normalized = normalized.replace(entry.getKey().toUpperCase(), entry.getValue());
        }
        
        // Normalize whitespace and newlines
        normalized = normalized.replaceAll("[\\r\\n]+", " ");
        normalized = normalized.replaceAll("\\s+", " ");
        
        return normalized;
    }
    
    private Language detectLanguage(String message) {
        // Check for Arabic characters
        boolean hasArabic = message.chars()
            .anyMatch(c -> Character.UnicodeBlock.of(c) == Character.UnicodeBlock.ARABIC);
        return hasArabic ? Language.ARABIC : Language.ENGLISH;
    }
    
    private CommandType detectCommandType(String normalized) {
        if (normalized.contains("REG MOTHER") || normalized.contains("REG MOM")) {
            return CommandType.REG_MOTHER;
        }
        if (normalized.contains("REG VOL") || normalized.contains("REG VOLUNTEER")) {
            return CommandType.REG_VOLUNTEER;
        }
        if (normalized.contains("EMERGENCY") || normalized.startsWith("SOS")) {
            return CommandType.EMERGENCY;
        }
        if (normalized.contains("SUPPORT") || normalized.contains("HELP")) {
            return CommandType.SUPPORT;
        }
        if (normalized.startsWith("ACCEPT")) {
            return CommandType.ACCEPT;
        }
        if (normalized.startsWith("COMPLETE") || normalized.startsWith("DONE")) {
            return CommandType.COMPLETE;
        }
        if (normalized.startsWith("CANCEL")) {
            return CommandType.CANCEL;
        }
        if (normalized.startsWith("STATUS")) {
            return CommandType.STATUS;
        }
        if (normalized.equals("AVAILABLE") || normalized.equals("ONLINE")) {
            return CommandType.AVAILABLE;
        }
        if (normalized.equals("BUSY") || normalized.equals("OFFLINE")) {
            return CommandType.BUSY;
        }
        
        return CommandType.UNKNOWN;
    }
    
    private String extractField(String normalized, String fieldName) {
        // Handles both "FIELD VALUE" and "FIELD:VALUE" formats
        Pattern pattern = Pattern.compile(fieldName + "[:\\s]+([A-Z0-9\\-]+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(normalized);
        return matcher.find() ? matcher.group(1).trim() : null;
    }
    
    private Set<String> extractZones(String normalized) {
        String zonesStr = extractField(normalized, "ZONE");
        if (zonesStr == null) return Set.of();
        
        // Handle comma-separated zones: "ZONE 1,2,3"
        return Arrays.stream(zonesStr.split(","))
            .map(String::trim)
            .filter(s -> !s.isEmpty())
            .collect(Collectors.toSet());
    }
    
    private LocalDate extractDueDate(String normalized) {
        // Handles: DUE 15-02, DUE 15/02, DUE 2024-02-15
        Pattern pattern = Pattern.compile("DUE[:\\s]+(\\d{1,2})[\\-/](\\d{1,2})(?:[\\-/](\\d{2,4}))?");
        Matcher matcher = pattern.matcher(normalized);
        
        if (matcher.find()) {
            int day = Integer.parseInt(matcher.group(1));
            int month = Integer.parseInt(matcher.group(2));
            int year = matcher.group(3) != null 
                ? Integer.parseInt(matcher.group(3))
                : LocalDate.now().getYear();
            
            if (year < 100) year += 2000;
            
            try {
                return LocalDate.of(year, month, day);
            } catch (Exception e) {
                log.warn("Invalid date format: {}", matcher.group());
            }
        }
        return null;
    }
    
    private RiskLevel extractRiskLevel(String normalized) {
        if (normalized.contains("RISK HIGH") || normalized.contains("HIGH RISK")) {
            return RiskLevel.HIGH;
        }
        if (normalized.contains("RISK MEDIUM") || normalized.contains("MEDIUM RISK")) {
            return RiskLevel.MEDIUM;
        }
        if (normalized.contains("RISK LOW") || normalized.contains("LOW RISK")) {
            return RiskLevel.LOW;
        }
        return null;
    }
    
    private SkillType extractSkillType(String normalized) {
        if (normalized.contains("MIDWIFE")) return SkillType.MIDWIFE;
        if (normalized.contains("NURSE")) return SkillType.NURSE;
        if (normalized.contains("TRAINED")) return SkillType.TRAINED;
        if (normalized.contains("COMMUNITY")) return SkillType.COMMUNITY;
        return null;
    }
    
    private String extractCaseId(String normalized) {
        // Extract case ID like "HR-0001" or just "0001"
        Pattern pattern = Pattern.compile("(?:ACCEPT|COMPLETE|CANCEL|STATUS)[:\\s]+(?:HR[\\-]?)?(\\d+)");
        Matcher matcher = pattern.matcher(normalized);
        return matcher.find() ? "HR-" + matcher.group(1) : null;
    }
}
```

#### 2.3 SMS Examples (Both Languages)

**Mother Registration**:
```
English (multi-line):       English (single-line):
REG MOTHER                  REG MOTHER CAMP A ZONE 3 DUE 15-02 RISK HIGH
CAMP A
ZONE 3
DUE 15-02
RISK HIGH

Arabic (multi-line):        Arabic (single-line):
تسجيل ام                    تسجيل ام مخيم أ منطقة 3 موعد 15-02 خطورة عالية
مخيم أ
منطقة 3
موعد 15-02
خطورة عالية
```

**Volunteer Registration**:
```
English:                    Arabic:
REG VOLUNTEER               تسجيل متطوعة
NAME FATIMA                 الاسم فاطمة
SKILL MIDWIFE               مهارة قابلة
ZONE 3,4,5                  منطقة 3,4,5
```

**Emergency Request**:
```
English: EMERGENCY          Arabic: طوارئ
English: SOS                Arabic: طوارئ مساعدة
```

**Accept Case**:
```
English: ACCEPT HR-0042     Arabic: قبول 0042
English: ACCEPT 0042        Arabic: قبول HR-0042
```

#### 2.4 Completion Criteria
- [ ] All entities created with proper relationships
- [ ] Repositories created
- [ ] SmsParser handles all command types
- [ ] Arabic AND English commands tested
- [ ] H2 console shows tables
- [ ] Unit tests pass
- [ ] PROGRESS.md updated to 🟢

---

## 📁 PHASE-03: Backend Twilio Integration & Matching

### Objective
Implement SMS gateway abstraction, Twilio integration, and volunteer matching.

### Tasks

#### 3.1 SMS Gateway Abstraction

**SmsGateway.java**:
```java
public interface SmsGateway {
    void sendSms(String to, String message);
    String generateTwimlResponse(String message);
}
```

**MockSmsGateway.java** (for development):
```java
@Service
@Profile("dev")
@Slf4j
public class MockSmsGateway implements SmsGateway {
    
    private final List<SmsMessage> outbox = new CopyOnWriteArrayList<>();
    
    @Override
    public void sendSms(String to, String message) {
        log.info("📤 [MOCK] SMS to {}: {}", to, message);
        outbox.add(new SmsMessage(to, message, LocalDateTime.now()));
    }
    
    @Override
    public String generateTwimlResponse(String message) {
        return """
            <?xml version="1.0" encoding="UTF-8"?>
            <Response>
                <Message>%s</Message>
            </Response>
            """.formatted(escapeXml(message));
    }
    
    public List<SmsMessage> getOutbox() {
        return List.copyOf(outbox);
    }
    
    public void clearOutbox() {
        outbox.clear();
    }
    
    private String escapeXml(String s) {
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
    
    @Data
    @AllArgsConstructor
    public static class SmsMessage {
        private String to;
        private String body;
        private LocalDateTime sentAt;
    }
}
```

**TwilioSmsGateway.java** (for production):
```java
@Service
@Profile("prod")
@Slf4j
public class TwilioSmsGateway implements SmsGateway {
    
    private final String twilioPhoneNumber;
    
    public TwilioSmsGateway(
            @Value("${twilio.account-sid}") String accountSid,
            @Value("${twilio.auth-token}") String authToken,
            @Value("${twilio.phone-number}") String phoneNumber) {
        
        Twilio.init(accountSid, authToken);
        this.twilioPhoneNumber = phoneNumber;
        log.info("Twilio initialized with number: {}", phoneNumber);
    }
    
    @Override
    public void sendSms(String to, String message) {
        try {
            Message twilioMessage = Message.creator(
                    new PhoneNumber(to),
                    new PhoneNumber(twilioPhoneNumber),
                    message
            ).create();
            
            log.info("📤 SMS sent to {}: SID={}", to, twilioMessage.getSid());
        } catch (Exception e) {
            log.error("Failed to send SMS to {}: {}", to, e.getMessage());
            throw new SmsDeliveryException("Failed to send SMS", e);
        }
    }
    
    @Override
    public String generateTwimlResponse(String message) {
        return new MessagingResponse.Builder()
                .message(new com.twilio.twiml.messaging.Message.Builder(message).build())
                .build()
                .toXml();
    }
}
```

#### 3.2 Webhook Controller

**SmsWebhookController.java**:
```java
@RestController
@RequestMapping("/api/sms")
@Slf4j
@RequiredArgsConstructor
public class SmsWebhookController {
    
    private final SmsParser smsParser;
    private final SmsCommandHandler commandHandler;
    private final SmsGateway smsGateway;
    
    /**
     * Twilio webhook endpoint - receives incoming SMS
     */
    @PostMapping(value = "/incoming", produces = MediaType.APPLICATION_XML_VALUE)
    public ResponseEntity<String> handleIncomingSms(
            @RequestParam("From") String from,
            @RequestParam("Body") String body,
            @RequestParam(value = "To", required = false) String to) {
        
        log.info("📥 Incoming SMS from {}: {}", from, body);
        
        try {
            // Parse the SMS
            SmsCommand command = smsParser.parse(from, body);
            
            // Process and get response
            String response = commandHandler.handle(command);
            
            // Return TwiML response
            String twiml = smsGateway.generateTwimlResponse(response);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_XML)
                    .body(twiml);
                    
        } catch (Exception e) {
            log.error("Error processing SMS from {}: {}", from, e.getMessage(), e);
            
            String errorResponse = "Sorry, we couldn't process your message. Please try again.";
            String twiml = smsGateway.generateTwimlResponse(errorResponse);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_XML)
                    .body(twiml);
        }
    }
    
    /**
     * Mock endpoint for development - simulate incoming SMS
     */
    @PostMapping("/simulate")
    @Profile("dev")
    public ResponseEntity<Map<String, String>> simulateSms(
            @RequestBody SimulateSmsRequest request) {
        
        SmsCommand command = smsParser.parse(request.from(), request.body());
        String response = commandHandler.handle(command);
        
        return ResponseEntity.ok(Map.of(
            "from", request.from(),
            "body", request.body(),
            "response", response
        ));
    }
    
    public record SimulateSmsRequest(String from, String body) {}
}
```

#### 3.3 Matching Service

**MatchingService.java**:
```java
@Service
@Slf4j
@RequiredArgsConstructor
public class MatchingService {
    
    private final VolunteerRepository volunteerRepository;
    private final SmsGateway smsGateway;
    
    /**
     * Find and notify matching volunteers for a help request.
     * Priority:
     * 1. Certified volunteer (MIDWIFE, NURSE) in same zone
     * 2. Trained volunteer in same zone
     * 3. Any available volunteer in same zone
     * 4. Expand to nearby zones if no match
     */
    public List<Volunteer> matchAndNotify(HelpRequest request) {
        log.info("Matching volunteers for request {} in zone {}", 
                request.getCaseId(), request.getZone());
        
        List<Volunteer> matched = findMatchingVolunteers(request);
        
        if (matched.isEmpty()) {
            log.warn("No volunteers found for request {}", request.getCaseId());
            return List.of();
        }
        
        // Notify all matched volunteers
        for (Volunteer volunteer : matched) {
            notifyVolunteer(volunteer, request);
        }
        
        log.info("Notified {} volunteers for request {}", matched.size(), request.getCaseId());
        return matched;
    }
    
    private List<Volunteer> findMatchingVolunteers(HelpRequest request) {
        String zone = request.getZone();
        
        // Try certified volunteers in same zone first
        List<Volunteer> certified = volunteerRepository
            .findByZonesContainingAndAvailabilityAndSkillTypeIn(
                zone, 
                AvailabilityStatus.AVAILABLE,
                List.of(SkillType.MIDWIFE, SkillType.NURSE)
            );
        
        if (!certified.isEmpty()) {
            return certified;
        }
        
        // Try trained volunteers
        List<Volunteer> trained = volunteerRepository
            .findByZonesContainingAndAvailabilityAndSkillType(
                zone,
                AvailabilityStatus.AVAILABLE,
                SkillType.TRAINED
            );
        
        if (!trained.isEmpty()) {
            return trained;
        }
        
        // Fall back to any available volunteer in zone
        return volunteerRepository
            .findByZonesContainingAndAvailability(zone, AvailabilityStatus.AVAILABLE);
    }
    
    private void notifyVolunteer(Volunteer volunteer, HelpRequest request) {
        String message = buildAlertMessage(volunteer, request);
        smsGateway.sendSms(volunteer.getPhoneNumber(), message);
    }
    
    private String buildAlertMessage(Volunteer volunteer, HelpRequest request) {
        boolean isArabic = volunteer.getPreferredLanguage() == Language.ARABIC;
        
        if (isArabic) {
            return String.format("""
                🚨 %s منطقة %s
                الخطورة: %s | الموعد: %s
                للقبول أرسل: قبول %s
                """,
                request.getRequestType() == RequestType.EMERGENCY ? "طوارئ" : "طلب مساعدة",
                request.getZone(),
                translateRiskLevel(request.getRiskLevel(), true),
                formatDueDate(request.getDueDate()),
                request.getCaseId()
            );
        } else {
            return String.format("""
                🚨 %s Zone %s
                Risk: %s | Due: %s
                Reply: ACCEPT %s
                """,
                request.getRequestType() == RequestType.EMERGENCY ? "EMERGENCY" : "SUPPORT REQUEST",
                request.getZone(),
                translateRiskLevel(request.getRiskLevel(), false),
                formatDueDate(request.getDueDate()),
                request.getCaseId()
            );
        }
    }
    
    private String translateRiskLevel(RiskLevel level, boolean arabic) {
        if (level == null) return arabic ? "غير محدد" : "Unknown";
        return switch (level) {
            case HIGH -> arabic ? "عالية" : "HIGH";
            case MEDIUM -> arabic ? "متوسطة" : "MEDIUM";
            case LOW -> arabic ? "منخفضة" : "LOW";
        };
    }
    
    private String formatDueDate(LocalDate date) {
        if (date == null) return "N/A";
        long daysUntil = ChronoUnit.DAYS.between(LocalDate.now(), date);
        if (daysUntil <= 0) return "TODAY";
        if (daysUntil == 1) return "Tomorrow";
        if (daysUntil <= 7) return daysUntil + " days";
        return date.format(DateTimeFormatter.ofPattern("dd-MM"));
    }
}
```

#### 3.4 Command Handler

**SmsCommandHandler.java**:
```java
@Service
@Slf4j
@RequiredArgsConstructor
public class SmsCommandHandler {
    
    private final MotherService motherService;
    private final VolunteerService volunteerService;
    private final HelpRequestService helpRequestService;
    private final MatchingService matchingService;
    
    public String handle(SmsCommand command) {
        log.info("Handling command: {} from {}", command.getType(), command.getSenderPhone());
        
        return switch (command.getType()) {
            case REG_MOTHER -> handleMotherRegistration(command);
            case REG_VOLUNTEER -> handleVolunteerRegistration(command);
            case EMERGENCY -> handleEmergencyRequest(command);
            case SUPPORT -> handleSupportRequest(command);
            case ACCEPT -> handleAcceptCase(command);
            case COMPLETE -> handleCompleteCase(command);
            case CANCEL -> handleCancelCase(command);
            case STATUS -> handleStatusRequest(command);
            case AVAILABLE -> handleAvailabilityChange(command, AvailabilityStatus.AVAILABLE);
            case BUSY -> handleAvailabilityChange(command, AvailabilityStatus.BUSY);
            case UNKNOWN -> handleUnknownCommand(command);
        };
    }
    
    private String handleMotherRegistration(SmsCommand command) {
        try {
            Mother mother = motherService.register(
                command.getSenderPhone(),
                command.getCamp(),
                command.getZone(),
                command.getDueDate(),
                command.getRiskLevel(),
                command.getLanguage()
            );
            
            return formatResponse(command.getLanguage(),
                "✅ Registered! Your ID: M-%04d\nZone: %s, Due: %s\nFor emergency, send: EMERGENCY",
                "✅ تم التسجيل! رقمك: M-%04d\nالمنطقة: %s، الموعد: %s\nللطوارئ أرسلي: طوارئ",
                mother.getId(),
                mother.getZone(),
                mother.getDueDate() != null ? mother.getDueDate().toString() : "Not set"
            );
        } catch (Exception e) {
            log.error("Registration failed: {}", e.getMessage());
            return formatResponse(command.getLanguage(),
                "❌ Registration failed. Please check format and try again.",
                "❌ فشل التسجيل. يرجى التحقق من الصيغة والمحاولة مرة أخرى."
            );
        }
    }
    
    private String handleVolunteerRegistration(SmsCommand command) {
        try {
            Volunteer volunteer = volunteerService.register(
                command.getSenderPhone(),
                command.getName(),
                command.getSkillType(),
                command.getZones(),
                command.getLanguage()
            );
            
            return formatResponse(command.getLanguage(),
                "✅ Registered as volunteer!\nName: %s\nSkill: %s\nZones: %s\nSend AVAILABLE/BUSY to update status",
                "✅ تم تسجيلك كمتطوع!\nالاسم: %s\nالمهارة: %s\nالمناطق: %s\nأرسل متاح/مشغول لتحديث الحالة",
                volunteer.getName(),
                volunteer.getSkillType(),
                String.join(", ", volunteer.getZones())
            );
        } catch (Exception e) {
            log.error("Volunteer registration failed: {}", e.getMessage());
            return formatResponse(command.getLanguage(),
                "❌ Registration failed. Required: NAME, SKILL, ZONE",
                "❌ فشل التسجيل. المطلوب: الاسم، المهارة، المنطقة"
            );
        }
    }
    
    private String handleEmergencyRequest(SmsCommand command) {
        return createHelpRequest(command, RequestType.EMERGENCY);
    }
    
    private String handleSupportRequest(SmsCommand command) {
        return createHelpRequest(command, RequestType.SUPPORT);
    }
    
    private String createHelpRequest(SmsCommand command, RequestType type) {
        try {
            // Find mother by phone
            Mother mother = motherService.findByPhone(command.getSenderPhone())
                .orElseThrow(() -> new IllegalStateException("Not registered"));
            
            // Create help request
            HelpRequest request = helpRequestService.create(mother, type);
            
            // Match and notify volunteers
            List<Volunteer> notified = matchingService.matchAndNotify(request);
            
            if (notified.isEmpty()) {
                return formatResponse(command.getLanguage(),
                    "⚠️ Request received (ID: %s) but no volunteers available. We'll keep trying.",
                    "⚠️ تم استلام الطلب (رقم: %s) لكن لا يوجد متطوعين متاحين. سنستمر بالمحاولة.",
                    request.getCaseId()
                );
            }
            
            return formatResponse(command.getLanguage(),
                "✅ Help request sent! ID: %s\n%d volunteer(s) notified. Stay by your phone.",
                "✅ تم إرسال طلب المساعدة! رقم: %s\nتم إبلاغ %d متطوع. ابقي قرب هاتفك.",
                request.getCaseId(),
                notified.size()
            );
        } catch (IllegalStateException e) {
            return formatResponse(command.getLanguage(),
                "❌ You're not registered. Send: REG MOTHER followed by your details",
                "❌ أنت غير مسجلة. أرسلي: تسجيل ام ثم بياناتك"
            );
        }
    }
    
    private String handleAcceptCase(SmsCommand command) {
        try {
            Volunteer volunteer = volunteerService.findByPhone(command.getSenderPhone())
                .orElseThrow(() -> new IllegalStateException("Not registered as volunteer"));
            
            HelpRequest request = helpRequestService.accept(command.getCaseId(), volunteer);
            
            // Notify mother
            notifyMotherOfAcceptance(request, volunteer);
            
            return formatResponse(command.getLanguage(),
                "✅ Case %s accepted!\nMother location: Zone %s\nSend COMPLETE %s when done.",
                "✅ تم قبول الحالة %s!\nموقع الأم: منطقة %s\nأرسل انهاء %s عند الانتهاء.",
                request.getCaseId(),
                request.getZone(),
                request.getCaseId()
            );
        } catch (Exception e) {
            log.error("Accept case failed: {}", e.getMessage());
            return formatResponse(command.getLanguage(),
                "❌ Could not accept case. It may already be taken.",
                "❌ تعذر قبول الحالة. قد تكون محجوزة بالفعل."
            );
        }
    }
    
    // ... Additional handlers ...
    
    private String formatResponse(Language lang, String english, String arabic, Object... args) {
        String template = lang == Language.ARABIC ? arabic : english;
        return String.format(template, args);
    }
    
    private void notifyMotherOfAcceptance(HelpRequest request, Volunteer volunteer) {
        Mother mother = request.getMother();
        Language lang = mother.getPreferredLanguage();
        
        String message = formatResponse(lang,
            "✅ Help is on the way!\nVolunteer: %s (%s)\nCase: %s",
            "✅ المساعدة في الطريق!\nالمتطوع: %s (%s)\nرقم الحالة: %s",
            volunteer.getName(),
            volunteer.getSkillType(),
            request.getCaseId()
        );
        
        // This would send SMS to mother
        // smsGateway.sendSms(mother.getPhoneNumber(), message);
    }
}
```

#### 3.5 Completion Criteria
- [ ] SMS Gateway interface + both implementations
- [ ] Twilio webhook receives and responds
- [ ] Mock gateway works for development
- [ ] Matching logic prioritizes certified volunteers
- [ ] All command handlers implemented
- [ ] Arabic responses working
- [ ] PROGRESS.md updated to 🟢

---

## 📁 PHASE-04: Backend REST API for Flutter

### Objective
Create REST endpoints for Flutter app (dashboard, cases, volunteer management).

### Tasks

#### 4.1 DTOs

```java
// DashboardStatsDto.java
public record DashboardStatsDto(
    long totalMothers,
    long totalVolunteers,
    long activeVolunteers,
    long pendingRequests,
    long activeRequests,
    long completedToday,
    Map<String, Long> mothersByZone,
    Map<String, Long> requestsByStatus,
    Map<String, Long> volunteersBySkill,
    List<DueDateCluster> upcomingDueDates
) {
    public record DueDateCluster(LocalDate date, long count) {}
}

// CaseDto.java
public record CaseDto(
    String caseId,
    String zone,
    RequestType requestType,
    RequestStatus status,
    RiskLevel riskLevel,
    LocalDate dueDate,
    LocalDateTime createdAt,
    LocalDateTime acceptedAt,
    String volunteerName,
    String volunteerPhone
) {}

// VolunteerDto.java
public record VolunteerDto(
    Long id,
    String name,
    String phoneNumber,
    SkillType skillType,
    Set<String> zones,
    AvailabilityStatus availability,
    int activeCases,
    int completedCases
) {}
```

#### 4.2 Dashboard Controller

```java
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    
    private final DashboardService dashboardService;
    private final HelpRequestService helpRequestService;
    private final VolunteerService volunteerService;
    
    @GetMapping("/stats")
    public DashboardStatsDto getStats() {
        return dashboardService.getStats();
    }
    
    @GetMapping("/cases")
    public List<CaseDto> getCases(
            @RequestParam(required = false) String zone,
            @RequestParam(required = false) RequestStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return helpRequestService.findCases(zone, status, page, size);
    }
    
    @GetMapping("/cases/{caseId}")
    public CaseDto getCase(@PathVariable String caseId) {
        return helpRequestService.findByCaseId(caseId)
            .map(this::toDto)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }
    
    @GetMapping("/volunteers")
    public List<VolunteerDto> getVolunteers(
            @RequestParam(required = false) String zone,
            @RequestParam(required = false) AvailabilityStatus availability) {
        return volunteerService.findVolunteers(zone, availability);
    }
    
    @GetMapping("/zones")
    public List<ZoneStatsDto> getZoneStats() {
        return dashboardService.getZoneStats();
    }
}
```

#### 4.3 Volunteer API (for Flutter app)

```java
@RestController
@RequestMapping("/api/volunteer")
@RequiredArgsConstructor
public class VolunteerController {
    
    private final VolunteerService volunteerService;
    private final HelpRequestService helpRequestService;
    
    @GetMapping("/me")
    public VolunteerDto getProfile(@RequestHeader("X-Phone-Number") String phone) {
        return volunteerService.findByPhone(phone)
            .map(this::toDto)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }
    
    @GetMapping("/me/cases")
    public List<CaseDto> getMyCases(@RequestHeader("X-Phone-Number") String phone) {
        return helpRequestService.findByVolunteerPhone(phone);
    }
    
    @PutMapping("/me/availability")
    public VolunteerDto updateAvailability(
            @RequestHeader("X-Phone-Number") String phone,
            @RequestBody AvailabilityUpdateRequest request) {
        return volunteerService.updateAvailability(phone, request.availability());
    }
    
    public record AvailabilityUpdateRequest(AvailabilityStatus availability) {}
}
```

#### 4.4 CORS Configuration

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")  // For dev; restrict in prod
            .allowedMethods("GET", "POST", "PUT", "DELETE")
            .allowedHeaders("*");
    }
}
```

#### 4.5 Completion Criteria
- [ ] All DTOs created
- [ ] Dashboard endpoints return data
- [ ] Volunteer endpoints work
- [ ] CORS configured
- [ ] Swagger/OpenAPI docs generated
- [ ] PROGRESS.md updated to 🟢

---

## 📁 PHASE-05: Flutter Project Setup & Core

### Objective
Set up Flutter project with Riverpod, localization, and core infrastructure.

### Tasks

#### 5.1 Main App Setup

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

**app.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'shared/providers/locale_provider.dart';

class SafeBirthApp extends ConsumerWidget {
  const SafeBirthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SafeBirth Connect',
      debugShowCheckedModeBanner: false,
      
      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF81B29A),  // Sage green
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',  // Arabic-friendly font
      ),
      
      // Router
      routerConfig: router,
    );
  }
}
```

#### 5.2 Localization

**core/localization/app_localizations.dart**:
```dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
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
      'volunteer_name': 'Volunteer Name',
      'skill_type': 'Skill Type',
      'midwife': 'Midwife',
      'nurse': 'Nurse',
      'trained': 'Trained Attendant',
      'community': 'Community Volunteer',
    },
    'ar': {
      'app_title': 'سيف بيرث كونكت',
      'inbox': 'صندوق الحالات',
      'dashboard': 'لوحة التحكم',
      'settings': 'الإعدادات',
      'emergency': 'طوارئ',
      'support': 'طلب مساعدة',
      'accept': 'قبول',
      'complete': 'إنهاء',
      'cancel': 'إلغاء',
      'available': 'متاح',
      'busy': 'مشغول',
      'zone': 'المنطقة',
      'risk_level': 'مستوى الخطورة',
      'due_date': 'موعد الولادة',
      'high': 'عالية',
      'medium': 'متوسطة',
      'low': 'منخفضة',
      'pending': 'قيد الانتظار',
      'accepted': 'مقبولة',
      'completed': 'مكتملة',
      'no_cases': 'لا توجد حالات',
      'pull_to_refresh': 'اسحب للتحديث',
      'volunteer_name': 'اسم المتطوع',
      'skill_type': 'نوع المهارة',
      'midwife': 'قابلة',
      'nurse': 'ممرضة',
      'trained': 'مدربة',
      'community': 'متطوعة مجتمعية',
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);
  
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isRtl => Localizations.localeOf(this).languageCode == 'ar';
}
```

#### 5.3 Network Layer

**core/network/dio_client.dart**:
```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api',  // Android emulator localhost
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  
  return dio;
}
```

#### 5.4 Local Database

**core/database/database_helper.dart**:
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_helper.g.dart';

@riverpod
Future<Database> database(DatabaseRef ref) async {
  final path = join(await getDatabasesPath(), 'safebirth.db');
  
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Cases table (offline inbox)
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

#### 5.5 Router

**core/router/app_router.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

part 'app_router.g.dart';

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

#### 5.6 Completion Criteria
- [ ] App runs without errors
- [ ] Arabic locale displays RTL correctly
- [ ] English locale displays LTR correctly
- [ ] Language switching works
- [ ] Dio client configured
- [ ] SQLite database initializes
- [ ] Router navigates between screens
- [ ] PROGRESS.md updated to 🟢

---

## 📁 PHASE-06: Flutter Features Implementation

### Objective
Implement inbox, dashboard, and settings features.

### Tasks

#### 6.1 Inbox Feature

**features/inbox/data/models/case_model.dart**:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'case_model.freezed.dart';
part 'case_model.g.dart';

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

**features/inbox/presentation/providers/inbox_provider.dart**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/case_model.dart';
import '../../data/repositories/case_repository.dart';

part 'inbox_provider.g.dart';

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
    final repository = ref.read(caseRepositoryProvider);
    await repository.acceptCase(caseId);
    ref.invalidateSelf();
  }
}
```

**features/inbox/presentation/screens/inbox_screen.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/inbox_provider.dart';
import '../widgets/case_card.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(inboxNotifierProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('inbox')),
      ),
      body: casesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (cases) {
          if (cases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.translate('no_cases')),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.read(inboxNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cases.length,
              itemBuilder: (context, index) => CaseCard(
                caseModel: cases[index],
                onAccept: () => ref
                    .read(inboxNotifierProvider.notifier)
                    .acceptCase(cases[index].caseId),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**features/inbox/presentation/widgets/case_card.dart**:
```dart
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/case_model.dart';

class CaseCard extends StatelessWidget {
  final CaseModel caseModel;
  final VoidCallback? onAccept;

  const CaseCard({
    super.key,
    required this.caseModel,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEmergency = caseModel.requestType == 'EMERGENCY';
    final isPending = caseModel.status == 'PENDING';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isEmergency ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isEmergency ? Icons.emergency : Icons.support_agent,
                  color: isEmergency ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.translate(isEmergency ? 'emergency' : 'support'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isEmergency ? Colors.red : Colors.blue,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(caseModel.caseId),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details
            _DetailRow(
              label: l10n.translate('zone'),
              value: caseModel.zone,
            ),
            if (caseModel.riskLevel != null)
              _DetailRow(
                label: l10n.translate('risk_level'),
                value: l10n.translate(caseModel.riskLevel!.toLowerCase()),
                valueColor: _riskColor(caseModel.riskLevel!),
              ),
            if (caseModel.dueDate != null)
              _DetailRow(
                label: l10n.translate('due_date'),
                value: caseModel.dueDate!,
              ),
            
            // Actions
            if (isPending && onAccept != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check),
                  label: Text(l10n.translate('accept')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _riskColor(String risk) {
    return switch (risk.toUpperCase()) {
      'HIGH' => Colors.red,
      'MEDIUM' => Colors.orange,
      _ => Colors.green,
    };
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 6.2 Dashboard Feature

**features/dashboard/presentation/screens/dashboard_screen.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/zone_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('dashboard')),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardStatsProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Mothers',
                        value: stats.totalMothers.toString(),
                        icon: Icons.pregnant_woman,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Volunteers',
                        value: '${stats.activeVolunteers}/${stats.totalVolunteers}',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Pending',
                        value: stats.pendingRequests.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Active',
                        value: stats.activeRequests.toString(),
                        icon: Icons.local_hospital,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Zone distribution
                Text(
                  'Mothers by Zone',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ZoneChart(data: stats.mothersByZone),
                
                const SizedBox(height: 24),
                
                // Upcoming due dates
                Text(
                  'Upcoming Due Dates',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...stats.upcomingDueDates.map((cluster) => ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(cluster.date),
                  trailing: Chip(label: Text('${cluster.count}')),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 6.3 Settings Feature (Language Toggle)

**features/settings/presentation/screens/settings_screen.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language / اللغة'),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('SafeBirth Connect v1.0.0'),
          ),
        ],
      ),
    );
  }
}
```

#### 6.4 Completion Criteria
- [ ] Inbox displays cases from API
- [ ] Inbox works offline with cached data
- [ ] Accept/Complete case buttons work
- [ ] Dashboard shows statistics
- [ ] Dashboard charts render
- [ ] Settings language toggle works
- [ ] RTL layout correct for Arabic
- [ ] PROGRESS.md updated to 🟢

---

## 📁 PHASE-07: Integration & Testing

### Objective
End-to-end testing, Twilio integration test, final polish.

### Tasks

#### 7.1 Backend Integration Tests

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class SmsIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void testMotherRegistrationFlow_English() {
        // Simulate SMS
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
    void testEmergencyMatchingFlow() {
        // Setup: Register mother and volunteer
        // Then: Send emergency
        // Assert: Volunteer notified
    }
}
```

#### 7.2 Flutter Widget Tests

```dart
void main() {
  testWidgets('CaseCard displays correctly in Arabic', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ar'),
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
    expect(find.text('طوارئ'), findsOneWidget);  // Arabic for "Emergency"
  });
}
```

#### 7.3 Twilio Live Test Checklist

```markdown
## Live SMS Testing Checklist

Prerequisites:
- [ ] Twilio account created
- [ ] Phone number obtained
- [ ] Test phones verified
- [ ] ngrok running
- [ ] Webhook URL configured in Twilio

Test Cases:
- [ ] Send "REG MOTHER CAMP A ZONE 3 DUE 15-02" → Receive confirmation
- [ ] Send "تسجيل ام مخيم أ منطقة 3" → Receive Arabic confirmation
- [ ] Send "REG VOLUNTEER NAME Test SKILL MIDWIFE ZONE 3" → Registered
- [ ] Send "EMERGENCY" from registered mother → Volunteer receives alert
- [ ] Volunteer sends "ACCEPT HR-xxxx" → Case assigned
```

#### 7.4 Final Checklist

```markdown
## Launch Readiness Checklist

Backend:
- [ ] All endpoints return expected data
- [ ] SMS parsing handles edge cases
- [ ] Matching algorithm tested
- [ ] Error messages are bilingual
- [ ] H2 console accessible for debugging

Flutter:
- [ ] App builds for Android
- [ ] Offline mode works
- [ ] Sync when online works
- [ ] Arabic RTL layout correct
- [ ] No hardcoded strings

Integration:
- [ ] Full SMS flow works end-to-end
- [ ] Flutter app receives data from backend
- [ ] ngrok + Twilio integration verified

Documentation:
- [ ] README.md complete
- [ ] API documentation available
- [ ] Setup instructions clear
```

#### 7.5 Completion Criteria
- [ ] All backend tests pass
- [ ] All Flutter tests pass
- [ ] Twilio live test successful
- [ ] Final checklist complete
- [ ] PROGRESS.md shows all phases 🟢

---

## 📄 Quick Reference

### SMS Commands Summary

| Command | English | Arabic |
|---------|---------|--------|
| Register Mother | `REG MOTHER CAMP x ZONE x DUE dd-mm` | `تسجيل ام مخيم x منطقة x موعد dd-mm` |
| Register Volunteer | `REG VOL NAME x SKILL x ZONE x` | `تسجيل متطوع الاسم x مهارة x منطقة x` |
| Emergency | `EMERGENCY` or `SOS` | `طوارئ` |
| Support | `SUPPORT` | `مساعدة` |
| Accept | `ACCEPT HR-xxxx` | `قبول xxxx` |
| Complete | `COMPLETE HR-xxxx` | `انهاء xxxx` |
| Available | `AVAILABLE` | `متاح` |
| Busy | `BUSY` | `مشغول` |

### API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/sms/incoming` | Twilio webhook |
| POST | `/api/sms/simulate` | Dev SMS simulator |
| GET | `/api/dashboard/stats` | Dashboard statistics |
| GET | `/api/dashboard/cases` | List cases |
| GET | `/api/volunteer/me` | Volunteer profile |
| GET | `/api/volunteer/me/cases` | Volunteer's cases |
| PUT | `/api/volunteer/me/availability` | Update availability |

---

## 🚀 Start Here

**Agent: Execute in order:**

1. Create `plans/` directory
2. Create `plans/PROGRESS.md` with template above
3. Create all `plans/PHASE-xx.md` files
4. Start with PHASE-01
5. Update PROGRESS.md after each phase

**Good luck!**
