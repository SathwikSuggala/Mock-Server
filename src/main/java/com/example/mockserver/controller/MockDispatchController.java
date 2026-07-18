package com.example.mockserver.controller;

import com.example.mockserver.entity.*;
import com.example.mockserver.service.*;
import com.example.mockserver.util.RequestMatcherUtil;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

/**
 * Catch-all controller that handles all mock API requests under /mock/** prefix.
 */
@RestController
@RequestMapping("/mock")
public class MockDispatchController {

    private final MockEngineService engine;
    private final CallLogService logService;
    private final SettingsService settingsService;
    private final ProxyService proxyService;
    private final WebhookService webhookService;
    private final ObjectMapper objectMapper;

    public MockDispatchController(MockEngineService engine, CallLogService logService,
                                  SettingsService settingsService, ProxyService proxyService,
                                  WebhookService webhookService) {
        this.engine = engine;
        this.logService = logService;
        this.settingsService = settingsService;
        this.proxyService = proxyService;
        this.webhookService = webhookService;
        this.objectMapper = new ObjectMapper();
    }

    @RequestMapping(value = "/**", method = {RequestMethod.GET, RequestMethod.POST,
            RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.PATCH,
            RequestMethod.HEAD, RequestMethod.OPTIONS})
    public void handle(HttpServletRequest request, HttpServletResponse response) throws Exception {
        long start = System.currentTimeMillis();

        // Strip /mock prefix from path for matching
        String fullPath = request.getRequestURI();
        String mockPath = fullPath.startsWith("/mock") ? fullPath.substring(5) : fullPath;
        if (mockPath.isEmpty()) mockPath = "/";

        String requestBody = RequestMatcherUtil.readBody(request);
        HttpServletRequest wrappedRequest = new UriOverrideRequest(request, mockPath);

        // Check proxy mode
        String proxyEnabled = settingsService.get("proxy.enabled", "false");
        String proxyTarget  = settingsService.get("proxy.targetUrl", "");

        if ("true".equals(proxyEnabled) && !proxyTarget.isBlank()) {
            handleProxy(request, wrappedRequest, response, requestBody, proxyTarget, mockPath, start);
            return;
        }

        Optional<MockEngineService.MatchResult> matchOpt = engine.match(wrappedRequest, requestBody);
        long execTime = System.currentTimeMillis() - start;

        if (matchOpt.isEmpty()) {
            logRequest(request, mockPath, requestBody, 404, "", null, null, execTime);
            response.setStatus(404);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"No mock configured for this endpoint\"}");
            return;
        }

        MockEngineService.MatchResult result = matchOpt.get();

        // Rate limit sentinel: matcher matched but response is null → 429
        if (result.response() == null) {
            int status = 429;
            String body = "{\"error\":\"Rate limit exceeded\",\"retryAfter\":60}";
            logRequest(request, mockPath, requestBody, status, body,
                    result.matcher() != null ? result.matcher().getName() : null,
                    result.activeScenarioName(), System.currentTimeMillis() - start);
            response.setStatus(status);
            response.setContentType("application/json");
            response.setHeader("Retry-After", "60");
            response.getWriter().write(body);
            return;
        }

        MockResponse mockResponse = result.response();

        // Handle fault simulation
        if (mockResponse.getFaultType() != null) {
            switch (mockResponse.getFaultType()) {
                case "TIMEOUT"          -> { Thread.sleep(60000); return; }
                case "EMPTY_RESPONSE"   -> { response.setStatus(mockResponse.getHttpStatus()); return; }
                case "CONNECTION_RESET" -> { response.setStatus(500); response.getWriter().write(""); return; }
            }
        }

        // Apply delay
        applyDelay(mockResponse);

        // Set status
        response.setStatus(mockResponse.getHttpStatus());

        // Set content type
        if (mockResponse.getContentType() != null) {
            response.setContentType(mockResponse.getContentType());
        }

