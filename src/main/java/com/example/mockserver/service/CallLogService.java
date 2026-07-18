package com.example.mockserver.service;

import com.example.mockserver.entity.CallLog;
import com.example.mockserver.repository.CallLogRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.*;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class CallLogService {

    private final CallLogRepository logRepo;

    @Value("${app.call-log.retention-days:30}")
    private int retentionDays;

    public CallLogService(CallLogRepository logRepo) {
        this.logRepo = logRepo;
    }

    public void save(CallLog log) {
        logRepo.save(log);
    }

    @Transactional(readOnly = true)
    public Page<CallLog> search(String method, String path, Integer status,
                                LocalDateTime from, LocalDateTime to, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "timestamp"));
        return logRepo.search(method, path, status, from, to, pageable);
    }

    @Transactional(readOnly = true)
    public long countToday() {
        return logRepo.countByTimestampAfter(LocalDateTime.now().toLocalDate().atStartOfDay());
    }

    @Transactional(readOnly = true)
    public long countLastHour() {
        return logRepo.countByTimestampAfter(LocalDateTime.now().minusHours(1));
    }

    @Transactional(readOnly = true)
    public List<Object[]> topCalledApis(int limit) {
        return logRepo.findTopCalledApis(PageRequest.of(0, limit));
    }

    public void clearAll() {
        logRepo.deleteAll();
    }

    @Scheduled(cron = "0 0 2 * * *")
    public void purgeOldLogs() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(retentionDays);
        logRepo.deleteOlderThan(cutoff);
    }
}
