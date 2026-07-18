package com.example.mockserver.service;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * In-memory rate limiter per RequestMatcher.
 * Counts are reset every minute by a scheduled job.
 */
@Service
public class RateLimitService {

    // matcherId → count in current minute window
    private final ConcurrentHashMap<Long, AtomicInteger> counts = new ConcurrentHashMap<>();

    /**
     * Returns true if the request is allowed (within the RPM limit).
     * @param matcherId the matcher to track
     * @param rpmLimit  max requests per minute; 0 = unlimited
     */
    public boolean isAllowed(Long matcherId, int rpmLimit) {
        if (rpmLimit <= 0) return true;
        AtomicInteger counter = counts.computeIfAbsent(matcherId, k -> new AtomicInteger(0));
        int current = counter.incrementAndGet();
        return current <= rpmLimit;
    }

    /** Reset all counters every minute. */
    @Scheduled(fixedRate = 60_000)
    public void resetCounts() {
        counts.clear();
    }
}
