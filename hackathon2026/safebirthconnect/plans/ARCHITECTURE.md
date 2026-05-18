# SafeBirth Connect — Architecture Reference

## System Overview

SafeBirth Connect is an SMS-first maternal support coordination system designed for crisis settings (refugee camps, disaster zones) where internet access is unreliable.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SAFEBIRTH CONNECT                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────────────────┐  │
│   │   MOTHERS   │     │ VOLUNTEERS  │     │    NGO COORDINATORS     │  │
│   │  (Any Phone)│     │ (Any Phone) │     │     (Flutter App)       │  │
│   └──────┬──────┘     └──────┬──────┘     └───────────┬─────────────┘  │
│          │                   │                        │                 │
│          │ SMS               │ SMS                    │ REST API        │
│          ▼                   ▼                        ▼                 │
│   ┌──────────────────────────────────────────────────────────────────┐ │
│   │                        TWILIO                                     │ │
│   │                   (SMS Gateway)                                   │ │
│   └──────────────────────────────┬───────────────────────────────────┘ │
│                                  │                                      │
│                                  │ Webhook                              │
│                                  ▼                                      │
│   ┌──────────────────────────────────────────────────────────────────┐ │
│   │                    SPRING BOOT BACKEND                            │ │
│   │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌────────────┐ │ │
│   │  │ SMS Parser  │ │  Matching   │ │ REST API    │ │  Services  │ │ │
│   │  │ (AR + EN)   │ │  Service    │ │ Controller  │ │            │ │ │
│   │  └─────────────┘ └─────────────┘ └─────────────┘ └────────────┘ │ │
│   │                          │                                        │ │
│   │                          ▼                                        │ │
│   │               ┌─────────────────────┐                            │ │
│   │               │    H2 Database      │                            │ │
│   │               │  (Embedded/File)    │                            │ │
│   │               └─────────────────────┘                            │ │
│   └──────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## User Flows

### 1. Mother Registration Flow
```
Mother SMS                          System                           Database
   │                                   │                                │
   │  "REG MOTHER CAMP A ZONE 3"      │                                │
   │ ─────────────────────────────────>│                                │
   │                                   │  Create Mother Record          │
   │                                   │ ──────────────────────────────>│
   │                                   │                                │
   │  "✅ Registered! Your ID: M-001"  │<───────────────────────────────│
   │ <─────────────────────────────────│                                │
```

### 2. Emergency Request Flow
```
Mother                    System                   Volunteer              Database
   │                         │                         │                     │
   │  "EMERGENCY"           │                         │                     │
   │ ───────────────────────>│                         │                     │
   │                         │  Find Mother           │                     │
   │                         │ ─────────────────────────────────────────────>│
   │                         │<─────────────────────────────────────────────│
   │                         │                         │                     │
   │                         │  Create HelpRequest    │                     │
   │                         │ ─────────────────────────────────────────────>│
   │                         │                         │                     │
   │                         │  Find Matching Volunteers                    │
   │                         │ ─────────────────────────────────────────────>│
   │                         │<─────────────────────────────────────────────│
   │                         │                         │                     │
   │                         │  🚨 ALERT: Zone 3      │                     │
   │                         │ ───────────────────────>│                     │
   │                         │                         │                     │
   │  "Help is on the way!" │                         │                     │
   │ <───────────────────────│                         │                     │
   │                         │                         │                     │
   │                         │       "ACCEPT HR-001"  │                     │
   │                         │ <───────────────────────│                     │
   │                         │                         │                     │
   │  "Volunteer assigned"  │                         │                     │
   │ <───────────────────────│                         │                     │
```

### 3. Volunteer Matching Priority
```
Priority 1: Certified (MIDWIFE, NURSE) + Same Zone + Available
    ↓ (if none)
Priority 2: Trained Attendant + Same Zone + Available
    ↓ (if none)
Priority 3: Any Volunteer + Same Zone + Available
    ↓ (if none)
Priority 4: Expand to adjacent zones
```

