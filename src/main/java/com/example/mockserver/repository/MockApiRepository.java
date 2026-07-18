package com.example.mockserver.repository;

import com.example.mockserver.entity.MockApi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface MockApiRepository extends JpaRepository<MockApi, Long> {
    List<MockApi> findByEnabledTrue();
    List<MockApi> findByTagsContaining(String tag);
    @Query("SELECT a FROM MockApi a WHERE a.enabled = true ORDER BY a.name")
    List<MockApi> findAllEnabledOrdered();
    long countByEnabledTrue();
}
