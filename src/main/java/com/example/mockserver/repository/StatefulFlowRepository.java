package com.example.mockserver.repository;

import com.example.mockserver.entity.StatefulFlow;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface StatefulFlowRepository extends JpaRepository<StatefulFlow, Long> {
    Optional<StatefulFlow> findByMockApiIdAndStateKey(Long apiId, String stateKey);
    List<StatefulFlow> findByMockApiId(Long apiId);
    void deleteByMockApiId(Long apiId);
}