## Technology Stack

### Backend
| Component | Technology | Purpose |
|-----------|------------|---------|
| Language | Java 17 | LTS release with records, pattern matching |
| Framework | Spring Boot 3.2.x | Rapid development, auto-configuration |
| Build Tool | Maven | Dependency management |
| Database | H2 | Embedded, zero-config, file-based persistence |
| SMS Gateway | Twilio SDK 9.x | SMS send/receive via webhooks |
| Utilities | Lombok | Reduce boilerplate |

### Mobile
| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | Flutter 3.x | Cross-platform mobile |
| State | Riverpod 2.x | State management with code generation |
| Local DB | sqflite | Offline data persistence |
| HTTP | Dio | Network requests with interceptors |
| Routing | go_router | Declarative routing |
| Models | Freezed | Immutable models with code generation |

### Infrastructure (POC)
| Component | Technology | Purpose |
|-----------|------------|---------|
| SMS | Twilio Free Trial | SMS gateway |
| Tunnel | ngrok | Expose localhost for webhooks |
| Hosting | Local | Development laptop |

## Package Structure

### Backend (Java)
```
com.safebirth/
├── SafeBirthApplication.java          # Entry point
├── config/
│   ├── TwilioConfig.java              # Twilio credentials
│   └── WebConfig.java                 # CORS configuration
├── sms/
│   ├── gateway/
│   │   ├── SmsGateway.java            # Interface
│   │   ├── TwilioSmsGateway.java      # Production implementation
│   │   └── MockSmsGateway.java        # Development mock
│   ├── parser/
│   │   ├── SmsParser.java             # Parse SMS into commands
│   │   ├── SmsCommand.java            # Parsed command DTO
│   │   └── CommandType.java           # Command enum
│   └── handler/
│       ├── SmsWebhookController.java  # Twilio webhook endpoint
│       └── SmsCommandHandler.java     # Route to services
├── domain/
│   ├── mother/
│   │   ├── Mother.java                # Entity
│   │   ├── MotherRepository.java      # JPA Repository
│   │   └── MotherService.java         # Business logic
│   ├── volunteer/
│   │   ├── Volunteer.java             # Entity
│   │   ├── SkillType.java             # Enum
│   │   ├── AvailabilityStatus.java    # Enum
│   │   ├── VolunteerRepository.java   # JPA Repository
│   │   └── VolunteerService.java      # Business logic
│   └── helprequest/
│       ├── HelpRequest.java           # Entity
│       ├── RequestType.java           # Enum (EMERGENCY, SUPPORT)
│       ├── RequestStatus.java         # Enum (PENDING, ACCEPTED, etc.)
│       ├── HelpRequestRepository.java # JPA Repository
│       └── HelpRequestService.java    # Business logic
├── matching/
│   └── MatchingService.java           # Volunteer matching algorithm
├── api/
│   ├── dto/
│   │   ├── DashboardStatsDto.java     # Dashboard statistics
│   │   ├── CaseDto.java               # Case details
│   │   └── VolunteerDto.java          # Volunteer details
│   ├── DashboardController.java       # NGO dashboard API
│   └── VolunteerController.java       # Volunteer app API
└── exception/
    ├── SmsDeliveryException.java      # SMS sending failures
    └── GlobalExceptionHandler.java    # REST exception handling
```

### Flutter (Dart)
```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp configuration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_strings.dart           # Static strings
│   │   └── api_endpoints.dart         # API URLs
│   ├── network/
│   │   ├── dio_client.dart            # HTTP client setup
│   │   └── api_exceptions.dart        # Network exceptions
│   ├── database/
│   │   ├── database_helper.dart       # SQLite setup
│   │   └── tables.dart                # Table definitions
│   ├── localization/
│   │   └── app_localizations.dart     # AR/EN translations
│   └── router/
│       └── app_router.dart            # go_router config
├── features/
│   ├── inbox/                         # Volunteer case inbox
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   └── entities/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── dashboard/                     # NGO statistics
│   ├── registration/                  # Volunteer onboarding
│   └── settings/                      # Language, profile
└── shared/
    ├── widgets/                       # Reusable UI components
    └── providers/                     # Global providers
```

