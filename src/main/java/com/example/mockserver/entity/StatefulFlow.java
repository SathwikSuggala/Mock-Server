package com.example.mockserver.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "stateful_flow", indexes = {
    @Index(name = "idx_state_api", columnList = "mock_api_id"),
    @Index(name = "idx_state_key", columnList = "state_key")
})
public class StatefulFlow {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mock_api_id", nullable = false)
    private MockApi mockApi;

    @Column(name = "state_key", nullable = false)
    private String stateKey; // "GLOBAL" or client-ip or session-id

    @Column(name = "current_index")
    private int currentIndex = 0;

    @Column(name = "tracking_mode", length = 20)
    private String trackingMode = "GLOBAL"; // GLOBAL, PER_CLIENT, PER_SESSION

    @Column(name = "session_header", length = 100)
    private String sessionHeader;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public MockApi getMockApi() { return mockApi; }
    public void setMockApi(MockApi mockApi) { this.mockApi = mockApi; }
    public String getStateKey() { return stateKey; }
    public void setStateKey(String stateKey) { this.stateKey = stateKey; }
    public int getCurrentIndex() { return currentIndex; }
    public void setCurrentIndex(int currentIndex) { this.currentIndex = currentIndex; }
    public String getTrackingMode() { return trackingMode; }
    public void setTrackingMode(String trackingMode) { this.trackingMode = trackingMode; }
    public String getSessionHeader() { return sessionHeader; }
    public void setSessionHeader(String sessionHeader) { this.sessionHeader = sessionHeader; }
}