        // Set response headers
        if (mockResponse.getResponseHeaders() != null && !mockResponse.getResponseHeaders().isBlank()) {
            try {
                Map<String, String> headers = objectMapper.readValue(
                        mockResponse.getResponseHeaders(), new TypeReference<>() {});
                headers.forEach(response::setHeader);
            } catch (Exception ignored) {}
        }

        // Set cookies
        if (mockResponse.getResponseCookies() != null && !mockResponse.getResponseCookies().isBlank()) {
            try {
                Map<String, String> cookies = objectMapper.readValue(
                        mockResponse.getResponseCookies(), new TypeReference<>() {});
                cookies.forEach((k, v) -> response.addCookie(new Cookie(k, v)));
            } catch (Exception ignored) {}
        }

        // Resolve and write body
        String resolvedBody = RequestMatcherUtil.resolveVariables(
                mockResponse.getResponseBody(), request, result.pathVars(), requestBody);

        execTime = System.currentTimeMillis() - start;
        logRequest(request, mockPath, requestBody, mockResponse.getHttpStatus(), resolvedBody,
                result.matcher() != null ? result.matcher().getName() : "default",
                result.activeScenarioName(), execTime);

        if (resolvedBody != null) {
            response.getWriter().write(resolvedBody);
        }

        // Fire webhook asynchronously if configured
        if (mockResponse.getWebhookUrl() != null && !mockResponse.getWebhookUrl().isBlank()) {
            webhookService.fireWebhook(
                    mockResponse.getWebhookUrl(),
                    mockResponse.getWebhookDelayMs(),
                    mockResponse.getWebhookBody() != null ? mockResponse.getWebhookBody() : resolvedBody);
        }
    }

    private void handleProxy(HttpServletRequest originalRequest, HttpServletRequest wrappedRequest,
                              HttpServletResponse response, String requestBody,
                              String proxyTarget, String mockPath, long start) throws Exception {
        try {
            ProxyRecording recording = proxyService.forwardAndRecord(wrappedRequest, requestBody, proxyTarget);
            response.setStatus(recording.getResponseStatus());
            if (recording.getContentType() != null) response.setContentType(recording.getContentType());
            if (recording.getResponseBody() != null) response.getWriter().write(recording.getResponseBody());
        } catch (Exception e) {
            response.setStatus(502);
            response.getWriter().write("{\"error\":\"Proxy error: " + e.getMessage() + "\"}");
        }
    }

    private void applyDelay(MockResponse r) throws InterruptedException {
        if (r.getDelayMs() <= 0) return;
        int delay = r.getDelayMs();
        if ("RANDOM".equals(r.getDelayType()) && r.getDelayMaxMs() > r.getDelayMs()) {
            delay = r.getDelayMs() + new Random().nextInt(r.getDelayMaxMs() - r.getDelayMs());
        }
        Thread.sleep(delay);
    }

    private void logRequest(HttpServletRequest request, String path, String reqBody,
                             int status, String respBody, String matcherName,
                             String scenarioName, long execTime) {
        try {
            CallLog log = new CallLog();
            log.setHttpMethod(request.getMethod());
            log.setRequestPath(path);
            log.setRequestBody(reqBody);
            log.setResponseBody(respBody != null && respBody.length() > 5000
                    ? respBody.substring(0, 5000) + "..." : respBody);
            log.setStatusCode(status);
            log.setMatcherName(matcherName);
            log.setScenarioName(scenarioName);
            log.setExecutionTimeMs(execTime);

            Map<String, String> headers = RequestMatcherUtil.headersToMap(request);
            log.setRequestHeaders(objectMapper.writeValueAsString(headers));

            String qs = request.getQueryString();
            log.setQueryParams(qs);

            logService.save(log);
        } catch (Exception ignored) {}
    }

    // Simple wrapper to override getRequestURI
    private static class UriOverrideRequest extends jakarta.servlet.http.HttpServletRequestWrapper {
        private final String uri;
        public UriOverrideRequest(HttpServletRequest request, String uri) {
            super(request);
            this.uri = uri;
        }
        @Override public String getRequestURI() { return uri; }
    }
}
