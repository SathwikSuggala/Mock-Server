package com.example.mockserver.mapper;

import com.example.mockserver.dto.*;
import com.example.mockserver.entity.*;
import org.springframework.stereotype.Component;
import java.util.stream.Collectors;

@Component
public class MockApiMapper {

    public MockApiDto toDto(MockApi entity) {
        if (entity == null) return null;
        MockApiDto dto = new MockApiDto();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setDescription(entity.getDescription());
        dto.setHttpMethod(entity.getHttpMethod());
        dto.setEndpointPath(entity.getEndpointPath());
        dto.setTags(entity.getTags());
        dto.setEnabled(entity.isEnabled());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());
        dto.setMatcherCount(entity.getMatchers() != null ? entity.getMatchers().size() : 0);
        return dto;
    }

    public MockApiDto toDtoWithMatchers(MockApi entity) {
        MockApiDto dto = toDto(entity);
        if (entity.getMatchers() != null) {
            dto.setMatchers(entity.getMatchers().stream().map(this::toMatcherDto).collect(Collectors.toList()));
        }
        return dto;
    }

    public RequestMatcherDto toMatcherDto(RequestMatcher m) {
        RequestMatcherDto dto = new RequestMatcherDto();
        dto.setId(m.getId());
        dto.setMockApiId(m.getMockApi() != null ? m.getMockApi().getId() : null);
        dto.setName(m.getName());
        dto.setDescription(m.getDescription());
        dto.setPriority(m.getPriority());
        dto.setEnabled(m.isEnabled());
        dto.setMatchHeaders(m.getMatchHeaders());
        dto.setMatchQueryParams(m.getMatchQueryParams());
        dto.setMatchBody(m.getMatchBody());
        dto.setMatchBodyType(m.getMatchBodyType());
        dto.setMatchBodyFormat(m.getMatchBodyFormat());
        dto.setMatchPathVariables(m.getMatchPathVariables());
        dto.setResponseSelectionMode(m.getResponseSelectionMode());
        dto.setSequentialIndex(m.getSequentialIndex());
        dto.setRateLimitRpm(m.getRateLimitRpm());
        if (m.getResponses() != null) {
            dto.setResponses(m.getResponses().stream().map(this::toResponseDto).collect(Collectors.toList()));
        }
        return dto;
    }

    public MockResponseDto toResponseDto(MockResponse r) {
        MockResponseDto dto = new MockResponseDto();
        dto.setId(r.getId());
        dto.setRequestMatcherId(r.getRequestMatcher() != null ? r.getRequestMatcher().getId() : null);
        dto.setName(r.getName());
        dto.setDescription(r.getDescription());
        dto.setEnabled(r.isEnabled());
        dto.setActive(r.isActive());
        dto.setHttpStatus(r.getHttpStatus());
        dto.setResponseHeaders(r.getResponseHeaders());
        dto.setResponseCookies(r.getResponseCookies());
        dto.setResponseBody(r.getResponseBody());
        dto.setContentType(r.getContentType());
        dto.setDelayMs(r.getDelayMs());
        dto.setDelayType(r.getDelayType());
        dto.setDelayMaxMs(r.getDelayMaxMs());
        dto.setFaultType(r.getFaultType());
        dto.setWeight(r.getWeight());
        dto.setWebhookUrl(r.getWebhookUrl());
        dto.setWebhookDelayMs(r.getWebhookDelayMs());
        dto.setWebhookBody(r.getWebhookBody());
        return dto;
    }

    public void updateEntity(MockApi entity, MockApiDto dto) {
        entity.setName(dto.getName());
        entity.setDescription(dto.getDescription());
        entity.setHttpMethod(dto.getHttpMethod());
        entity.setEndpointPath(dto.getEndpointPath());
        entity.setTags(dto.getTags());
        entity.setEnabled(dto.isEnabled());
    }
}
