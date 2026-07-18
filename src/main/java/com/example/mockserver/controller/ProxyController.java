package com.example.mockserver.controller;

import com.example.mockserver.entity.ProxyRecording;
import com.example.mockserver.service.*;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/proxy")
public class ProxyController {

    private final ProxyService proxyService;
    private final SettingsService settingsService;

    public ProxyController(ProxyService proxyService, SettingsService settingsService) {
        this.proxyService = proxyService;
        this.settingsService = settingsService;
    }

    @GetMapping
    public String page(Model model) {
        model.addAttribute("proxyEnabled", settingsService.get("proxy.enabled", "false"));
        model.addAttribute("proxyTarget", settingsService.get("proxy.targetUrl", ""));
        return "proxy";
    }

    @GetMapping("/api/recordings")
    @ResponseBody
    public Page<ProxyRecording> recordings(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return proxyService.findAll(page, size);
    }

    @PostMapping("/api/import/{id}")
    @ResponseBody
    public ResponseEntity<String> importRecording(@PathVariable Long id) {
        try {
            proxyService.importAsApi(id);
            return ResponseEntity.ok("{\"message\":\"Imported as API\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @DeleteMapping("/api/recordings/{id}")
    @ResponseBody
    public ResponseEntity<Void> deleteRecording(@PathVariable Long id) {
        proxyService.deleteRecording(id);
        return ResponseEntity.noContent().build();
    }
}
