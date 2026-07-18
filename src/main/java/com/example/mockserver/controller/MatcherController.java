package com.example.mockserver.controller;

import com.example.mockserver.dto.RequestMatcherDto;
import com.example.mockserver.service.*;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/matchers")
public class MatcherController {

    private final RequestMatcherService matcherService;
    private final MockApiService apiService;

    public MatcherController(RequestMatcherService matcherService, MockApiService apiService) {
        this.matcherService = matcherService;
        this.apiService = apiService;
    }

    @GetMapping("/api/{apiId}")
    public String list(@PathVariable Long apiId, Model model) {
        model.addAttribute("api", apiService.findById(apiId));
        model.addAttribute("matchers", matcherService.findByApiId(apiId));
        return "matchers";
    }

    @GetMapping("/api/json/{apiId}")
    @ResponseBody
    public List<RequestMatcherDto> listJson(@PathVariable Long apiId) {
        return matcherService.findByApiIdWithResponses(apiId);
    }

    @GetMapping("/{id}/json")
    @ResponseBody
    public RequestMatcherDto getJson(@PathVariable Long id) {
        return matcherService.findById(id);
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<RequestMatcherDto> create(@RequestBody RequestMatcherDto dto) {
        return ResponseEntity.ok(matcherService.create(dto));
    }

    @PutMapping("/{id}")
    @ResponseBody
    public ResponseEntity<RequestMatcherDto> update(@PathVariable Long id, @RequestBody RequestMatcherDto dto) {
        return ResponseEntity.ok(matcherService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        matcherService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/clone")
    @ResponseBody
    public ResponseEntity<RequestMatcherDto> clone(@PathVariable Long id) {
        return ResponseEntity.ok(matcherService.clone(id));
    }
}