## Data Models

### Mother
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| phoneNumber | String | Unique, required |
| camp | String | Camp identifier |
| zone | String | Zone within camp |
| dueDate | LocalDate | Expected delivery date |
| riskLevel | Enum | LOW, MEDIUM, HIGH |
| preferredLanguage | Enum | ARABIC, ENGLISH |
| registeredAt | DateTime | Auto-generated |

### Volunteer
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| phoneNumber | String | Unique, required |
| name | String | Display name |
| skillType | Enum | MIDWIFE, NURSE, TRAINED, COMMUNITY |
| zones | Set<String> | Coverage zones |
| availability | Enum | AVAILABLE, BUSY, OFFLINE |
| preferredLanguage | Enum | ARABIC, ENGLISH |

### HelpRequest
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| caseId | String | Human-readable ID (HR-0001) |
| mother | Mother | Foreign key |
| acceptedBy | Volunteer | Foreign key (nullable) |
| requestType | Enum | EMERGENCY, SUPPORT |
| status | Enum | PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED |
| zone | String | Copied from mother |
| riskLevel | Enum | Copied from mother |
| dueDate | LocalDate | Copied from mother |
| createdAt | DateTime | Auto-generated |
| acceptedAt | DateTime | When volunteer accepted |
| closedAt | DateTime | When completed/cancelled |

## API Endpoints

### SMS (Twilio Webhook)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/sms/incoming` | Receive SMS from Twilio |
| POST | `/api/sms/simulate` | Dev: Simulate incoming SMS |

### Dashboard (Flutter App)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/dashboard/stats` | Overview statistics |
| GET | `/api/dashboard/cases` | List all cases (paginated) |
| GET | `/api/dashboard/cases/{caseId}` | Single case details |
| GET | `/api/dashboard/volunteers` | List volunteers |
| GET | `/api/dashboard/zones` | Zone-level statistics |

### Volunteer (Flutter App)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/volunteer/me` | Current volunteer profile |
| GET | `/api/volunteer/me/cases` | My assigned cases |
| PUT | `/api/volunteer/me/availability` | Update status |

## Bilingual Support

### SMS Commands (Arabic ↔ English)
| Action | English | Arabic |
|--------|---------|--------|
| Register Mother | `REG MOTHER` | `تسجيل ام` |
| Register Volunteer | `REG VOLUNTEER` | `تسجيل متطوع` |
| Emergency | `EMERGENCY` / `SOS` | `طوارئ` |
| Support Request | `SUPPORT` | `مساعدة` |
| Accept Case | `ACCEPT HR-xxxx` | `قبول xxxx` |
| Complete Case | `COMPLETE HR-xxxx` | `انهاء xxxx` |
| Set Available | `AVAILABLE` | `متاح` |
| Set Busy | `BUSY` | `مشغول` |

### Flutter RTL Support
- Use `Directionality` widget for RTL layout
- All text strings in localization files
- Test both LTR (English) and RTL (Arabic) layouts
- Font: Cairo (Arabic-friendly)

## Security Considerations (POC)

1. **No authentication** for POC (add in production)
2. **Phone number** as identifier (vulnerable to spoofing)
3. **CORS** wide open for dev (restrict in production)
4. **No rate limiting** (add for production)
5. **H2 file storage** (use PostgreSQL in production)

## Future Enhancements

1. **Authentication**: JWT for Flutter app
2. **Push notifications**: Firebase Cloud Messaging
3. **Offline sync**: Conflict resolution strategy
4. **Analytics**: Usage metrics and outcomes
5. **Multi-tenancy**: Support multiple camps/organizations
6. **Escalation**: Auto-escalate unanswered emergencies
