# PHASE-04: Backend REST API for Flutter

## Objective
Create REST endpoints for Flutter app: dashboard statistics, case management, and volunteer profile.

## Status: 🟢 Completed

## Tasks

### 4.1 Create DTOs

**DashboardStatsDto.java** (`com.safebirth.api.dto/`):
```java
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
```

**CaseDto.java**:
```java
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
    String volunteerPhone,
    String motherPhone  // For contact if needed
) {}
```

**VolunteerDto.java**:
```java
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

**ZoneStatsDto.java**:
```java
public record ZoneStatsDto(
    String zone,
    long motherCount,
    long volunteerCount,
    long pendingRequests,
    long activeRequests
) {}
```

**AvailabilityUpdateRequest.java**:
```java
public record AvailabilityUpdateRequest(
    AvailabilityStatus availability
) {}
```

### 4.2 Create Dashboard Service

**DashboardService.java** (`com.safebirth.api/`):

**Methods**:
- `getStats()` → DashboardStatsDto
- `getZoneStats()` → List<ZoneStatsDto>

**Implementation**:
```java
public DashboardStatsDto getStats() {
    return new DashboardStatsDto(
        motherRepository.count(),
        volunteerRepository.count(),
        volunteerRepository.countByAvailability(AVAILABLE),
        helpRequestRepository.countByStatus(PENDING),
        helpRequestRepository.countByStatus(ACCEPTED) + 
            helpRequestRepository.countByStatus(IN_PROGRESS),
        helpRequestRepository.countByStatusAndCreatedAtAfter(
            COMPLETED, LocalDate.now().atStartOfDay()),
        getMothersByZone(),
        getRequestsByStatus(),
        getVolunteersBySkill(),
        getUpcomingDueDates()
    );
}
```

### 4.3 Create Dashboard Controller

**DashboardController.java** (`com.safebirth.api/`):

**Endpoints**:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/dashboard/stats` | Overall statistics |
| GET | `/api/dashboard/cases` | List cases with filters |
| GET | `/api/dashboard/cases/{caseId}` | Single case details |
| GET | `/api/dashboard/volunteers` | List volunteers |
| GET | `/api/dashboard/zones` | Zone-level stats |

**Implementation**:
```java
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    
    @GetMapping("/stats")
    public DashboardStatsDto getStats() { ... }
    
    @GetMapping("/cases")
    public List<CaseDto> getCases(
        @RequestParam(required = false) String zone,
        @RequestParam(required = false) RequestStatus status,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) { ... }
    
    @GetMapping("/cases/{caseId}")
    public CaseDto getCase(@PathVariable String caseId) { ... }
    
    @GetMapping("/volunteers")
    public List<VolunteerDto> getVolunteers(
        @RequestParam(required = false) String zone,
        @RequestParam(required = false) AvailabilityStatus availability
    ) { ... }
    
    @GetMapping("/zones")
    public List<ZoneStatsDto> getZoneStats() { ... }
}
```

### 4.4 Create Volunteer Controller

**VolunteerController.java** (`com.safebirth.api/`):

**Endpoints** (use X-Phone-Number header for auth):

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/volunteer/me` | Get my profile |
| GET | `/api/volunteer/me/cases` | Get my assigned cases |
| PUT | `/api/volunteer/me/availability` | Update my status |

**Implementation**:
```java
@RestController
@RequestMapping("/api/volunteer")
@RequiredArgsConstructor
public class VolunteerController {
    
    @GetMapping("/me")
    public VolunteerDto getProfile(
        @RequestHeader("X-Phone-Number") String phone
    ) { ... }
    
    @GetMapping("/me/cases")
    public List<CaseDto> getMyCases(
        @RequestHeader("X-Phone-Number") String phone
    ) { ... }
    
    @PutMapping("/me/availability")
    public VolunteerDto updateAvailability(
        @RequestHeader("X-Phone-Number") String phone,
        @RequestBody AvailabilityUpdateRequest request
    ) { ... }
}
```

### 4.5 Configure CORS

**WebConfig.java** (`com.safebirth.config/`):
```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")  // Restrict in production
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .maxAge(3600);
    }
}
```

### 4.6 Add Validation

Add validation annotations to request bodies:
```java
public record AvailabilityUpdateRequest(
    @NotNull AvailabilityStatus availability
) {}
```

Handle validation errors in GlobalExceptionHandler:
```java
@ExceptionHandler(MethodArgumentNotValidException.class)
public ResponseEntity<Map<String, String>> handleValidation(
    MethodArgumentNotValidException ex
) {
    Map<String, String> errors = new HashMap<>();
    ex.getBindingResult().getFieldErrors().forEach(error -> 
        errors.put(error.getField(), error.getDefaultMessage())
    );
    return ResponseEntity.badRequest().body(errors);
}
```

### 4.7 Add API Documentation (Optional)

**Add Springdoc OpenAPI**:
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

Access Swagger UI at: `http://localhost:8080/swagger-ui.html`

### 4.8 Write Tests

**DashboardControllerTest.java**:
- testGetStats_ReturnsAllMetrics
- testGetCases_NoFilter_ReturnsAll
- testGetCases_FilterByZone
- testGetCases_FilterByStatus
- testGetCase_Found
- testGetCase_NotFound_Returns404
- testGetVolunteers_NoFilter
- testGetVolunteers_FilterByAvailability

**VolunteerControllerTest.java**:
- testGetProfile_Found
- testGetProfile_NotFound_Returns404
- testGetMyCases_ReturnsCasesForVolunteer
- testUpdateAvailability_Success
- testUpdateAvailability_InvalidStatus_Returns400

### 4.9 Add Sample Data (Optional)

**DataInitializer.java** (`com.safebirth.config/`):
```java
@Component
@Profile("dev")
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    
    @Override
    public void run(String... args) {
        // Create sample mothers
        // Create sample volunteers
        // Create sample help requests
    }
}
```

## Completion Criteria
- [ ] All DTOs created with proper records
- [ ] Dashboard endpoints return correct data
- [ ] Volunteer endpoints work with phone header
- [ ] CORS configured for Flutter app
- [ ] Validation on request bodies
- [ ] 404 returned for not found resources
- [ ] Swagger/OpenAPI docs accessible (optional)
- [ ] All tests pass
- [ ] PROGRESS.md updated to 🟢

## Dependencies
- Phase 03 completed (services and matching)

## Notes
- Using X-Phone-Number header is simple for POC; use JWT in production
- Consider pagination for large datasets
- Return appropriate HTTP status codes
- Log all API requests for debugging
