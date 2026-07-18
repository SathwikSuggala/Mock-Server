package com.example.mockserver.controller;

import com.example.mockserver.entity.CallLog;
import com.example.mockserver.service.CallLogService;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
@RequestMapping("/logs")
public class CallLogController {

    private final CallLogService logService;

    public CallLogController(CallLogService logService) {
        this.logService = logService;
    }

    @GetMapping
    public String logsPage(Model model) {
        return "logs";
    }

    @GetMapping("/api/search")
    @ResponseBody
    public Page<CallLog> search(
            @RequestParam(required = false) String method,
            @RequestParam(required = false) String path,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        LocalDateTime fromDt = from != null && !from.isBlank()
                ? LocalDateTime.parse(from, DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null;
        LocalDateTime toDt = to != null && !to.isBlank()
                ? LocalDateTime.parse(to, DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null;

        return logService.search(
                method != null && method.isBlank() ? null : method,
                path != null && path.isBlank() ? null : path,
                status, fromDt, toDt, page, size);
    }

    @DeleteMapping("/api/clear")
    @ResponseBody
    public ResponseEntity<Void> clearAll() {
        logService.clearAll();
        return ResponseEntity.noContent().build();
    }
}
