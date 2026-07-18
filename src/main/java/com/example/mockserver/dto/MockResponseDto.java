package com.example.mockserver.dto;

public class MockResponseDto {
    private Long id;
    private Long requestMatcherId;
    private String name;
    private String description;
    private Boolean enabled = true;
    private Boolean active = false;
    private int httpStatus = 200;
    private String responseHeaders;
    private String responseCookies;
    private String responseBody;
    private String contentType;
    private int delayMs;
    private String delayType;
    private int delayMaxMs;
    private String faultType;
    private int weight = 100;
    private String webhookUrl;
    private int webhookDelayMs;
    private String webhookBody;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getRequestMatcherId() { return requestMatcherId; }
    public void setRequestMatcherId(Long requestMatcherId) { this.requestMatcherId = requestMatcherId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isEnabled() { return enabled != null ? enabled : true; }
    public void setEnabled(Boolean enabled) { this.enabled = enabled; }
    public boolean isActive() { return active != null ? active : false; }
    public void setActive(Boolean active) { this.active = active; }
    public int getHttpStatus() { return httpStatus > 0 ? httpStatus : 200; }
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
    public int getWeight() { return weight > 0 ? weight : 100; }
    public void setWeight(int weight) { this.weight = weight; }
    public String getWebhookUrl() { return webhookUrl; }
    public void setWebhookUrl(String webhookUrl) { this.webhookUrl = webhookUrl; }
    public int getWebhookDelayMs() { return webhookDelayMs; }
    public void setWebhookDelayMs(int webhookDelayMs) { this.webhookDelayMs = webhookDelayMs; }
    public String getWebhookBody() { return webhookBody; }
    public void setWebhookBody(String webhookBody) { this.webhookBody = webhookBody; }
}
