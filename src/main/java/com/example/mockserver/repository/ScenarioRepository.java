package com.example.mockserver.repository;

import com.example.mockserver.entity.Scenario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ScenarioRepository extends JpaRepository<Scenario, Long> {
    Optional<Scenario> findByActiveTrue();
    List<Scenario> findAllByOrderByNameAsc();
}
