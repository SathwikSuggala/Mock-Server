package com.example.mockserver.controller;

import com.example.mockserver.service.CallLogService;
import com.example.mockserver.service.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@Controller
public class DashboardController {

    private final DashboardService dashboardService;
    private final CallLogService callLogService;

    public DashboardController(DashboardService dashboardService, CallLogService callLogService) {
        this.dashboardService = dashboardService;
        this.callLogService = callLogService;
    }

    @GetMapping({"/", "/dashboard"})
    public String dashboard(Model model) {
        model.addAttribute("dashboard", dashboardService.getDashboard());
        return "dashboard";
    }

    /** Returns hourly call counts for the last 24 hours for Chart.js. */
    @GetMapping("/dashboard/api/chart-data")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> chartData() {
        List<String> labels = new ArrayList<>();
        List<Long> data = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        for (int i = 23; i >= 0; i--) {
            LocalDateTime from = now.minusHours(i + 1);
            LocalDateTime to = now.minusHours(i);
            long count = callLogService.search(null, null, null, from, to, 0, 1).getTotalElements();
            labels.add(from.getHour() + ":00");
            data.add(count);
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("data", data);
        return ResponseEntity.ok(result);
    }
}
