package com.example.mockserver.repository;

import com.example.mockserver.entity.ProxyRecording;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProxyRecordingRepository extends JpaRepository<ProxyRecording, Long> {
    Page<ProxyRecording> findAllByOrderByTimestampDesc(Pageable pageable);
    List<ProxyRecording> findByImportedFalse();
}
