package com.example.mockserver.service;

import com.example.mockserver.entity.ProxyRecording;
import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.hc.client5.http.classic.methods.*;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.*;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@Transactional
public class ProxyService {

    private final ProxyRecordingRepository recordingRepo;
    private final MockApiRepository apiRepo;
    private final ObjectMapper objectMapper;

    @Value("${app.proxy.timeout-seconds:30}")
    private int timeoutSeconds;

    public ProxyService(ProxyRecordingRepository recordingRepo, MockApiRepository apiRepo) {
        this.recordingRepo = recordingRepo;
        this.apiRepo = apiRepo;
        this.objectMapper = new ObjectMapper();
    }

    public ProxyRecording forwardAndRecord(HttpServletRequest request, String requestBody,
            String targetBaseUrl) throws Exception {
        String path = request.getRequestURI();
        String queryString = request.getQueryString();
        String targetUrl = targetBaseUrl + path + (queryString != null ? "?" + queryString : "");

        ProxyRecording recording = new ProxyRecording();
        recording.setHttpMethod(request.getMethod());
        recording.setRequestPath(path);
        recording.setTargetUrl(targetUrl);
        recording.setQueryParams(queryString);
        recording.setRequestBody(requestBody);

        // Capture request headers
        Map<String, String> reqHeaders = new LinkedHashMap<>();
        Enumeration<String> headerNames = request.getHeaderNames();
        if (headerNames != null) {
            while (headerNames.hasMoreElements()) {
                String name = headerNames.nextElement();
                reqHeaders.put(name, request.getHeader(name));
            }
        }
        recording.setRequestHeaders(objectMapper.writeValueAsString(reqHeaders));

        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpUriRequestBase httpRequest = createRequest(request.getMethod(), targetUrl, requestBody,
                    request.getContentType());
            // Forward headers (skip host)
            reqHeaders.forEach((k, v) -> {
                if (!k.equalsIgnoreCase("host") && !k.equalsIgnoreCase("content-length")) {
                    httpRequest.addHeader(k, v);
                }
            });

            client.execute(httpRequest, response -> {
                recording.setResponseStatus(response.getCode());
                Map<String, String> respHeaders = new LinkedHashMap<>();
                for (Header h : response.getHeaders()) {
                    respHeaders.put(h.getName(), h.getValue());
                    if (h.getName().equalsIgnoreCase("content-type")) {
                        recording.setContentType(h.getValue());
                    }
                }
                try {
                    recording.setResponseHeaders(objectMapper.writeValueAsString(respHeaders));
                    HttpEntity entity = response.getEntity();
                    if (entity != null)
                        recording.setResponseBody(EntityUtils.toString(entity));
                } catch (Exception e) {
                    /* ignore */ }
                return null;
            });
        }

        return recordingRepo.save(recording);
    }

    private HttpUriRequestBase createRequest(String method, String url, String body, String contentType) {
        return switch (method.toUpperCase()) {
            case "POST" -> {
                HttpPost post = new HttpPost(url);
                if (body != null && !body.isBlank())
                    post.setEntity(new StringEntity(body,
                            contentType != null ? ContentType.parse(contentType) : ContentType.APPLICATION_JSON));
                yield post;
            }
            case "PUT" -> {
                HttpPut put = new HttpPut(url);
                if (body != null && !body.isBlank())
                    put.setEntity(new StringEntity(body,
                            contentType != null ? ContentType.parse(contentType) : ContentType.APPLICATION_JSON));
                yield put;
            }
            case "PATCH" -> {
                HttpPatch patch = new HttpPatch(url);
                if (body != null && !body.isBlank())
                    patch.setEntity(new StringEntity(body,
                            contentType != null ? ContentType.parse(contentType) : ContentType.APPLICATION_JSON));
                yield patch;
            }
            case "DELETE" -> new HttpDelete(url);
            default -> new HttpGet(url);
        };
    }

    public MockApi importAsApi(Long recordingId) {
        ProxyRecording rec = recordingRepo.findById(recordingId)
                .orElseThrow(() -> new RuntimeException("Recording not found"));

        MockApi api = new MockApi();
        api.setName(rec.getHttpMethod() + " " + rec.getRequestPath());
        api.setHttpMethod(rec.getHttpMethod());
        api.setEndpointPath(rec.getRequestPath());
        api.setEnabled(true);

        RequestMatcher matcher = new RequestMatcher();
        matcher.setName("Recorded");
        matcher.setMockApi(api);
        matcher.setPriority(0);
        matcher.setEnabled(true);
        matcher.setResponseSelectionMode("MANUAL");

        MockResponse response = new MockResponse();
        response.setName("Recorded Response");
        response.setHttpStatus(rec.getResponseStatus());
        response.setResponseBody(rec.getResponseBody());
        response.setContentType(rec.getContentType() != null ? rec.getContentType() : "application/json");
        response.setActive(true);
        response.setEnabled(true);
        response.setRequestMatcher(matcher);

        matcher.setResponses(List.of(response));
        api.setMatchers(List.of(matcher));

        MockApi saved = apiRepo.save(api);
        rec.setImported(true);
        recordingRepo.save(rec);
        return saved;
    }

    @Transactional(readOnly = true)
    public Page<ProxyRecording> findAll(int page, int size) {
        return recordingRepo.findAllByOrderByTimestampDesc(PageRequest.of(page, size));
    }

    public void deleteRecording(Long id) {
        recordingRepo.deleteById(id);
    }
}
