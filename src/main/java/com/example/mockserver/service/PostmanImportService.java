package com.example.mockserver.service;

import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Import Postman Collection v2.1 format.
 * Parses the item[] array and creates MockApi + default matcher + response for each request.
 */
@Service
@Transactional
public class PostmanImportService {

    private final MockApiRepository apiRepo;
    private final ObjectMapper objectMapper;

    public PostmanImportService(MockApiRepository apiRepo) {
        this.apiRepo = apiRepo;
        this.objectMapper = new ObjectMapper();
    }

    /** Full import (backward compatible). Returns count of APIs created. */
    public int importFromJson(String json) throws Exception {
        return importSelected(json, null);
    }

    /** Preview: parse without saving. Returns list of {key, method, path, name} maps. */
    public List<Map<String, String>> previewFromJson(String json) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        List<Map<String, String>> items = new ArrayList<>();
        JsonNode it = root.path("item");
        if (it.isMissingNode()) it = root.path("collection").path("item");
        collectPreviewItems(it, items, null);
        return items;
    }

    /** Import only the items whose key appears in selectedKeys (null = all). Returns count. */
    public int importSelected(String json, List<String> selectedKeys) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        List<MockApi> created = new ArrayList<>();
        JsonNode items = root.path("item");
        if (items.isMissingNode()) items = root.path("collection").path("item");
        Set<String> allowed = selectedKeys != null ? new HashSet<>(selectedKeys) : null;
        processItems(items, created, null, allowed);
        return created.size();
    }

    // -------------------------------------------------------------------------

    private void collectPreviewItems(JsonNode items, List<Map<String, String>> result, String folderPrefix) {
        if (items == null || !items.isArray()) return;
        for (JsonNode item : items) {
            if (item.has("item")) {
                collectPreviewItems(item.path("item"), result, item.path("name").asText(""));
                continue;
            }
            JsonNode reqNode = item.path("request");
            if (reqNode.isMissingNode()) continue;
            String name = item.path("name").asText("Unnamed");
            String method = reqNode.path("method").asText("GET").toUpperCase();
            String rawUrl = extractUrl(reqNode.path("url"));
            if (rawUrl == null || rawUrl.isBlank()) continue;
            String path = toPath(rawUrl);
            String displayName = (folderPrefix != null && !folderPrefix.isBlank()) ? folderPrefix + " / " + name : name;
            Map<String, String> m = new LinkedHashMap<>();
            m.put("key", method + ":" + path + ":" + displayName);
            m.put("method", method);
            m.put("path", path);
            m.put("name", displayName);
            result.add(m);
        }
    }

    private void processItems(JsonNode items, List<MockApi> created, String folderPrefix, Set<String> allowed) {
        if (items == null || !items.isArray()) return;
        for (JsonNode item : items) {
            if (item.has("item")) {
                String folderName = item.path("name").asText("");
                processItems(item.path("item"), created, folderName, allowed);
                continue;
            }
            JsonNode reqNode = item.path("request");
            if (reqNode.isMissingNode()) continue;

            String name = item.path("name").asText("Unnamed");
            String method = reqNode.path("method").asText("GET").toUpperCase();
            String rawUrl = extractUrl(reqNode.path("url"));
            if (rawUrl == null || rawUrl.isBlank()) continue;
            String path = toPath(rawUrl);
            String displayName = (folderPrefix != null && !folderPrefix.isBlank()) ? folderPrefix + " / " + name : name;
            String key = method + ":" + path + ":" + displayName;

            if (allowed != null && !allowed.contains(key)) continue;

            MockApi api = new MockApi();
            api.setName(displayName);
            api.setDescription(reqNode.path("description").asText(""));
            api.setHttpMethod(method);
            api.setEndpointPath(path);
            api.setEnabled(true);

            RequestMatcher matcher = new RequestMatcher();
            matcher.setName("Default");
            matcher.setMockApi(api);
            matcher.setPriority(0);
            matcher.setEnabled(true);
            matcher.setResponseSelectionMode("MANUAL");

            MockResponse response = new MockResponse();
            response.setName("200 OK");
            response.setHttpStatus(200);
            response.setActive(true);
            response.setEnabled(true);
            response.setContentType("application/json");

            JsonNode examples = item.path("response");
            if (examples.isArray() && examples.size() > 0) {
                JsonNode first = examples.get(0);
                String body = first.path("body").asText(null);
                if (body != null && !body.isBlank()) {
                    response.setResponseBody(body);
                    int status = first.path("status").asInt(200);
                    response.setHttpStatus(status > 0 ? status : 200);
                } else {
                    response.setResponseBody("{\"message\": \"OK\"}");
                }
            } else {
                response.setResponseBody("{\"message\": \"OK\"}");
            }
            response.setRequestMatcher(matcher);
            matcher.setResponses(List.of(response));
            api.setMatchers(List.of(matcher));
            created.add(apiRepo.save(api));
        }
    }

    private String extractUrl(JsonNode urlNode) {
        if (urlNode.isTextual()) return urlNode.asText();
        return urlNode.path("raw").asText(null);
    }

    private String toPath(String url) {
        try {
            if (url.startsWith("http://") || url.startsWith("https://")) {
                int slashIdx = url.indexOf("/", url.indexOf("//") + 2);
                if (slashIdx < 0) return "/";
                url = url.substring(slashIdx);
            }
            int qIdx = url.indexOf("?");
            if (qIdx >= 0) url = url.substring(0, qIdx);
            url = url.replaceAll("\\{\\{([^}]+)}}", "{$1}");
            if (!url.startsWith("/")) url = "/" + url;
            return url;
        } catch (Exception e) {
            return "/imported";
        }
    }
}
