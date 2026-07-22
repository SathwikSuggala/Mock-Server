package com.example.mockserver.service;

import com.example.mockserver.dto.*;
import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
@Transactional
public class OpenApiImportService {

    private final MockApiRepository apiRepo;

    public OpenApiImportService(MockApiRepository apiRepo) {
        this.apiRepo = apiRepo;
    }

    public List<MockApi> importFromFile(MultipartFile file) throws Exception {
        String content = new String(file.getBytes(), StandardCharsets.UTF_8);
        String filename = file.getOriginalFilename() != null ? file.getOriginalFilename().toLowerCase() : "";
        boolean yaml = filename.endsWith(".yaml") || filename.endsWith(".yml");
        return importSelected(content, yaml, null);
    }

    public List<MockApi> importFromContent(String content, boolean yaml) throws Exception {
        return importSelected(content, yaml, null);
    }

    /** Preview: parse without saving. Returns list of {key, method, path, name} maps. */
    public List<Map<String, String>> previewFromContent(String content, boolean yaml) throws Exception {
        ObjectMapper mapper = yaml ? new ObjectMapper(new YAMLFactory()) : new ObjectMapper();
        JsonNode root = mapper.readTree(content);
        List<Map<String, String>> items = new ArrayList<>();
        JsonNode paths = root.path("paths");
        if (paths.isMissingNode()) return items;
        paths.fields().forEachRemaining(pathEntry -> {
            String path = pathEntry.getKey();
            pathEntry.getValue().fields().forEachRemaining(methodEntry -> {
                String method = methodEntry.getKey().toUpperCase();
                if (Set.of("GET","POST","PUT","DELETE","PATCH","HEAD","OPTIONS").contains(method)) {
                    JsonNode op = methodEntry.getValue();
                    Map<String, String> item = new LinkedHashMap<>();
                    item.put("key", method + ":" + path);
                    item.put("method", method);
                    item.put("path", path);
                    item.put("name", op.path("operationId").asText(method + " " + path));
                    items.add(item);
                }
            });
        });
        return items;
    }

    /** Import only the endpoints whose key (METHOD:path) appears in selectedKeys (null = all). */
    public List<MockApi> importSelected(String content, boolean yaml, List<String> selectedKeys) throws Exception {
        ObjectMapper mapper = yaml ? new ObjectMapper(new YAMLFactory()) : new ObjectMapper();
        JsonNode root = mapper.readTree(content);
        List<MockApi> created = new ArrayList<>();
        JsonNode paths = root.path("paths");
        if (paths.isMissingNode()) return created;

        Set<String> allowed = selectedKeys != null ? new HashSet<>(selectedKeys) : null;

        paths.fields().forEachRemaining(pathEntry -> {
            String path = pathEntry.getKey();
            pathEntry.getValue().fields().forEachRemaining(methodEntry -> {
                String method = methodEntry.getKey().toUpperCase();
                if (!Set.of("GET","POST","PUT","DELETE","PATCH","HEAD","OPTIONS").contains(method)) return;
                String key = method + ":" + path;
                if (allowed != null && !allowed.contains(key)) return;

                JsonNode op = methodEntry.getValue();
                MockApi api = new MockApi();
                api.setName(op.path("operationId").asText(method + " " + path));
                api.setDescription(op.path("summary").asText(""));
                api.setHttpMethod(method);
                api.setEndpointPath(path.replaceAll("\\{([^}]+)}", "{$1}"));
                api.setEnabled(true);
                JsonNode tags = op.path("tags");
                if (!tags.isMissingNode()) {
                    List<String> tagList = new ArrayList<>();
                    tags.forEach(t -> tagList.add(t.asText()));
                    api.setTags(String.join(",", tagList));
                }
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
                response.setResponseBody("{\"message\": \"OK\"}");
                response.setContentType("application/json");
                response.setRequestMatcher(matcher);

                matcher.setResponses(List.of(response));
                api.setMatchers(List.of(matcher));
                created.add(apiRepo.save(api));
            });
        });
        return created;
    }
}
