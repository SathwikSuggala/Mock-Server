package com.example.mockserver.controller;

import com.example.mockserver.service.SettingsService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequestMapping("/settings")
public class SettingsController {

    private final SettingsService settingsService;

    public SettingsController(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    @GetMapping
    public String page(Model model) {
        model.addAttribute("settings", settingsService.getAll());
        return "settings";
    }

    @PostMapping("/api/save")
    @ResponseBody
    public ResponseEntity<String> save(@RequestBody Map<String, String> settings) {
        settingsService.saveAll(settings);
        return ResponseEntity.ok("{\"message\":\"Settings saved\"}");
    }

    @GetMapping("/api/all")
    @ResponseBody
    public Map<String, String> getAll() {
        return settingsService.getAll();
    }
}
