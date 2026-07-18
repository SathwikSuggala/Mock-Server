package com.example.mockserver.controller;

import com.example.mockserver.dto.MockApiDto;
import com.example.mockserver.service.MockApiService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/apis")
public class ApiManagementController {

    private final MockApiService apiService;

    public ApiManagementController(MockApiService apiService) {
        this.apiService = apiService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("apis", apiService.findAll());
        return "api-list";
    }

    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute("api", new MockApiDto());
        return "api-form";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        model.addAttribute("api", apiService.findById(id));
        return "api-detail";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        model.addAttribute("api", apiService.findById(id));
        return "api-form";
    }

    // REST endpoints used by AJAX
    @GetMapping("/api/list")
    @ResponseBody
    public List<MockApiDto> listJson() {
        return apiService.findAll();
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<MockApiDto> create(@RequestBody MockApiDto dto) {
        return ResponseEntity.ok(apiService.create(dto));
    }

    @PutMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<MockApiDto> update(@PathVariable Long id, @RequestBody MockApiDto dto) {
        return ResponseEntity.ok(apiService.update(id, dto));
    }

    @DeleteMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        apiService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/api/{id}/toggle")
    @ResponseBody
    public ResponseEntity<Void> toggle(@PathVariable Long id) {
        apiService.toggleEnabled(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/api/{id}/clone")
    @ResponseBody
    public ResponseEntity<MockApiDto> clone(@PathVariable Long id) {
        return ResponseEntity.ok(apiService.clone(id));
    }

    @GetMapping("/api/search")
    @ResponseBody
    public List<MockApiDto> search(@RequestParam(defaultValue = "") String q) {
        return apiService.search(q);
    }
}
