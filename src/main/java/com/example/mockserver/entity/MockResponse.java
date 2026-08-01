package com.example.mockserver.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "mock_response", indexes = {
    @Index(name = "idx_response_matcher", columnList = "request_matcher_id"),
    @Index(name = "idx_response_active", columnList = "is_active")
})
public class MockResponse {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_matcher_id")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private RequestMatcher requestMatcher;

    @Column(name = "response_name", nullable = false, length = 255)
    private String name;

    @Column(name = "response_description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_enabled", nullable = false, columnDefinition = "INTEGER DEFAULT 1")
    private boolean enabled = true;

    @Column(name = "is_active", nullable = false, columnDefinition = "INTEGER DEFAULT 0")
    private boolean active = false;

    @Column(name = "http_status")
    private int httpStatus = 200;

    @Column(name = "response_headers", columnDefinition = "TEXT")
    private String responseHeaders;

    @Column(name = "response_cookies", columnDefinition = "TEXT")
    private String responseCookies;

    @Column(name = "response_body", columnDefinition = "TEXT")
    private String responseBody;

    @Column(name = "content_type", length = 200)
    private String contentType = "application/json";

    @Column(name = "delay_ms")
    private int delayMs = 0;

    @Column(name = "delay_type", length = 20)
    private String delayType = "FIXED";

    @Column(name = "delay_max_ms")
    private int delayMaxMs = 0;

    @Column(name = "fault_type", length = 30)
    private String faultType;

    @Column(name = "resp_weight")
    private int weight = 100;

    @Column(name = "webhook_url", length = 500)
    private String webhookUrl;

    @Column(name = "webhook_delay_ms")
    private Integer webhookDelayMs = 0;

    @Column(name = "webhook_body", columnDefinition = "TEXT")
    private String webhookBody;

    @OneToMany(mappedBy = "mockResponse", cascade = CascadeType.REMOVE)
    private java.util.List<ScenarioMapping> scenarioMappings = new java.util.ArrayList<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public RequestMatcher getRequestMatcher() { return requestMatcher; }
    public void setRequestMatcher(RequestMatcher requestMatcher) { this.requestMatcher = requestMatcher; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public int getHttpStatus() { return httpStatus; }
    public void setHttpStatus(int httpStatus) { this.httpStatus = httpStatus; }
    public String getResponseHeaders() { return responseHeaders; }
    public void setResponseHeaders(String responseHeaders) { this.responseHeaders = responseHeaders; }
    public String getResponseCookies() { return responseCookies; }
    public void setResponseCookies(String responseCookies) { this.responseCookies = responseCookies; }
    public String getResponseBody() { return responseBody; }
    public void setResponseBody(String responseBody) { this.responseBody = responseBody; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public int getDelayMs() { return delayMs; }
    public void setDelayMs(int delayMs) { this.delayMs = delayMs; }
    public String getDelayType() { return delayType; }
    public void setDelayType(String delayType) { this.delayType = delayType; }
    public int getDelayMaxMs() { return delayMaxMs; }
    public void setDelayMaxMs(int delayMaxMs) { this.delayMaxMs = delayMaxMs; }
    public String getFaultType() { return faultType; }
    public void setFaultType(String faultType) { this.faultType = faultType; }
    public int getWeight() { return weight; }
    public void setWeight(int weight) { this.weight = weight; }
    public String getWebhookUrl() { return webhookUrl; }
    public void setWebhookUrl(String webhookUrl) { this.webhookUrl = webhookUrl; }
    public Integer getWebhookDelayMs() { return webhookDelayMs != null ? webhookDelayMs : 0; }
    public void setWebhookDelayMs(Integer webhookDelayMs) { this.webhookDelayMs = webhookDelayMs; }
    public String getWebhookBody() { return webhookBody; }
    public void setWebhookBody(String webhookBody) { this.webhookBody = webhookBody; }
    public java.util.List<ScenarioMapping> getScenarioMappings() { return scenarioMappings; }
    public void setScenarioMappings(java.util.List<ScenarioMapping> scenarioMappings) { this.scenarioMappings = scenarioMappings; }
}
