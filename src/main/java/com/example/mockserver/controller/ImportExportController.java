package com.example.mockserver.controller;

import com.example.mockserver.entity.ScenarioMapping;
import com.example.mockserver.repository.MockApiRepository;
import com.example.mockserver.repository.ScenarioMappingRepository;
import com.example.mockserver.repository.ScenarioRepository;
import com.example.mockserver.service.ImportExportService;
import com.example.mockserver.service.OpenApiImportService;
import com.example.mockserver.service.PostmanImportService;
import com.example.mockserver.service.CurlImportService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/import-export")
public class ImportExportController {

    private final ImportExportService importExportService;
    private final OpenApiImportService openApiImportService;
    private final PostmanImportService postmanImportService;
    private final CurlImportService curlImportService;
    private final MockApiRepository apiRepo;
    private final ScenarioRepository scenarioRepo;
    private final ScenarioMappingRepository mappingRepo;

    public ImportExportController(ImportExportService importExportService,
            OpenApiImportService openApiImportService,
            PostmanImportService postmanImportService,
            CurlImportService curlImportService,
            MockApiRepository apiRepo,
            ScenarioRepository scenarioRepo,
            ScenarioMappingRepository mappingRepo) {
        this.importExportService = importExportService;
        this.openApiImportService = openApiImportService;
        this.postmanImportService = postmanImportService;
        this.curlImportService = curlImportService;
        this.apiRepo = apiRepo;
        this.scenarioRepo = scenarioRepo;
        this.mappingRepo = mappingRepo;
    }

    // =========================================================================
    // PAGE
    // =========================================================================

    @GetMapping
    public String page(Model model) {
        return "import-export";
    }

    // =========================================================================
    // LISTING ENDPOINTS (for UI)
    // =========================================================================

