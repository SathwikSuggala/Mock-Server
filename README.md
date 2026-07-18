# Local Mock Server

A Spring Boot 3.x application that lets developers mock third-party APIs locally — fully configurable from a web UI without writing any code.

## Overview

Many real third-party APIs are only accessible from production or whitelisted servers. This tool runs locally and:

- Provides a UI to define mock APIs, request matchers, and responses
- Intercepts requests via a catch-all `/mock/**` controller
- Supports dynamic variables, scenarios, proxy/record mode, and fault simulation

---

## Tech Stack

| Layer      | Technology                              |
|------------|-----------------------------------------|
| Backend    | Java 17+, Spring Boot 3.2, Spring MVC, Spring Data JPA |
| Frontend   | JSP, Bootstrap 5, jQuery                |
| Database   | MySQL                                   |
| Build      | Maven                                   |
| Server     | Embedded Tomcat                         |

---

## Setup

### 1. MySQL Configuration

Create a database:
```sql
CREATE DATABASE mockserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Edit `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/mockserver?useSSL=false&serverTimezone=UTC
spring.datasource.username=your_username
spring.datasource.password=your_password
```

Tables are created automatically by Hibernate (`ddl-auto=update`).

### 2. Build & Run

```bash
mvn clean install
mvn spring-boot:run
```

Open your browser at: **http://localhost:8080**

---

## How It Works

All mock requests go through the prefix `/mock`. For example:

- You configure API: `POST /customer/search`
- You call it as: `POST http://localhost:8080/mock/customer/search`

---

## Creating APIs

1. Go to **APIs** in the sidebar
2. Click **New API**
3. Enter method, path, name, tags
4. Save

**Path variable examples:**
- `/customer/{id}`
- `/account/{accountId}/balance`

---

## Creating Matchers

Each API can have multiple request matchers. Higher priority matchers are evaluated first.

1. Open an API → click **Add Matcher**
2. Configure match criteria (all fields are optional — empty = match all):
   - **Headers** — JSON map: `{"x-api-key": "abc"}`
   - **Query Params** — JSON map: `{"status": "active"}`
   - **Path Variables** — JSON map: `{"id": "123"}`
   - **Body** — string match with type: Contains / Exact / Regex / JSONPath
3. Choose **Response Selection Mode**:
   - **Manual** — you pick the active response with a radio button
   - **Random** — each response has a weight (e.g., 80 / 20)
   - **Sequential** — cycles through responses in order, then repeats

---

## Managing Responses

For each matcher, you can add multiple responses:

1. Open Matcher → click **Responses**
2. Click **Add Response**
3. Configure:
   - HTTP status, Content-Type, body
   - Headers (JSON), Cookies (JSON)
   - Delay: Fixed or Random
   - Fault: Timeout / Empty Response / Connection Reset

**Dynamic variables in response body:**

| Variable | Resolves To |
|----------|-------------|
| `${request.body.fieldName}` | JSON field from request body |
| `${request.path.id}` | Path variable `{id}` |
| `${request.query.param}` | Query parameter value |
| `${request.header.x-api-key}` | Request header value |
| `${uuid}` | Random UUID |
| `${currentTimestamp}` | Current ISO timestamp |

---

## Scenario Management

Scenarios let you activate a set of responses across multiple APIs at once.

1. Go to **Scenarios** → **New Scenario**
2. Open scenario → **Add API Mapping** (select API + Response)
3. Click **Activate** to switch all mapped responses at once

One scenario can be active at a time.

---

## OpenAPI Import

1. Go to **Import / Export**
2. Upload a `swagger.json`, `openapi.json`, or `openapi.yaml`
3. APIs are created automatically with default matchers and `200 OK` responses
4. Edit each API's responses as needed

---

## Proxy Recording

1. Go to **Proxy** in the sidebar
2. Enter a target URL: `https://api.real-service.com`
3. Enable Proxy Mode → Save Settings
4. Send requests to `/mock/...` — they'll be forwarded to the real service and recorded
5. Click the import icon on a recording to convert it to a reusable mock

---

## Export / Import

- **Export** — downloads all APIs, matchers, responses, and scenarios as JSON
- **Import** — re-imports from a previously exported JSON file (creates new records)

---

## Call Logs

Every request to `/mock/**` is logged. Go to **Call Logs** to:

- Search by method, path, status, or time range
- View request headers, body, and response body
- Clear all logs

Log retention defaults to 30 days (configurable in **Settings**).

---

## Settings

| Setting | Description |
|---------|-------------|
| Call Log Retention | How many days to keep logs |
| Proxy Target URL | Base URL for proxy mode |
| Enable Proxy Mode | Toggle proxy/record mode |

---

## Project Structure

```
src/main/java/com/example/mockserver/
├── MockServerApplication.java
├── config/          WebConfig
├── controller/      DashboardController, ApiManagementController,
│                    MatcherController, ResponseController,
│                    ScenarioController, CallLogController,
│                    ImportExportController, ProxyController,
│                    SettingsController, MockDispatchController
├── service/         MockApiService, RequestMatcherService,
│                    MockResponseService, ScenarioService,
│                    MockEngineService, CallLogService,
│                    DashboardService, ImportExportService,
│                    OpenApiImportService, ProxyService, SettingsService
├── repository/      (JPA repositories for each entity)
├── entity/          MockApi, RequestMatcher, MockResponse,
│                    Scenario, ScenarioMapping, CallLog,
│                    ProxyRecording, StatefulFlow, AppSettings
├── dto/             MockApiDto, RequestMatcherDto, MockResponseDto,
│                    ScenarioDto, ScenarioMappingDto, DashboardDto
├── mapper/          MockApiMapper
└── util/            RequestMatcherUtil

src/main/webapp/WEB-INF/views/
├── dashboard.jsp, api-list.jsp, api-detail.jsp
├── matchers.jsp, responses.jsp
├── scenarios.jsp, scenario-detail.jsp
├── logs.jsp, import-export.jsp, proxy.jsp, settings.jsp
```
