package com.example.mockserver.controller;

import com.example.mockserver.dto.ScenarioDto;
import com.example.mockserver.service.*;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/scenarios")
public class ScenarioController {

    private final ScenarioService scenarioService;
    private final MockApiService apiService;
    private final MockResponseService responseService;

    public ScenarioController(ScenarioService scenarioService, MockApiService apiService,
                               MockResponseService responseService) {
        this.scenarioService = scenarioService;
        this.apiService = apiService;
        this.responseService = responseService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("scenarios", scenarioService.findAll());
        return "scenarios";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        model.addAttribute("scenario", scenarioService.findById(id));
        model.addAttribute("apis", apiService.findAll());
        return "scenario-detail";
    }

    @GetMapping("/api/list")
    @ResponseBody
    public List<ScenarioDto> listJson() {
        return scenarioService.findAll();
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<ScenarioDto> create(@RequestBody ScenarioDto dto) {
        return ResponseEntity.ok(scenarioService.create(dto));
    }

    @PutMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<ScenarioDto> update(@PathVariable Long id, @RequestBody ScenarioDto dto) {
        return ResponseEntity.ok(scenarioService.update(id, dto));
    }

    @DeleteMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        scenarioService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/api/{id}/activate")
    @ResponseBody
    public ResponseEntity<Void> activate(@PathVariable Long id) {
        scenarioService.activate(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/api/deactivate")
    @ResponseBody
    public ResponseEntity<Void> deactivate() {
        scenarioService.deactivate();
        return ResponseEntity.ok().build();
    }

    @PostMapping("/api/{id}/mapping")
    @ResponseBody
    public ResponseEntity<Void> addMapping(@PathVariable Long id, @RequestBody Map<String, Long> body) {
        scenarioService.addMapping(id, body.get("apiId"), body.get("responseId"));
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/api/mapping/{mappingId}")
    @ResponseBody
    public ResponseEntity<Void> removeMapping(@PathVariable Long mappingId) {
        scenarioService.removeMapping(mappingId);
        return ResponseEntity.noContent().build();
    }
}