    /** Lightweight list of all APIs for export selection. */
    @GetMapping("/apis-list")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> apisList() {
        List<Map<String, Object>> list = apiRepo.findAll().stream().map(a -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", a.getId());
            m.put("name", a.getName());
            m.put("httpMethod", a.getHttpMethod());
            m.put("endpointPath", a.getEndpointPath());
            m.put("enabled", a.isEnabled());
            return m;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    /** Lightweight list of all scenarios for export selection. */
    @GetMapping("/scenarios-list")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> scenariosList() {
        List<Map<String, Object>> list = scenarioRepo.findAllByOrderByNameAsc().stream().map(s -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", s.getId());
            m.put("name", s.getName());
            m.put("description", s.getDescription());
            m.put("active", s.isActive());
            m.put("mappingCount", s.getMappings() != null ? s.getMappings().size() : 0);
            return m;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    /** Mappings for a specific scenario for export selection checklist. */
    @GetMapping("/scenario-mappings/{scenarioId}")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> scenarioMappings(@PathVariable Long scenarioId) {
        List<ScenarioMapping> mappings = mappingRepo.findByScenarioId(scenarioId);
        List<Map<String, Object>> list = mappings.stream().map(sm -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("mappingId", sm.getId());
            m.put("apiId", sm.getMockApi() != null ? sm.getMockApi().getId() : null);
            m.put("apiName", sm.getMockApi() != null ? sm.getMockApi().getName() : "?");
            m.put("httpMethod", sm.getMockApi() != null ? sm.getMockApi().getHttpMethod() : "?");
            m.put("endpointPath", sm.getMockApi() != null ? sm.getMockApi().getEndpointPath() : "?");
            m.put("responseId", sm.getMockResponse() != null ? sm.getMockResponse().getId() : null);
            m.put("responseName", sm.getMockResponse() != null ? sm.getMockResponse().getName() : "?");
            return m;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    // =========================================================================
    // EXPORT
    // =========================================================================

    /** Legacy: export everything. */
    @GetMapping("/export")
    public ResponseEntity<byte[]> export() throws Exception {
        String json = importExportService.exportAll();
        return downloadResponse(json, "mock-config");
    }

    /** Export selected APIs. Body: {"ids": [1,2,3]} */
    @PostMapping("/export-apis")
    @ResponseBody
    public ResponseEntity<byte[]> exportApis(@RequestBody Map<String, Object> body) throws Exception {
        @SuppressWarnings("unchecked")
        List<Integer> rawIds = (List<Integer>) body.getOrDefault("ids", Collections.emptyList());
        List<Long> ids = rawIds.stream().map(i -> Long.valueOf(i.toString())).collect(Collectors.toList());
        String json = importExportService.exportApis(ids);
        return downloadResponse(json, "mock-apis");
    }

    /**
     * Export one scenario with selected mappings. Body: {"scenarioId": 1,
     * "mappingIds": [1,2]}
     */
    @PostMapping("/export-scenario")
    @ResponseBody
    public ResponseEntity<byte[]> exportScenario(@RequestBody Map<String, Object> body) throws Exception {
        Long scenarioId = Long.valueOf(body.get("scenarioId").toString());
        @SuppressWarnings("unchecked")
        List<Integer> rawIds = (List<Integer>) body.getOrDefault("mappingIds", Collections.emptyList());
        List<Long> mappingIds = rawIds.stream().map(i -> Long.valueOf(i.toString())).collect(Collectors.toList());
        String json = importExportService.exportScenario(scenarioId, mappingIds);
        return downloadResponse(json, "mock-scenario");
    }

    // =========================================================================
    // IMPORT — STEP 1: PREVIEW
    // =========================================================================

    /**
     * Preview import: parse file, return list of endpoints WITHOUT saving.
     * Param: file, type (mockserver | openapi | postman)
     */
    @PostMapping("/preview")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> preview(@RequestParam("file") MultipartFile file,
            @RequestParam("type") String type) {
        try {
            String content = new String(file.getBytes(), StandardCharsets.UTF_8);
            String filename = file.getOriginalFilename() != null ? file.getOriginalFilename().toLowerCase() : "";
            List<Map<String, String>> items;

            switch (type) {
                case "openapi":
                    boolean yaml = filename.endsWith(".yaml") || filename.endsWith(".yml");
                    items = openApiImportService.previewFromContent(content, yaml);
                    break;
                case "postman":
                    items = postmanImportService.previewFromJson(content);
                    break;
                default: // mockserver
                    items = importExportService.previewMockServerJson(content);
                    break;
            }

            List<Map<String, Object>> conflicts = importExportService.detectConflicts(items);

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("type", type);
            result.put("fileContent", content);
            result.put("items", items);
            result.put("conflicts", conflicts);
            result.put("conflictKeys", conflicts.stream().map(c -> c.get("key")).collect(Collectors.toList()));
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================================================================
    // IMPORT — STEP 2: SELECTIVE IMPORT WITH CONFLICT RESOLUTION
    // =========================================================================

    /**
     * Final import with user's selections and conflict resolutions.
     * Body: {type, fileContent, selectedKeys:[],
     * resolutions:{"GET:/users":"REUSE"|"CREATE_NEW"}}
     */
    @PostMapping("/import-selective")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> importSelective(@RequestBody Map<String, Object> body) {
        try {
            String type = (String) body.getOrDefault("type", "mockserver");
            String fileContent = (String) body.get("fileContent");
            @SuppressWarnings("unchecked")
            List<String> selectedKeys = (List<String>) body.getOrDefault("selectedKeys", Collections.emptyList());
            @SuppressWarnings("unchecked")
            Map<String, String> resolutions = (Map<String, String>) body.getOrDefault("resolutions",
                    Collections.emptyMap());

            int count;
            String filename = (String) body.getOrDefault("filename", "");

            switch (type) {
                case "openapi": {
                    boolean yaml = filename.endsWith(".yaml") || filename.endsWith(".yml");
                    count = openApiImportService.importSelected(fileContent, yaml, selectedKeys).size();
                    break;
                }
                case "postman":
                    count = postmanImportService.importSelected(fileContent, selectedKeys);
                    break;
                case "scenario":
                    count = importExportService.importScenario(fileContent, selectedKeys, resolutions);
                    break;
                default: // mockserver apis type
                    count = importExportService.importApis(fileContent, selectedKeys, resolutions);
                    break;
            }

            return ResponseEntity.ok(Map.of("message", "Imported " + count + " item(s) successfully", "count", count));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =========================================================================
    // LEGACY IMPORT ENDPOINTS (backward compatible)
    // =========================================================================

    @PostMapping("/import")
    @ResponseBody
    public ResponseEntity<String> importConfig(@RequestParam("file") MultipartFile file) {
        try {
            String content = new String(file.getBytes(), StandardCharsets.UTF_8);
            importExportService.importAll(content);
            return ResponseEntity.ok("{\"message\":\"Import successful\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @PostMapping("/openapi")
    @ResponseBody
    public ResponseEntity<String> importOpenApi(@RequestParam("file") MultipartFile file) {
        try {
            int count = openApiImportService.importFromFile(file).size();
            return ResponseEntity.ok("{\"message\":\"Imported " + count + " APIs\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @PostMapping("/postman")
    @ResponseBody
    public ResponseEntity<String> importPostman(@RequestParam("file") MultipartFile file) {
        try {
            String content = new String(file.getBytes(), StandardCharsets.UTF_8);
            int count = postmanImportService.importFromJson(content);
            return ResponseEntity.ok("{\"message\":\"Imported " + count + " APIs from Postman collection\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // =========================================================================
    // CURL IMPORT
    // =========================================================================

    /** Body: {"curlCommand": "curl -X POST ..."} */
    @PostMapping("/curl")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> importCurl(@RequestBody Map<String, String> body) {
        String cmd = body.get("curlCommand");
        try {
            var dto = curlImportService.importFromCurl(cmd);
            Map<String, Object> result = new LinkedHashMap<>();
            result.put("success", true);
            result.put("api", Map.of(
                    "id", dto.getId(),
                    "name", dto.getName(),
                    "httpMethod", dto.getHttpMethod(),
                    "endpointPath", dto.getEndpointPath()));
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> result = new LinkedHashMap<>();
            result.put("success", false);
            result.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(result);
        }
    }

    // =========================================================================
    // Helper
    // =========================================================================

    private ResponseEntity<byte[]> downloadResponse(String json, String namePrefix) {
        String filename = namePrefix + "-" +
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss")) + ".json";
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                .contentType(MediaType.APPLICATION_JSON)
                .body(json.getBytes(StandardCharsets.UTF_8));
    }
}
