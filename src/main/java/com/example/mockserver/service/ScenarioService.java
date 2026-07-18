package com.example.mockserver.service;

import com.example.mockserver.dto.*;
import com.example.mockserver.entity.*;
import com.example.mockserver.mapper.MockApiMapper;
import com.example.mockserver.repository.*;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ScenarioService {

    private final ScenarioRepository scenarioRepo;
    private final ScenarioMappingRepository mappingRepo;
    private final MockApiRepository apiRepo;
    private final MockResponseRepository responseRepo;
    private final MockApiMapper mapper;

    public ScenarioService(ScenarioRepository scenarioRepo, ScenarioMappingRepository mappingRepo,
                           MockApiRepository apiRepo, MockResponseRepository responseRepo,
                           MockApiMapper mapper) {
        this.scenarioRepo = scenarioRepo;
        this.mappingRepo = mappingRepo;
        this.apiRepo = apiRepo;
        this.responseRepo = responseRepo;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<ScenarioDto> findAll() {
        return scenarioRepo.findAllByOrderByNameAsc().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ScenarioDto findById(Long id) {
        return scenarioRepo.findById(id).map(this::toDto)
                .orElseThrow(() -> new RuntimeException("Scenario not found: " + id));
    }

    public ScenarioDto create(ScenarioDto dto) {
        Scenario s = new Scenario();
        s.setName(dto.getName());
        s.setDescription(dto.getDescription());
        s.setCronExpression(dto.getCronExpression());
        s.setActiveUntil(dto.getActiveUntil());
        return toDto(scenarioRepo.save(s));
    }

    public ScenarioDto update(Long id, ScenarioDto dto) {
        Scenario s = scenarioRepo.findById(id).orElseThrow(() -> new RuntimeException("Scenario not found"));
        s.setName(dto.getName());
        s.setDescription(dto.getDescription());
        s.setCronExpression(dto.getCronExpression());
        s.setActiveUntil(dto.getActiveUntil());
        return toDto(scenarioRepo.save(s));
    }

    public void delete(Long id) {
        scenarioRepo.deleteById(id);
    }

    public void activate(Long id) {
        // Deactivate all
        scenarioRepo.findAll().forEach(s -> { s.setActive(false); scenarioRepo.save(s); });
        // Activate target
        Scenario target = scenarioRepo.findById(id).orElseThrow();
        target.setActive(true);
        scenarioRepo.save(target);
        // Apply mappings: set active responses
        mappingRepo.findByScenarioId(id).forEach(mapping -> {
            // deactivate all responses for matcher containing this response
            MockResponse resp = mapping.getMockResponse();
            if (resp != null && resp.getRequestMatcher() != null) {
                responseRepo.findByRequestMatcherId(resp.getRequestMatcher().getId())
                        .forEach(r -> { r.setActive(false); responseRepo.save(r); });
                resp.setActive(true);
                responseRepo.save(resp);
            }
        });
    }

    public void deactivate() {
        scenarioRepo.findAll().forEach(s -> { s.setActive(false); scenarioRepo.save(s); });
    }

    /** Auto-activate scenarios by cron or deactivate when activeUntil has passed. Runs every minute. */
    @Scheduled(fixedRate = 60_000)
    public void checkScheduledScenarios() {
        LocalDateTime now = LocalDateTime.now();
        scenarioRepo.findAll().forEach(s -> {
            // Auto-deactivate if activeUntil has passed
            if (s.isActive() && s.getActiveUntil() != null && now.isAfter(s.getActiveUntil())) {
                s.setActive(false);
                scenarioRepo.save(s);
            }
        });
    }

    public void addMapping(Long scenarioId, Long apiId, Long responseId) {
        Scenario s = scenarioRepo.findById(scenarioId).orElseThrow();
        MockApi api = apiRepo.findById(apiId).orElseThrow();
        MockResponse resp = responseRepo.findById(responseId).orElseThrow();
        ScenarioMapping m = mappingRepo.findByScenarioIdAndMockApiId(scenarioId, apiId)
                .orElse(new ScenarioMapping());
        m.setScenario(s);
        m.setMockApi(api);
        m.setMockResponse(resp);
        mappingRepo.save(m);
    }

    public void removeMapping(Long mappingId) {
        mappingRepo.deleteById(mappingId);
    }

    private ScenarioDto toDto(Scenario s) {
        ScenarioDto dto = new ScenarioDto();
        dto.setId(s.getId());
        dto.setName(s.getName());
        dto.setDescription(s.getDescription());
        dto.setActive(s.isActive());
        dto.setCreatedAt(s.getCreatedAt());
        dto.setCronExpression(s.getCronExpression());
        dto.setActiveUntil(s.getActiveUntil());
        List<ScenarioMappingDto> mappingDtos = new ArrayList<>();
        if (s.getMappings() != null) {
            for (ScenarioMapping m : s.getMappings()) {
                ScenarioMappingDto md = new ScenarioMappingDto();
                md.setId(m.getId());
                md.setScenarioId(s.getId());
                md.setMockApiId(m.getMockApi() != null ? m.getMockApi().getId() : null);
                md.setMockApiName(m.getMockApi() != null ? m.getMockApi().getName() : null);
                md.setMockResponseId(m.getMockResponse() != null ? m.getMockResponse().getId() : null);
                md.setMockResponseName(m.getMockResponse() != null ? m.getMockResponse().getName() : null);
                mappingDtos.add(md);
            }
        }
        dto.setMappings(mappingDtos);
        return dto;
    }
}
