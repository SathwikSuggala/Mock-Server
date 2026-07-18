package com.example.mockserver.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "mock_api", indexes = {
    @Index(name = "idx_mock_api_path", columnList = "endpoint_path"),
    @Index(name = "idx_mock_api_enabled", columnList = "is_enabled")
})
public class MockApi {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "api_name", nullable = false, length = 255)
    private String name;

    @Column(name = "api_description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "http_method", nullable = false, length = 10)
    private String httpMethod;

    @Column(name = "endpoint_path", nullable = false, length = 500)
    private String endpointPath;

    @Column(name = "tags", length = 500)
    private String tags;

    @Column(name = "is_enabled", nullable = false, columnDefinition = "TINYINT(1) DEFAULT 1")
    private boolean enabled = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @OneToMany(mappedBy = "mockApi", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("priority DESC")
    private List<RequestMatcher> matchers = new ArrayList<>();

    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "default_response_id")
    private MockResponse defaultResponse;

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
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public List<RequestMatcher> getMatchers() { return matchers; }
    public void setMatchers(List<RequestMatcher> matchers) { this.matchers = matchers; }
    public MockResponse getDefaultResponse() { return defaultResponse; }
    public void setDefaultResponse(MockResponse defaultResponse) { this.defaultResponse = defaultResponse; }

    @PreUpdate
    public void preUpdate() { this.updatedAt = LocalDateTime.now(); }
}
