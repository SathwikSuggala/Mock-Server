package com.example.mockserver.service;

import com.example.mockserver.dto.RequestMatcherDto;
import com.example.mockserver.entity.*;
import com.example.mockserver.mapper.MockApiMapper;
import com.example.mockserver.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class RequestMatcherService {

    private final RequestMatcherRepository matcherRepo;
    private final MockApiRepository apiRepo;
    private final MockApiMapper mapper;

    public RequestMatcherService(RequestMatcherRepository matcherRepo, MockApiRepository apiRepo, MockApiMapper mapper) {
        this.matcherRepo = matcherRepo;
        this.apiRepo = apiRepo;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<RequestMatcherDto> findByApiId(Long apiId) {
        return matcherRepo.findByMockApiIdOrderByPriorityDesc(apiId).stream()
                .map(mapper::toMatcherDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RequestMatcherDto> findByApiIdWithResponses(Long apiId) {
        return matcherRepo.findByApiIdWithResponses(apiId).stream()
                .map(mapper::toMatcherDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public RequestMatcherDto findById(Long id) {
        return matcherRepo.findById(id).map(mapper::toMatcherDto)
                .orElseThrow(() -> new RuntimeException("Matcher not found: " + id));
    }

    public RequestMatcherDto create(RequestMatcherDto dto) {
        RequestMatcher m = new RequestMatcher();
        applyDto(m, dto);
        MockApi api = apiRepo.findById(dto.getMockApiId())
                .orElseThrow(() -> new RuntimeException("API not found"));
        m.setMockApi(api);
        return mapper.toMatcherDto(matcherRepo.save(m));
    }

    public RequestMatcherDto update(Long id, RequestMatcherDto dto) {
        RequestMatcher m = matcherRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Matcher not found: " + id));
        applyDto(m, dto);
        return mapper.toMatcherDto(matcherRepo.save(m));
    }

    public void delete(Long id) {
        matcherRepo.deleteById(id);
    }

    public RequestMatcherDto clone(Long id) {
        RequestMatcher original = matcherRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Matcher not found: " + id));
        RequestMatcher copy = new RequestMatcher();
        copy.setMockApi(original.getMockApi());
        copy.setName(original.getName() + " (copy)");
        copy.setDescription(original.getDescription());
        copy.setPriority(original.getPriority());
        copy.setEnabled(original.isEnabled());
        copy.setMatchHeaders(original.getMatchHeaders());
        copy.setMatchQueryParams(original.getMatchQueryParams());
        copy.setMatchBody(original.getMatchBody());
        copy.setMatchBodyType(original.getMatchBodyType());
        copy.setMatchPathVariables(original.getMatchPathVariables());
        copy.setResponseSelectionMode(original.getResponseSelectionMode());
        copy.setRateLimitRpm(original.getRateLimitRpm());
        return mapper.toMatcherDto(matcherRepo.save(copy));
    }

    public void updateSequentialIndex(Long id, int index) {
        matcherRepo.findById(id).ifPresent(m -> {
            m.setSequentialIndex(index);
            matcherRepo.save(m);
        });
    }

    private void applyDto(RequestMatcher m, RequestMatcherDto dto) {
        m.setName(dto.getName());
        m.setDescription(dto.getDescription());
        m.setPriority(dto.getPriority());
        m.setEnabled(dto.isEnabled());
        m.setMatchHeaders(dto.getMatchHeaders());
        m.setMatchQueryParams(dto.getMatchQueryParams());
        m.setMatchBody(dto.getMatchBody());
        m.setMatchBodyType(dto.getMatchBodyType());
        m.setMatchPathVariables(dto.getMatchPathVariables());
        m.setResponseSelectionMode(dto.getResponseSelectionMode());
        m.setRateLimitRpm(dto.getRateLimitRpm());
    }
}
