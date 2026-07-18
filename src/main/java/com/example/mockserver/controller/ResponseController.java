package com.example.mockserver.controller;

import com.example.mockserver.dto.MockResponseDto;
import com.example.mockserver.service.*;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/responses")
public class ResponseController {

    private final MockResponseService responseService;
    private final RequestMatcherService matcherService;
    private final MockApiService apiService;

    public ResponseController(MockResponseService responseService,
                               RequestMatcherService matcherService,
                               MockApiService apiService) {
        this.responseService = responseService;
        this.matcherService = matcherService;
        this.apiService = apiService;
    }

    @GetMapping("/matcher/{matcherId}")
    public String list(@PathVariable Long matcherId, Model model) {
        model.addAttribute("matcher", matcherService.findById(matcherId));
        model.addAttribute("responses", responseService.findByMatcherId(matcherId));
        return "responses";
    }

    @GetMapping("/matcher/json/{matcherId}")
    @ResponseBody
    public List<MockResponseDto> listJson(@PathVariable Long matcherId) {
        return responseService.findByMatcherId(matcherId);
    }

    @GetMapping("/{id}/json")
    @ResponseBody
    public MockResponseDto getJson(@PathVariable Long id) {
        return responseService.findById(id);
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<MockResponseDto> create(@RequestBody MockResponseDto dto) {
        return ResponseEntity.ok(responseService.create(dto));
    }

    @PutMapping("/{id}")
    @ResponseBody
    public ResponseEntity<MockResponseDto> update(@PathVariable Long id, @RequestBody MockResponseDto dto) {
        return ResponseEntity.ok(responseService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        responseService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/matcher/{matcherId}/active/{responseId}")
    @ResponseBody
    public ResponseEntity<Void> setActive(@PathVariable Long matcherId, @PathVariable Long responseId) {
        responseService.setActive(matcherId, responseId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/clone")
    @ResponseBody
    public ResponseEntity<MockResponseDto> clone(@PathVariable Long id) {
        return ResponseEntity.ok(responseService.clone(id));
    }
}
