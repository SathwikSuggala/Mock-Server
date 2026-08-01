package com.example.mockserver.service;

import com.example.mockserver.dto.MockApiDto;
import com.example.mockserver.entity.*;
import com.example.mockserver.mapper.MockApiMapper;
import com.example.mockserver.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.regex.*;

/**
 * Parses a raw curl command and creates a MockApi + default RequestMatcher + MockResponse.
 */
@Service
@Transactional
public class CurlImportService {

    private final MockApiRepository apiRepo;
    private final MockApiMapper mapper;

    public CurlImportService(MockApiRepository apiRepo, MockApiMapper mapper) {
        this.apiRepo = apiRepo;
        this.mapper = mapper;
    }

    public MockApiDto importFromCurl(String curlCommand) {
        if (curlCommand == null || curlCommand.isBlank()) {
            throw new IllegalArgumentException("curl command cannot be empty");
        }

        // Normalize multiline curl (backslash-newline continuation)
        String cmd = curlCommand.trim()
                .replaceAll("\\\\\\r?\\n\\s*", " ");

        // Must start with 'curl'
        if (!cmd.toLowerCase().startsWith("curl")) {
            throw new IllegalArgumentException("Command must start with 'curl'");
        }

        // ---- Extract URL ----
        String url = extractUrl(cmd);
        if (url == null || url.isBlank()) {
            throw new IllegalArgumentException("Could not find a URL in the curl command");
        }
        String path = toPath(url);

        // ---- Extract HTTP Method ----
        String method = extractMethod(cmd);
        // If no explicit method but has -d/--data → POST
        if (method == null) {
            method = hasBody(cmd) ? "POST" : "GET";
        }

        // ---- Extract Headers ----
        Map<String, String> headers = extractHeaders(cmd);

        // ---- Extract Body ----
        String body = extractBody(cmd);

        // ---- Detect content type ----
        String contentType = headers.getOrDefault("Content-Type",
                headers.getOrDefault("content-type", "application/json"));

        // ---- Build entities ----
        MockApi api = new MockApi();
        api.setName(method + " " + path);
        api.setDescription("Imported from curl");
        api.setHttpMethod(method.toUpperCase());
        api.setEndpointPath(path);
        api.setEnabled(true);

        RequestMatcher matcher = new RequestMatcher();
        matcher.setName("Default");
        matcher.setMockApi(api);
        matcher.setPriority(0);
        matcher.setEnabled(true);
        matcher.setResponseSelectionMode("MANUAL");

        // Store captured headers as match headers JSON if present
        if (!headers.isEmpty()) {
            StringBuilder sb = new StringBuilder("{");
            headers.forEach((k, v) -> sb.append("\"").append(k).append("\":\"").append(v).append("\","));
            if (sb.charAt(sb.length() - 1) == ',') sb.deleteCharAt(sb.length() - 1);
            sb.append("}");
            matcher.setMatchHeaders(sb.toString());
        }

        if (body != null && !body.isBlank()) {
            matcher.setMatchBody(body);
            if (contentType.toLowerCase().contains("json")) {
                matcher.setMatchBodyType("JSON_MATCH");
                matcher.setMatchBodyFormat("json");
            } else if (contentType.toLowerCase().contains("xml")) {
                matcher.setMatchBodyType("EXACT");
                matcher.setMatchBodyFormat("xml");
            } else {
                matcher.setMatchBodyType("EXACT");
                matcher.setMatchBodyFormat("text");
            }
        }

        MockResponse response = new MockResponse();
        response.setName("200 OK");
        response.setHttpStatus(200);
        response.setActive(true);
        response.setEnabled(true);
        response.setContentType(contentType);
        response.setResponseBody(body != null && !body.isBlank() ? body : "{\"message\": \"OK\"}");
        response.setRequestMatcher(matcher);

        matcher.setResponses(List.of(response));
        api.setMatchers(List.of(matcher));

        return mapper.toDto(apiRepo.save(api));
    }

    // -------------------------------------------------------------------------

    private String extractUrl(String cmd) {
        // Look for URL-like token: starts with http/https, or is quoted
        // Patterns: 'https://...' or "https://..." or bare https://...
        Matcher m = Pattern.compile("(?<![\\-\\w])['\"]?(https?://[^'\"\\s]+)['\"]?").matcher(cmd);
        if (m.find()) return m.group(1);
        // Also try --url flag
        m = Pattern.compile("--url\\s+['\"]?([^'\"\\s]+)['\"]?").matcher(cmd);
        if (m.find()) return m.group(1);
        return null;
    }

    private String extractMethod(String cmd) {
        // -X METHOD or --request METHOD
        Matcher m = Pattern.compile("(?:-X|--request)\\s+['\"]?([A-Za-z]+)['\"]?").matcher(cmd);
        if (m.find()) return m.group(1).toUpperCase();
        return null;
    }

    private boolean hasBody(String cmd) {
        return Pattern.compile("\\s(?:-d|--data(?:-raw|-binary)?|--json)\\s").matcher(cmd).find();
    }

    private Map<String, String> extractHeaders(String cmd) {
        Map<String, String> headers = new LinkedHashMap<>();
        Matcher m = Pattern.compile("(?:-H|--header)\\s+(?:'([^']+)'|\"([^\"]+)\")").matcher(cmd);
        while (m.find()) {
            String h = m.group(1) != null ? m.group(1) : m.group(2);
            int colon = h.indexOf(':');
            if (colon > 0) {
                headers.put(h.substring(0, colon).trim(), h.substring(colon + 1).trim());
            }
        }
        return headers;
    }

    private String extractBody(String cmd) {
        // --json 'body' (curl >= 7.82)
        Matcher m = Pattern.compile("--json\\s+(?:'([^']+)'|\"([^\"]+)\")").matcher(cmd);
        if (m.find()) return m.group(1) != null ? m.group(1) : m.group(2);
        // -d / --data / --data-raw / --data-binary
        m = Pattern.compile("(?:-d|--data(?:-raw|-binary)?)\\s+(?:'([^']+)'|\"([^\"]+)\")").matcher(cmd);
        if (m.find()) return m.group(1) != null ? m.group(1) : m.group(2);
        // unquoted -d value
        m = Pattern.compile("(?:-d|--data)\\s+(\\S+)").matcher(cmd);
        if (m.find()) return m.group(1);
        return null;
    }

    private String toPath(String url) {
        try {
            if (url.startsWith("http://") || url.startsWith("https://")) {
                int slashIdx = url.indexOf("/", url.indexOf("//") + 2);
                if (slashIdx < 0) return "/";
                url = url.substring(slashIdx);
            }
            // Remove query string
            int qIdx = url.indexOf("?");
            if (qIdx >= 0) url = url.substring(0, qIdx);
            // Convert {{var}} to {var}
            url = url.replaceAll("\\{\\{([^}]+)}}", "{$1}");
            if (!url.startsWith("/")) url = "/" + url;
            return url;
        } catch (Exception e) {
            return "/imported";
        }
    }
}
