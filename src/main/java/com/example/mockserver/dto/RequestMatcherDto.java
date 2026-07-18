package com.example.mockserver.dto;

import java.util.List;

public class RequestMatcherDto {
    private Long id;
    private Long mockApiId;
    private String name;
    private String description;
    private int priority;
    private Boolean enabled = true;
    private String matchHeaders;
    private String matchQueryParams;
    private String matchBody;
    private String matchBodyType;
    private String matchPathVariables;
    private String responseSelectionMode;
    private int sequentialIndex;
    private int rateLimitRpm;
    private List<MockResponseDto> responses;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getMockApiId() { return mockApiId; }
    public void setMockApiId(Long mockApiId) { this.mockApiId = mockApiId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }
    public boolean isEnabled() { return enabled != null ? enabled : true; }
    public void setEnabled(Boolean enabled) { this.enabled = enabled; }
    public String getMatchHeaders() { return matchHeaders; }
    public void setMatchHeaders(String matchHeaders) { this.matchHeaders = matchHeaders; }
    public String getMatchQueryParams() { return matchQueryParams; }
    public void setMatchQueryParams(String matchQueryParams) { this.matchQueryParams = matchQueryParams; }
    public String getMatchBody() { return matchBody; }
    public void setMatchBody(String matchBody) { this.matchBody = matchBody; }
    public String getMatchBodyType() { return matchBodyType; }
    public void setMatchBodyType(String matchBodyType) { this.matchBodyType = matchBodyType; }
    public String getMatchPathVariables() { return matchPathVariables; }
    public void setMatchPathVariables(String matchPathVariables) { this.matchPathVariables = matchPathVariables; }
    public String getResponseSelectionMode() { return responseSelectionMode; }
    public void setResponseSelectionMode(String responseSelectionMode) { this.responseSelectionMode = responseSelectionMode; }
    public int getSequentialIndex() { return sequentialIndex; }
    public void setSequentialIndex(int sequentialIndex) { this.sequentialIndex = sequentialIndex; }
    public int getRateLimitRpm() { return rateLimitRpm; }
    public void setRateLimitRpm(int rateLimitRpm) { this.rateLimitRpm = rateLimitRpm; }
    public List<MockResponseDto> getResponses() { return responses; }
    public void setResponses(List<MockResponseDto> responses) { this.responses = responses; }
}
