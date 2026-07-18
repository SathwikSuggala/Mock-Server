package com.example.mockserver.repository;

import com.example.mockserver.entity.CallLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

public interface CallLogRepository extends JpaRepository<CallLog, Long> {
    @Query("SELECT l FROM CallLog l WHERE " +
           "(:method IS NULL OR l.httpMethod = :method) AND " +
           "(:path IS NULL OR l.requestPath LIKE %:path%) AND " +
           "(:status IS NULL OR l.statusCode = :status) AND " +
           "(:from IS NULL OR l.timestamp >= :from) AND " +
           "(:to IS NULL OR l.timestamp <= :to) " +
           "ORDER BY l.timestamp DESC")
    Page<CallLog> search(@Param("method") String method, @Param("path") String path,
                         @Param("status") Integer status, @Param("from") LocalDateTime from,
                         @Param("to") LocalDateTime to, Pageable pageable);

    long countByTimestampAfter(LocalDateTime after);

    @Query("SELECT l.requestPath, COUNT(l) as cnt FROM CallLog l GROUP BY l.requestPath ORDER BY cnt DESC")
    List<Object[]> findTopCalledApis(Pageable pageable);

    @Modifying
    @Query("DELETE FROM CallLog l WHERE l.timestamp < :before")
    int deleteOlderThan(@Param("before") LocalDateTime before);

    @Modifying
    @Query("DELETE FROM CallLog l")
    void deleteAll();
}
