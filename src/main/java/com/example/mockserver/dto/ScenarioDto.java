package com.example.mockserver.dto;

import java.time.LocalDateTime;
import java.util.List;

public class ScenarioDto {
    private Long id;
    private String name;
    private String description;
    private boolean active;
    private LocalDateTime createdAt;
    private String cronExpression;
    private LocalDateTime activeUntil;
    private List<ScenarioMappingDto> mappings;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getCronExpression() { return cronExpression; }
    public void setCronExpression(String cronExpression) { this.cronExpression = cronExpression; }
    public LocalDateTime getActiveUntil() { return activeUntil; }
    public void setActiveUntil(LocalDateTime activeUntil) { this.activeUntil = activeUntil; }
    public List<ScenarioMappingDto> getMappings() { return mappings; }
    public void setMappings(List<ScenarioMappingDto> mappings) { this.mappings = mappings; }
}
