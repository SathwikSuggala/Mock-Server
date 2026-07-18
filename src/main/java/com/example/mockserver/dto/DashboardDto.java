package com.example.mockserver.dto;

public class DashboardDto {
    private long totalApis;
    private long totalMatchers;
    private long totalResponses;
    private String activeScenario;
    private long requestsToday;
    private long requestsLastHour;
    private java.util.List<String[]> topCalledApis;

    public long getTotalApis() { return totalApis; }
    public void setTotalApis(long totalApis) { this.totalApis = totalApis; }
    public long getTotalMatchers() { return totalMatchers; }
    public void setTotalMatchers(long totalMatchers) { this.totalMatchers = totalMatchers; }
    public long getTotalResponses() { return totalResponses; }
    public void setTotalResponses(long totalResponses) { this.totalResponses = totalResponses; }
    public String getActiveScenario() { return activeScenario; }
    public void setActiveScenario(String activeScenario) { this.activeScenario = activeScenario; }
    public long getRequestsToday() { return requestsToday; }
    public void setRequestsToday(long requestsToday) { this.requestsToday = requestsToday; }
    public long getRequestsLastHour() { return requestsLastHour; }
    public void setRequestsLastHour(long requestsLastHour) { this.requestsLastHour = requestsLastHour; }
    public java.util.List<String[]> getTopCalledApis() { return topCalledApis; }
    public void setTopCalledApis(java.util.List<String[]> topCalledApis) { this.topCalledApis = topCalledApis; }
}
