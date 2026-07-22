# Local Mock Server

A Spring Boot 3.x application that lets developers mock third-party APIs locally — fully configurable from a web UI without writing any code.

## Overview

Many real third-party APIs are only accessible from production or whitelisted servers. This tool runs locally and:

- Provides a UI to define mock APIs, request matchers, and responses
- Intercepts requests via a catch-all `/mock/**` controller
- Supports dynamic variables, scenarios, proxy/record mode, and fault simulation

---

## Changelog

### v2.1 — Bug Fixes
> **Tag:** `v2.1`

- **Fix:** JSP EL conflict — the Import/Export page was crashing at startup due to JSP's Expression Language processor trying to evaluate JavaScript template literal `${...}` expressions as server-side EL. Fixed with `isELIgnored="true"`.
- **Fix:** Dark theme table colors were reversed — Bootstrap 5's default table CSS was overriding the custom dark styles, causing table rows to appear white and turn dark on hover. Fixed by overriding Bootstrap's CSS custom properties (`--bs-table-bg`, `--bs-table-color`) and applying `!important` where needed.

---

### v2 — Major Feature Release
> **Tag:** `v2`

#### 🎨 UI Theme Support
- Added `theme.jsp` — a shared stylesheet that drives a consistent dark theme across all pages.
- Sidebar navigation now uses a gradient dark panel with active-link indicator and hover animations.

#### 🔧 Bug Fix: Cascade Delete
- **Fixed:** Deleting a saved API or response threw a `DataIntegrityViolationException` due to orphaned rows in the `scenario_mapping` table.
- Added `@OneToMany(cascade = CascadeType.REMOVE)` on `MockResponse.scenarioMappings` and `MockApi.scenarioMappings` so JPA now deletes child `ScenarioMapping` rows before deleting the parent.

#### 📤 Selective Export
- **Export by APIs** — presents a checklist of all saved APIs. Choose specific ones; only selected APIs are written to the JSON export.
- **Export by Scenario** — pick one scenario, then choose which of its API→response mappings to include. Exports as a dedicated `type: "scenario"` JSON with the mapped response embedded per API.

#### 📥 Selective Import with Conflict Resolution
- **2-step import flow** for all formats (Mock Server JSON, OpenAPI, Postman Collection):
  1. **Preview** — upload the file; the server parses it and returns all detected endpoints *without saving anything*.
  2. **Checklist** — user selects which endpoints to actually import.
- **Conflict Detection** — if any selected endpoint's `method + path` already exists in the database, a conflict resolution row appears with two options per conflicted API:
  - ♻️ **Reuse Existing** — skips creating a duplicate API; if the import is a scenario, attaches the response to the existing API instead.
  - ➕ **Create New Copy** — imports a fresh copy regardless.
- **Smart Scenario Import** — when importing a `type: "scenario"` JSON:
  - Reuses an existing scenario by name if it already exists.
  - For "Reuse Existing" APIs, searches for a response with the same name under the existing API's matchers before creating a duplicate response.

#### 📥 Postman Collection Import — Selective
- Postman Collections can now also be previewed before importing. All endpoints appear in a checklist; only selected ones are saved.

#### 🔌 cURL Import (New)
- Paste any `curl` command into the new **Import from cURL** card.
- Parses: HTTP method (`-X`), URL→path, headers (`-H`), request body (`-d`/`--data`).
- Creates a `MockApi` + default `RequestMatcher` + `200 OK` `MockResponse` instantly.
- Errors are shown **inline** directly below the button — no modals.

---

### v1 — Initial Release
> **Tag:** `v1`

- Full mock API lifecycle: create, edit, clone, delete APIs.
- Request matchers with priority, header/query/body/path-variable matching.
- Multiple responses per matcher with Manual / Random / Sequential selection modes.
- Dynamic variables in response bodies (`${request.body.x}`, `${uuid}`, etc.).
- Fault simulation: Timeout, Empty Response, Connection Reset.
- Delay support: Fixed or Random range (ms).
- Scenario management: activate a set of responses across multiple APIs at once; cron-based auto-activation.
- Proxy / Record mode: forward to a real service and record the response.
- Call Logs with search, filtering, and configurable retention.
- Import from OpenAPI (JSON/YAML) and Postman Collection v2.1.
- Full export of all APIs and scenarios as JSON.
- Dark-themed web UI built with Bootstrap 5 and jQuery.

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

One scenario can be active at a time. Scenarios also support cron-based auto-activation.

---

## Import / Export

### Export

| Mode | Description |
|------|-------------|
| **Export by APIs** | Choose specific APIs from a checklist → downloads a `type: "apis"` JSON |
| **Export by Scenario** | Select one scenario + its mappings → downloads a `type: "scenario"` JSON with the exact mapped response per API |
| **Export All** | Quick download of everything |

### Import

All import flows use a **2-step preview** process — no data is saved until you confirm:

1. Upload the file → click **Preview**
2. Review detected endpoints in a checklist
3. Handle any conflicts (APIs already in DB) — choose **Reuse** or **Create New**
4. Click **Import Selected**

Supported formats:
- Mock Server JSON (`type: "apis"` or `type: "scenario"`)
- OpenAPI / Swagger (JSON or YAML)
- Postman Collection v2.1

### cURL Import

Paste any `curl` command and click **Parse & Import**. Supports `-X`, `-H`, `-d`/`--data` flags. Errors display inline.

---

## Proxy Recording

1. Go to **Proxy** in the sidebar
2. Enter a target URL: `https://api.real-service.com`
3. Enable Proxy Mode → Save Settings
4. Send requests to `/mock/...` — they'll be forwarded to the real service and recorded
5. Click the import icon on a recording to convert it to a reusable mock

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
│                    OpenApiImportService, PostmanImportService,
│                    CurlImportService, ProxyService, SettingsService
├── repository/      (JPA repositories for each entity)
├── entity/          MockApi, RequestMatcher, MockResponse,
│                    Scenario, ScenarioMapping, CallLog,
│                    ProxyRecording, AppSettings
├── dto/             MockApiDto, RequestMatcherDto, MockResponseDto,
│                    ScenarioDto, ScenarioMappingDto, DashboardDto
├── mapper/          MockApiMapper
└── util/            RequestMatcherUtil

src/main/webapp/WEB-INF/views/
├── theme.jsp
├── dashboard.jsp, api-list.jsp, api-detail.jsp
├── matchers.jsp, responses.jsp
├── scenarios.jsp, scenario-detail.jsp
├── logs.jsp, import-export.jsp, proxy.jsp, settings.jsp
```
