package com.example.mockserver.dto;

import java.time.LocalDateTime;
import java.util.List;

public class MockApiDto {
    private Long id;
    private String name;
    private String description;
    private String httpMethod;
    private String endpointPath;
    private String tags;
    private Boolean enabled = true;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private int matcherCount;
    private List<RequestMatcherDto> matchers;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getHttpMethod() { return httpMethod; }
    public void setHttpMethod(String httpMethod) { this.httpMethod = httpMethod; }
    public String getEndpointPath() { return endpointPath; }
    public void setEndpointPath(String endpointPath) { this.endpointPath = endpointPath; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public boolean isEnabled() { return enabled != null ? enabled : true; }
    public void setEnabled(Boolean enabled) { this.enabled = enabled; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public int getMatcherCount() { return matcherCount; }
    public void setMatcherCount(int matcherCount) { this.matcherCount = matcherCount; }
    public List<RequestMatcherDto> getMatchers() { return matchers; }
    public void setMatchers(List<RequestMatcherDto> matchers) { this.matchers = matchers; }
}
