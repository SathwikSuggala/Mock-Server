package com.example.mockserver.dto;

public class ScenarioMappingDto {
    private Long id;
    private Long scenarioId;
    private Long mockApiId;
    private String mockApiName;
    private Long mockResponseId;
    private String mockResponseName;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getScenarioId() { return scenarioId; }
    public void setScenarioId(Long scenarioId) { this.scenarioId = scenarioId; }
    public Long getMockApiId() { return mockApiId; }
    public void setMockApiId(Long mockApiId) { this.mockApiId = mockApiId; }
    public String getMockApiName() { return mockApiName; }
    public void setMockApiName(String mockApiName) { this.mockApiName = mockApiName; }
    public Long getMockResponseId() { return mockResponseId; }
    public void setMockResponseId(Long mockResponseId) { this.mockResponseId = mockResponseId; }
    public String getMockResponseName() { return mockResponseName; }
    public void setMockResponseName(String mockResponseName) { this.mockResponseName = mockResponseName; }
}
