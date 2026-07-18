package com.example.mockserver.repository;

import com.example.mockserver.entity.ScenarioMapping;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ScenarioMappingRepository extends JpaRepository<ScenarioMapping, Long> {
    List<ScenarioMapping> findByScenarioId(Long scenarioId);
    Optional<ScenarioMapping> findByScenarioIdAndMockApiId(Long scenarioId, Long apiId);
    void deleteByScenarioId(Long scenarioId);
}
