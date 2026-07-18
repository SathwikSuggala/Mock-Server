package com.example.mockserver.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "scenario_mapping")
public class ScenarioMapping {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "scenario_id", nullable = false)
    private Scenario scenario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mock_api_id", nullable = false)
    private MockApi mockApi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mock_response_id", nullable = false)
    private MockResponse mockResponse;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Scenario getScenario() { return scenario; }
    public void setScenario(Scenario scenario) { this.scenario = scenario; }
    public MockApi getMockApi() { return mockApi; }
    public void setMockApi(MockApi mockApi) { this.mockApi = mockApi; }
    public MockResponse getMockResponse() { return mockResponse; }
    public void setMockResponse(MockResponse mockResponse) { this.mockResponse = mockResponse; }
}
