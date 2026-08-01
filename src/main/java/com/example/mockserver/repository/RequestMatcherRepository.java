package com.example.mockserver.repository;

import com.example.mockserver.entity.RequestMatcher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface RequestMatcherRepository extends JpaRepository<RequestMatcher, Long> {
    List<RequestMatcher> findByMockApiIdOrderByPriorityDesc(Long apiId);

    List<RequestMatcher> findByMockApiIdAndEnabledTrueOrderByPriorityDesc(Long apiId);

    @Query("SELECT DISTINCT m FROM RequestMatcher m LEFT JOIN FETCH m.responses WHERE m.mockApi.id = :apiId ORDER BY m.priority DESC")
    List<RequestMatcher> findByApiIdWithResponses(@Param("apiId") Long apiId);

    long countByMockApiId(Long apiId);

    long count();
}
