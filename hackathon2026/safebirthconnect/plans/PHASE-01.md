# PHASE-01: Project Setup & Structure

## Objective
Set up monorepo structure, initialize both Spring Boot and Flutter projects, configure Cursor rules.

## Status: 🟢 Completed

## Tasks

### 1.1 Create Monorepo Structure
Create the following directory structure:

```
safebirthconnect/
├── backend/
├── mobile/
├── plans/
├── .cursor/
│   └── rules
├── .gitignore
└── README.md
```

### 1.2 Initialize Spring Boot Project

**Location**: `backend/`

**pom.xml dependencies**:
- Spring Boot 3.2.5 parent
- Java 21
- spring-boot-starter-web
- spring-boot-starter-data-jpa
- spring-boot-starter-validation
- H2 Database (runtime)
- Twilio SDK 9.14.0
- Lombok
- spring-boot-starter-test

**Package structure**:
```
com.safebirth/
├── SafeBirthApplication.java
├── config/
├── sms/
│   ├── gateway/
│   ├── parser/
│   └── handler/
├── domain/
│   ├── mother/
│   ├── volunteer/
│   └── helprequest/
├── matching/
├── api/
│   └── dto/
└── exception/
```

**application.yml configuration**:
- H2 file-based database
- H2 console enabled
- JPA auto-update schema
- Twilio credentials (environment variables)
- Mock SMS gateway for dev

### 1.3 Initialize Flutter Project

**Location**: `mobile/`

**Command**: `flutter create --org com.safebirth safebirth_connect`

**pubspec.yaml dependencies**:
- flutter_riverpod: ^2.5.1
- riverpod_annotation: ^2.3.5
- dio: ^5.4.3+1
- sqflite: ^2.3.3+1
- intl: ^0.19.0
- equatable: ^2.0.5
- freezed_annotation: ^2.4.1
- json_annotation: ^4.8.1
- go_router: ^14.0.2
- flutter_svg: ^2.0.10+1

**Dev dependencies**:
- build_runner: ^2.4.9
- riverpod_generator: ^2.4.0
- freezed: ^2.5.2
- json_serializable: ^6.7.1

**Folder structure** (feature-first):
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── network/
│   ├── database/
│   ├── localization/
│   └── utils/
├── features/
│   ├── auth/
│   ├── inbox/
│   ├── dashboard/
│   ├── registration/
│   └── settings/
└── shared/
    ├── widgets/
    └── providers/
```

### 1.4 Create .cursor/rules
Rules for code style, naming conventions, planning protocol, testing, and bilingual support.

### 1.5 Create .gitignore
Ignore common Java, Flutter, and IDE files:
- target/
- build/
- .dart_tool/
- *.iml
- .idea/
- *.class
- *.jar
- .flutter-plugins
- etc.

### 1.6 Create README.md
Basic project overview with:
- Project description
- Tech stack
- Setup instructions
- SMS commands reference

## Completion Criteria
- [ ] Monorepo structure created
- [ ] Spring Boot project compiles (`mvn clean compile`)
- [ ] Flutter project runs (`flutter run`)
- [ ] .cursor/rules in place
- [ ] .gitignore configured
- [ ] README.md created
- [ ] PROGRESS.md updated to 🟢

## Dependencies
None (this is the first phase)

## Notes
- Use Java 21 features throughout
- Configure Spring profiles (dev, prod)
- Set up bilingual support foundation
