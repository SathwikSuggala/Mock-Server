package com.example.mockserver.service;

import com.example.mockserver.dto.MockApiDto;
import com.example.mockserver.entity.*;
import com.example.mockserver.mapper.MockApiMapper;
import com.example.mockserver.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class MockApiService {

    private final MockApiRepository apiRepo;
    private final MockApiMapper mapper;

    public MockApiService(MockApiRepository apiRepo, MockApiMapper mapper) {
        this.apiRepo = apiRepo;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<MockApiDto> findAll() {
        return apiRepo.findAll().stream().map(mapper::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MockApiDto findById(Long id) {
        return apiRepo.findById(id).map(mapper::toDtoWithMatchers)
                .orElseThrow(() -> new RuntimeException("API not found: " + id));
    }

    @Transactional(readOnly = true)
    public MockApi findEntityById(Long id) {
        return apiRepo.findById(id).orElseThrow(() -> new RuntimeException("API not found: " + id));
    }

    public MockApiDto create(MockApiDto dto) {
        MockApi entity = new MockApi();
        mapper.updateEntity(entity, dto);
        return mapper.toDto(apiRepo.save(entity));
    }

    public MockApiDto update(Long id, MockApiDto dto) {
        MockApi entity = findEntityById(id);
        mapper.updateEntity(entity, dto);
        return mapper.toDto(apiRepo.save(entity));
    }

    public void delete(Long id) {
        apiRepo.deleteById(id);
    }

    public void toggleEnabled(Long id) {
        MockApi api = findEntityById(id);
        api.setEnabled(!api.isEnabled());
        apiRepo.save(api);
    }

    @Transactional(readOnly = true)
    public List<MockApi> findAllEnabled() {
        return apiRepo.findByEnabledTrue();
    }

    public MockApiDto clone(Long id) {
        MockApi original = findEntityById(id);
        MockApi copy = new MockApi();
        copy.setName(original.getName() + " (copy)");
        copy.setDescription(original.getDescription());
        copy.setHttpMethod(original.getHttpMethod());
        copy.setEndpointPath(original.getEndpointPath());
        copy.setTags(original.getTags());
        copy.setEnabled(original.isEnabled());
        // Deep copy matchers and responses
        List<com.example.mockserver.entity.RequestMatcher> copiedMatchers = new java.util.ArrayList<>();
        for (com.example.mockserver.entity.RequestMatcher m : original.getMatchers()) {
            com.example.mockserver.entity.RequestMatcher mc = new com.example.mockserver.entity.RequestMatcher();
            mc.setMockApi(copy);
            mc.setName(m.getName());
            mc.setDescription(m.getDescription());
            mc.setPriority(m.getPriority());
            mc.setEnabled(m.isEnabled());
            mc.setMatchHeaders(m.getMatchHeaders());
            mc.setMatchQueryParams(m.getMatchQueryParams());
            mc.setMatchBody(m.getMatchBody());
            mc.setMatchBodyType(m.getMatchBodyType());
            mc.setMatchPathVariables(m.getMatchPathVariables());
            mc.setResponseSelectionMode(m.getResponseSelectionMode());
            mc.setRateLimitRpm(m.getRateLimitRpm());
            List<com.example.mockserver.entity.MockResponse> copiedResponses = new java.util.ArrayList<>();
            for (com.example.mockserver.entity.MockResponse r : m.getResponses()) {
                com.example.mockserver.entity.MockResponse rc = new com.example.mockserver.entity.MockResponse();
                rc.setRequestMatcher(mc);
                rc.setName(r.getName());
                rc.setDescription(r.getDescription());
                rc.setEnabled(r.isEnabled());
                rc.setActive(r.isActive());
                rc.setHttpStatus(r.getHttpStatus());
                rc.setResponseHeaders(r.getResponseHeaders());
                rc.setResponseCookies(r.getResponseCookies());
                rc.setResponseBody(r.getResponseBody());
                rc.setContentType(r.getContentType());
                rc.setDelayMs(r.getDelayMs());
                rc.setDelayType(r.getDelayType());
                rc.setDelayMaxMs(r.getDelayMaxMs());
                rc.setFaultType(r.getFaultType());
                rc.setWeight(r.getWeight());
                rc.setWebhookUrl(r.getWebhookUrl());
                rc.setWebhookDelayMs(r.getWebhookDelayMs());
                rc.setWebhookBody(r.getWebhookBody());
                copiedResponses.add(rc);
            }
            mc.setResponses(copiedResponses);
            copiedMatchers.add(mc);
        }
        copy.setMatchers(copiedMatchers);
        return mapper.toDto(apiRepo.save(copy));
    }

    @Transactional(readOnly = true)
    public List<MockApiDto> search(String query) {
        if (query == null || query.isBlank()) return findAll();
        String q = query.toLowerCase();
        return apiRepo.findAll().stream()
                .filter(a -> (a.getName() != null && a.getName().toLowerCase().contains(q))
                          || (a.getEndpointPath() != null && a.getEndpointPath().toLowerCase().contains(q))
                          || (a.getTags() != null && a.getTags().toLowerCase().contains(q))
                          || (a.getDescription() != null && a.getDescription().toLowerCase().contains(q)))
                .map(mapper::toDto)
                .collect(Collectors.toList());
    }
}
