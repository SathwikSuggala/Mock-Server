package com.example.mockserver.service;

import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.ArrayList;

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

    /**
     * Import Postman Collection JSON (v2.0 or v2.1).
     * Returns count of APIs created.
     */
    public int importFromJson(String json) throws Exception {
        JsonNode root = objectMapper.readTree(json);
        List<MockApi> created = new ArrayList<>();
        // Postman v2.1 format: item[] at root
        JsonNode items = root.path("item");
        if (items.isMissingNode()) {
            // Try collection wrapper
            items = root.path("collection").path("item");
        }
        processItems(items, created, null);
        return created.size();
    }

    private void processItems(JsonNode items, List<MockApi> created, String folderPrefix) {
        if (items == null || !items.isArray()) return;
        for (JsonNode item : items) {
            // Folder (has item[] sub-items)
            if (item.has("item")) {
                String folderName = item.path("name").asText("");
                processItems(item.path("item"), created, folderName);
                continue;
            }
            // Request
            JsonNode reqNode = item.path("request");
            if (reqNode.isMissingNode()) continue;

            String name = item.path("name").asText("Unnamed");
            String method = reqNode.path("method").asText("GET").toUpperCase();
            String rawUrl  = extractUrl(reqNode.path("url"));
            if (rawUrl == null || rawUrl.isBlank()) continue;

            // Convert absolute URL to path
            String path = toPath(rawUrl);

            MockApi api = new MockApi();
            api.setName((folderPrefix != null ? folderPrefix + " / " : "") + name);
            api.setDescription(reqNode.path("description").asText(""));
            api.setHttpMethod(method);
            api.setEndpointPath(path);
            api.setEnabled(true);

            // Default matcher
            RequestMatcher matcher = new RequestMatcher();
            matcher.setName("Default");
            matcher.setMockApi(api);
            matcher.setPriority(0);
            matcher.setEnabled(true);
            matcher.setResponseSelectionMode("MANUAL");

            // Default response — try to use example body from Postman response
            MockResponse response = new MockResponse();
            response.setName("200 OK");
            response.setHttpStatus(200);
            response.setActive(true);
            response.setEnabled(true);
            response.setContentType("application/json");
            // Use first example response body if available
            JsonNode examples = item.path("response");
            if (examples.isArray() && examples.size() > 0) {
                JsonNode firstExample = examples.get(0);
                String body = firstExample.path("body").asText(null);
                if (body != null && !body.isBlank()) {
                    response.setResponseBody(body);
                    int status = firstExample.path("status").asInt(200);
                    response.setHttpStatus(status > 0 ? status : 200);
                    String ct = firstExample.path("_postman_previewtype").asText(null);
                    if (ct == null) ct = firstExample.path("header").toString().contains("json") ? "application/json" : "application/json";
                    response.setContentType(ct);
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
        // Postman v2.1 url is an object with raw field
        String raw = urlNode.path("raw").asText(null);
        return raw;
    }

    private String toPath(String url) {
        // Strip protocol + host
        try {
            if (url.startsWith("http://") || url.startsWith("https://")) {
                int slashIdx = url.indexOf("/", url.indexOf("//") + 2);
                if (slashIdx < 0) return "/";
                url = url.substring(slashIdx);
            }
            // Remove query string
            int qIdx = url.indexOf("?");
            if (qIdx >= 0) url = url.substring(0, qIdx);
            // Convert {{variable}} to {variable}
            url = url.replaceAll("\\{\\{([^}]+)}}", "{$1}");
            if (!url.startsWith("/")) url = "/" + url;
            return url;
        } catch (Exception e) {
            return "/" + url.replaceAll("[^a-zA-Z0-9/_{}]", "");
        }
    }
}
