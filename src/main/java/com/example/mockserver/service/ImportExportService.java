package com.example.mockserver.service;

import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class ImportExportService {

    private final MockApiRepository apiRepo;
    private final ScenarioRepository scenarioRepo;
    private final ScenarioMappingRepository mappingRepo;
    private final MockResponseRepository responseRepo;
    private final ObjectMapper objectMapper;

    public ImportExportService(MockApiRepository apiRepo,
            ScenarioRepository scenarioRepo,
            ScenarioMappingRepository mappingRepo,
            MockResponseRepository responseRepo) {
        this.apiRepo = apiRepo;
        this.scenarioRepo = scenarioRepo;
        this.mappingRepo = mappingRepo;
        this.responseRepo = responseRepo;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    // =========================================================================
    // EXPORT
    // =========================================================================

    /** Export all APIs (legacy). */
    public String exportAll() throws Exception {
        Map<String, Object> export = new LinkedHashMap<>();
        export.put("type", "apis");
        export.put("apis", apiRepo.findAll());
        export.put("scenarios", scenarioRepo.findAll());
        return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(export);
    }

    /** Export selected APIs by IDs. */
    public String exportApis(List<Long> ids) throws Exception {
        List<MockApi> apis = ids == null || ids.isEmpty()
                ? apiRepo.findAll()
                : ids.stream().map(id -> apiRepo.findById(id).orElse(null))
                        .filter(Objects::nonNull).collect(Collectors.toList());
        Map<String, Object> export = new LinkedHashMap<>();
        export.put("type", "apis");
        export.put("apis", apis);
        return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(export);
    }

    /** Export one scenario + selected mappings (by mapping IDs). */
    public String exportScenario(Long scenarioId, List<Long> mappingIds) throws Exception {
        Scenario scenario = scenarioRepo.findById(scenarioId)
                .orElseThrow(() -> new RuntimeException("Scenario not found: " + scenarioId));

        List<ScenarioMapping> allMappings = mappingRepo.findByScenarioId(scenarioId);
        Set<Long> allowed = mappingIds != null && !mappingIds.isEmpty() ? new HashSet<>(mappingIds) : null;

        List<Map<String, Object>> mappingExports = new ArrayList<>();
        for (ScenarioMapping sm : allMappings) {
            if (allowed != null && !allowed.contains(sm.getId()))
                continue;
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("api", sm.getMockApi());
            entry.put("response", sm.getMockResponse());
            mappingExports.add(entry);
        }

        Map<String, Object> scenarioData = new LinkedHashMap<>();
        scenarioData.put("name", scenario.getName());
        scenarioData.put("description", scenario.getDescription());
        scenarioData.put("cronExpression", scenario.getCronExpression());

        Map<String, Object> export = new LinkedHashMap<>();
        export.put("type", "scenario");
        export.put("scenario", scenarioData);
        export.put("mappings", mappingExports);
        return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(export);
    }

    // =========================================================================
    // PREVIEW (parse without saving)
    // =========================================================================

    /**
     * Preview a MockServer JSON file.
     * Returns a list of {key, method, path, name} for each API in the file.
     */
    public List<Map<String, String>> previewMockServerJson(String json) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        String type = root.path("type").asText("apis");
        List<Map<String, String>> items = new ArrayList<>();

        if ("scenario".equals(type)) {
            JsonNode scenarioNode = root.path("scenario");
            String scenarioName = scenarioNode.path("name").asText("Unnamed Scenario");
            JsonNode mappings = root.path("mappings");
            if (mappings.isArray()) {
                for (JsonNode m : mappings) {
                    JsonNode api = m.path("api");
                    JsonNode resp = m.path("response");
                    String method = api.path("httpMethod").asText("GET");
                    String path = api.path("endpointPath").asText("/");
                    String name = api.path("name").asText(method + " " + path);
                    String respName = resp.path("name").asText("200 OK");
                    Map<String, String> item = new LinkedHashMap<>();
                    item.put("key", method + ":" + path);
                    item.put("method", method);
                    item.put("path", path);
                    item.put("name", name + " → " + respName);
                    item.put("scenarioName", scenarioName);
                    items.add(item);
                }
            }
        } else {
            JsonNode apis = root.path("apis");
            if (apis.isArray()) {
                for (JsonNode api : apis) {
                    String method = api.path("httpMethod").asText("GET");
                    String path = api.path("endpointPath").asText("/");
                    String name = api.path("name").asText(method + " " + path);
                    Map<String, String> item = new LinkedHashMap<>();
                    item.put("key", method + ":" + path);
                    item.put("method", method);
                    item.put("path", path);
                    item.put("name", name);
                    items.add(item);
                }
            }
        }
        return items;
    }

    /**
     * Detect which keys (method:path) from the preview already exist in DB.
     * Returns list of {key, existingId, existingName} for conflicts.
     */
    public List<Map<String, Object>> detectConflicts(List<Map<String, String>> previewItems) {
        List<Map<String, Object>> conflicts = new ArrayList<>();
        for (Map<String, String> item : previewItems) {
            String key = item.get("key");
            String[] parts = key.split(":", 2);
            if (parts.length < 2)
                continue;
            apiRepo.findByHttpMethodAndEndpointPath(parts[0], parts[1]).ifPresent(existing -> {
                Map<String, Object> conflict = new LinkedHashMap<>();
                conflict.put("key", key);
                conflict.put("method", parts[0]);
                conflict.put("path", parts[1]);
                conflict.put("name", item.get("name"));
                conflict.put("existingId", existing.getId());
                conflict.put("existingName", existing.getName());
                conflicts.add(conflict);
            });
        }
        return conflicts;
    }

    // =========================================================================
    // IMPORT
    // =========================================================================

    /**
     * Legacy full import. Used by old /import endpoint.
     */
    public void importAll(String json) throws Exception {
        importApis(json, null, Collections.emptyMap());
    }

    /**
     * Import selected APIs from a MockServer "type:apis" JSON.
     * resolutions: key → "REUSE" | "CREATE_NEW"
     */
    public int importApis(String json, List<String> selectedKeys, Map<String, String> resolutions) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        JsonNode apis = root.path("apis");
        if (!apis.isArray())
            return 0;

        Set<String> allowed = selectedKeys != null && !selectedKeys.isEmpty() ? new HashSet<>(selectedKeys) : null;
        int count = 0;

        for (JsonNode apiNode : apis) {
            String method = apiNode.path("httpMethod").asText("GET");
            String path = apiNode.path("endpointPath").asText("/");
            String key = method + ":" + path;
            if (allowed != null && !allowed.contains(key))
                continue;

            String resolution = resolutions.getOrDefault(key, "CREATE_NEW");
            if ("REUSE".equals(resolution)) {
                // Skip — existing API is kept as-is
                continue;
            }

            // CREATE_NEW: deserialize and save
            MockApi api = objectMapper.treeToValue(apiNode, MockApi.class);
            resetIds(api);
            apiRepo.save(api);
            count++;
        }
        return count;
    }

    /**
     * Import a scenario-type JSON.
     * selectedKeys: which method:path mappings to include (null = all).
     * resolutions: method:path → "REUSE" | "CREATE_NEW"
     */
    public int importScenario(String json, List<String> selectedKeys, Map<String, String> resolutions)
            throws Exception {
        JsonNode root = objectMapper.readTree(json);
        JsonNode scenarioNode = root.path("scenario");
        JsonNode mappingsNode = root.path("mappings");
        if (!mappingsNode.isArray())
            return 0;

        Set<String> allowed = selectedKeys != null && !selectedKeys.isEmpty() ? new HashSet<>(selectedKeys) : null;

        // Get or create scenario
        String scenarioName = scenarioNode.path("name").asText("Imported Scenario");
        Scenario scenario = scenarioRepo.findByName(scenarioName).orElseGet(() -> {
            Scenario s = new Scenario();
            s.setName(scenarioName);
            s.setDescription(scenarioNode.path("description").asText(""));
            String cron = scenarioNode.path("cronExpression").asText(null);
            if (cron != null && !cron.isBlank())
                s.setCronExpression(cron);
            return scenarioRepo.save(s);
        });

        int count = 0;
        for (JsonNode mappingNode : mappingsNode) {
            JsonNode apiNode = mappingNode.path("api");
            JsonNode respNode = mappingNode.path("response");

            String method = apiNode.path("httpMethod").asText("GET");
            String path = apiNode.path("endpointPath").asText("/");
            String key = method + ":" + path;
            if (allowed != null && !allowed.contains(key))
                continue;

            String resolution = resolutions.getOrDefault(key, "CREATE_NEW");

            MockApi api;
            MockResponse response;

            if ("REUSE".equals(resolution)) {
                // Find the existing API
                Optional<MockApi> existingOpt = apiRepo.findByHttpMethodAndEndpointPath(method, path);
                if (existingOpt.isEmpty()) {
                    // Fallback: create anyway
                    api = createApiFromNode(apiNode);
                    response = createResponseUnderApi(api, respNode);
                } else {
                    api = existingOpt.get();
                    // Try to find same response by name under this API's matchers
                    String respName = respNode.path("name").asText("200 OK");
                    response = findOrCreateResponse(api, respName, respNode);
                }
            } else {
                // CREATE_NEW
                api = createApiFromNode(apiNode);
                response = createResponseUnderApi(api, respNode);
            }

            // Create scenario mapping
            ScenarioMapping sm = new ScenarioMapping();
            sm.setScenario(scenario);
            sm.setMockApi(api);
            sm.setMockResponse(response);
            mappingRepo.save(sm);
            count++;
        }
        return count;
    }

    // =========================================================================
    // Helpers
    // =========================================================================

    private MockApi createApiFromNode(JsonNode apiNode) throws Exception {
        MockApi api = objectMapper.treeToValue(apiNode, MockApi.class);
        resetIds(api);
        // Ensure at least one matcher + response
        if (api.getMatchers() == null || api.getMatchers().isEmpty()) {
            RequestMatcher m = new RequestMatcher();
            m.setName("Default");
            m.setMockApi(api);
            m.setPriority(0);
            m.setEnabled(true);
            m.setResponseSelectionMode("MANUAL");
            api.setMatchers(List.of(m));
        } else {
            api.getMatchers().forEach(m -> m.setMockApi(api));
        }
        return apiRepo.save(api);
    }

    private MockResponse createResponseUnderApi(MockApi api, JsonNode respNode) throws Exception {
        RequestMatcher matcher = api.getMatchers().isEmpty() ? null : api.getMatchers().get(0);
        if (matcher == null) {
            matcher = new RequestMatcher();
            matcher.setName("Default");
            matcher.setMockApi(api);
            matcher.setPriority(0);
            matcher.setEnabled(true);
            matcher.setResponseSelectionMode("MANUAL");
        }
        MockResponse resp = objectMapper.treeToValue(respNode, MockResponse.class);
        resp.setId(null);
        resp.setRequestMatcher(matcher);
        return responseRepo.save(resp);
    }

    private MockResponse findOrCreateResponse(MockApi api, String respName, JsonNode respNode) throws Exception {
        // Search existing matchers for a response with the same name
        for (RequestMatcher m : api.getMatchers()) {
            for (MockResponse r : m.getResponses()) {
                if (respName.equals(r.getName())) {
                    return r;
                }
            }
        }
        // Not found — create under first matcher
        return createResponseUnderApi(api, respNode);
    }

    private void resetIds(MockApi api) {
        api.setId(null);
        if (api.getMatchers() != null) {
            for (RequestMatcher m : api.getMatchers()) {
                m.setId(null);
                m.setMockApi(api);
                if (m.getResponses() != null)
                    m.getResponses().forEach(r -> r.setId(null));
            }
        }
        if (api.getDefaultResponse() != null)
            api.getDefaultResponse().setId(null);
    }
}
