package com.example.mockserver.service;

import com.example.mockserver.dto.MockResponseDto;
import com.example.mockserver.entity.*;
import com.example.mockserver.mapper.MockApiMapper;
import com.example.mockserver.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class MockResponseService {

    private final MockResponseRepository responseRepo;
    private final RequestMatcherRepository matcherRepo;
    private final MockApiMapper mapper;

    public MockResponseService(MockResponseRepository responseRepo,
                               RequestMatcherRepository matcherRepo,
                               MockApiMapper mapper) {
        this.responseRepo = responseRepo;
        this.matcherRepo = matcherRepo;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<MockResponseDto> findByMatcherId(Long matcherId) {
        return responseRepo.findByRequestMatcherId(matcherId).stream()
                .map(mapper::toResponseDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MockResponseDto findById(Long id) {
        return responseRepo.findById(id).map(mapper::toResponseDto)
                .orElseThrow(() -> new RuntimeException("Response not found: " + id));
    }

    public MockResponseDto create(MockResponseDto dto) {
        MockResponse r = new MockResponse();
        applyDto(r, dto);
        if (dto.getRequestMatcherId() != null) {
            RequestMatcher m = matcherRepo.findById(dto.getRequestMatcherId())
                    .orElseThrow(() -> new RuntimeException("Matcher not found"));
            r.setRequestMatcher(m);
        }
        return mapper.toResponseDto(responseRepo.save(r));
    }

    public MockResponseDto update(Long id, MockResponseDto dto) {
        MockResponse r = responseRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Response not found: " + id));
        applyDto(r, dto);
        return mapper.toResponseDto(responseRepo.save(r));
    }

    public void delete(Long id) {
        responseRepo.deleteById(id);
    }

    public void setActive(Long matcherId, Long responseId) {
        // Deactivate all for this matcher
        responseRepo.findByRequestMatcherId(matcherId).forEach(r -> {
            r.setActive(false);
            responseRepo.save(r);
        });
        // Activate the selected one
        responseRepo.findById(responseId).ifPresent(r -> {
            r.setActive(true);
            responseRepo.save(r);
        });
    }

    public MockResponseDto clone(Long id) {
        MockResponse original = responseRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Response not found: " + id));
        MockResponse copy = new MockResponse();
        copy.setName(original.getName() + " (copy)");
        copy.setDescription(original.getDescription());
        copy.setEnabled(original.isEnabled());
        copy.setActive(false);
        copy.setHttpStatus(original.getHttpStatus());
        copy.setResponseHeaders(original.getResponseHeaders());
        copy.setResponseCookies(original.getResponseCookies());
        copy.setResponseBody(original.getResponseBody());
        copy.setContentType(original.getContentType());
        copy.setDelayMs(original.getDelayMs());
        copy.setDelayType(original.getDelayType());
        copy.setDelayMaxMs(original.getDelayMaxMs());
        copy.setFaultType(original.getFaultType());
        copy.setWeight(original.getWeight());
        copy.setWebhookUrl(original.getWebhookUrl());
        copy.setWebhookDelayMs(original.getWebhookDelayMs());
        copy.setWebhookBody(original.getWebhookBody());
        copy.setRequestMatcher(original.getRequestMatcher());
        return mapper.toResponseDto(responseRepo.save(copy));
    }

    private void applyDto(MockResponse r, MockResponseDto dto) {
        r.setName(dto.getName());
        r.setDescription(dto.getDescription());
        r.setEnabled(dto.isEnabled());
        r.setActive(dto.isActive());
        r.setHttpStatus(dto.getHttpStatus() > 0 ? dto.getHttpStatus() : 200);
        r.setResponseHeaders(dto.getResponseHeaders());
        r.setResponseCookies(dto.getResponseCookies());
        r.setResponseBody(dto.getResponseBody());
        r.setContentType(dto.getContentType() != null ? dto.getContentType() : "application/json");
        r.setDelayMs(dto.getDelayMs());
        r.setDelayType(dto.getDelayType() != null ? dto.getDelayType() : "FIXED");
        r.setDelayMaxMs(dto.getDelayMaxMs());
        r.setFaultType(dto.getFaultType());
        r.setWeight(dto.getWeight() > 0 ? dto.getWeight() : 100);
        r.setWebhookUrl(dto.getWebhookUrl());
        r.setWebhookDelayMs(dto.getWebhookDelayMs());
        r.setWebhookBody(dto.getWebhookBody());
    }
}
