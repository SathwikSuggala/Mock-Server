package com.example.mockserver.repository;

import com.example.mockserver.entity.MockResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface MockResponseRepository extends JpaRepository<MockResponse, Long> {
    List<MockResponse> findByRequestMatcherId(Long matcherId);
    List<MockResponse> findByRequestMatcherIdAndEnabledTrue(Long matcherId);
    Optional<MockResponse> findByRequestMatcherIdAndActiveTrue(Long matcherId);
    long count();
}
