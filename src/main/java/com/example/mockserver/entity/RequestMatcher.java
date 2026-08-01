package com.example.mockserver.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "request_matcher", indexes = {
    @Index(name = "idx_matcher_api", columnList = "mock_api_id"),
    @Index(name = "idx_matcher_priority", columnList = "matcher_priority")
})
public class RequestMatcher {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mock_api_id", nullable = false)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private MockApi mockApi;

    @Column(name = "matcher_name", nullable = false, length = 255)
    private String name;

    @Column(name = "matcher_description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "matcher_priority")
    private int priority = 0;

    @Column(name = "is_enabled", nullable = false, columnDefinition = "INTEGER DEFAULT 1")
    private boolean enabled = true;

    @Column(name = "match_headers", columnDefinition = "TEXT")
    private String matchHeaders;

    @Column(name = "match_query_params", columnDefinition = "TEXT")
    private String matchQueryParams;

    @Column(name = "match_body", columnDefinition = "TEXT")
    private String matchBody;

    @Column(name = "match_body_type", length = 30)
    private String matchBodyType = "CONTAINS";

    @Column(name = "match_body_format", length = 20)
    private String matchBodyFormat = "text";

    @Column(name = "match_path_variables", columnDefinition = "TEXT")
    private String matchPathVariables;

    @Column(name = "response_selection_mode", length = 20)
    private String responseSelectionMode = "MANUAL";

    @Column(name = "sequential_index")
    private int sequentialIndex = 0;

    @Column(name = "rate_limit_rpm")
    private Integer rateLimitRpm = 0; // 0 = no limit

    @OneToMany(mappedBy = "requestMatcher", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("id ASC")
    private List<MockResponse> responses = new ArrayList<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public MockApi getMockApi() { return mockApi; }
    public void setMockApi(MockApi mockApi) { this.mockApi = mockApi; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public String getMatchHeaders() { return matchHeaders; }
    public void setMatchHeaders(String matchHeaders) { this.matchHeaders = matchHeaders; }
    public String getMatchQueryParams() { return matchQueryParams; }
    public void setMatchQueryParams(String matchQueryParams) { this.matchQueryParams = matchQueryParams; }
    public String getMatchBody() { return matchBody; }
    public void setMatchBody(String matchBody) { this.matchBody = matchBody; }
    public String getMatchBodyType() { return matchBodyType; }
    public void setMatchBodyType(String matchBodyType) { this.matchBodyType = matchBodyType; }
    public String getMatchBodyFormat() { return matchBodyFormat; }
    public void setMatchBodyFormat(String matchBodyFormat) { this.matchBodyFormat = matchBodyFormat; }
    public String getMatchPathVariables() { return matchPathVariables; }
    public void setMatchPathVariables(String matchPathVariables) { this.matchPathVariables = matchPathVariables; }
    public String getResponseSelectionMode() { return responseSelectionMode; }
    public void setResponseSelectionMode(String responseSelectionMode) { this.responseSelectionMode = responseSelectionMode; }
    public int getSequentialIndex() { return sequentialIndex; }
    public void setSequentialIndex(int sequentialIndex) { this.sequentialIndex = sequentialIndex; }
    public Integer getRateLimitRpm() { return rateLimitRpm != null ? rateLimitRpm : 0; }
    public void setRateLimitRpm(Integer rateLimitRpm) { this.rateLimitRpm = rateLimitRpm; }
    public List<MockResponse> getResponses() { return responses; }
    public void setResponses(List<MockResponse> responses) { this.responses = responses; }
}
