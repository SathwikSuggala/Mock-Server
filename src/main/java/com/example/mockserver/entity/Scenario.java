package com.example.mockserver.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "scenario", indexes = {
    @Index(name = "idx_scenario_active", columnList = "is_active")
})
public class Scenario {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "scenario_name", nullable = false, unique = true, length = 255)
    private String name;

    @Column(name = "scenario_description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_active", nullable = false, columnDefinition = "TINYINT(1) DEFAULT 0")
    private boolean active = false;

    @Column(name = "cron_expression", length = 100)
    private String cronExpression;

    @Column(name = "active_until")
    private LocalDateTime activeUntil;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "scenario", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ScenarioMapping> mappings = new ArrayList<>();

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
    public List<ScenarioMapping> getMappings() { return mappings; }
    public void setMappings(List<ScenarioMapping> mappings) { this.mappings = mappings; }
    public String getCronExpression() { return cronExpression; }
    public void setCronExpression(String cronExpression) { this.cronExpression = cronExpression; }
    public LocalDateTime getActiveUntil() { return activeUntil; }
    public void setActiveUntil(LocalDateTime activeUntil) { this.activeUntil = activeUntil; }
}
