package com.example.mockserver.service;

import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.example.mockserver.util.RequestMatcherUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Core engine that matches an incoming request against configured matchers and
 * returns the appropriate response.
 */
@Service
@Transactional
public class MockEngineService {

    private final MockApiRepository apiRepo;
    private final RequestMatcherRepository matcherRepo;
    private final MockResponseRepository responseRepo;
    private final StatefulFlowRepository stateRepo;
    private final ScenarioRepository scenarioRepo;
    private final RateLimitService rateLimitService;

    public MockEngineService(MockApiRepository apiRepo, RequestMatcherRepository matcherRepo,
            MockResponseRepository responseRepo, StatefulFlowRepository stateRepo,
            ScenarioRepository scenarioRepo, RateLimitService rateLimitService) {
        this.apiRepo = apiRepo;
        this.matcherRepo = matcherRepo;
        this.responseRepo = responseRepo;
        this.stateRepo = stateRepo;
        this.scenarioRepo = scenarioRepo;
        this.rateLimitService = rateLimitService;
    }

    public record MatchResult(MockApi api, RequestMatcher matcher, MockResponse response,
            Map<String, String> pathVars, String activeScenarioName) {
    }

    /**
     * Find best matching MockApi and response for the incoming request.
     * Returns a MatchResult with response==null when rate-limited (caller should
     * return 429).
     */
    public Optional<MatchResult> match(HttpServletRequest request, String requestBody) {
        String method = request.getMethod().toUpperCase();
        String path = request.getRequestURI();

        String activeScenarioName = scenarioRepo.findByActiveTrue().map(Scenario::getName).orElse(null);

        List<MockApi> apis = apiRepo.findByEnabledTrue();
        for (MockApi api : apis) {
            if (!api.getHttpMethod().equalsIgnoreCase(method))
                continue;
            if (!RequestMatcherUtil.pathMatches(api.getEndpointPath(), path))
                continue;

            Map<String, String> pathVars = RequestMatcherUtil.extractPathVariables(api.getEndpointPath(), path);
            Map<String, String> headers = RequestMatcherUtil.headersToMap(request);
            Map<String, String> queryParams = RequestMatcherUtil.queryParamsToMap(request);

            List<RequestMatcher> matchers = matcherRepo.findByMockApiIdAndEnabledTrueOrderByPriorityDesc(api.getId());

            for (RequestMatcher matcher : matchers) {
                if (!matchesMatcher(matcher, headers, queryParams, pathVars, requestBody))
                    continue;

                // Rate limit check — null response signals 429
                if (matcher.getRateLimitRpm() > 0
                        && !rateLimitService.isAllowed(matcher.getId(), matcher.getRateLimitRpm())) {
                    return Optional.of(new MatchResult(api, matcher, null, pathVars, activeScenarioName));
                }

                MockResponse response = selectResponse(matcher, api, request, activeScenarioName);
                if (response == null)
                    continue;

                return Optional.of(new MatchResult(api, matcher, response, pathVars, activeScenarioName));
            }

            // No matcher matched - use default response
            MockResponse defaultResp = api.getDefaultResponse();
            if (defaultResp != null) {
                return Optional.of(new MatchResult(api, null, defaultResp, pathVars, activeScenarioName));
            }
        }
        return Optional.empty();
    }

    private boolean matchesMatcher(RequestMatcher m, Map<String, String> headers,
            Map<String, String> queryParams, Map<String, String> pathVars,
            String body) {
        if (!RequestMatcherUtil.matchesMap(m.getMatchHeaders(), headers))
            return false;
        if (!RequestMatcherUtil.matchesMap(m.getMatchQueryParams(), queryParams))
            return false;
        if (!RequestMatcherUtil.matchesMap(m.getMatchPathVariables(), pathVars))
            return false;
        if (!RequestMatcherUtil.matchesBody(m.getMatchBody(), m.getMatchBodyType(), body))
            return false;
        return true;
    }

    private MockResponse selectResponse(RequestMatcher matcher, MockApi api,
            HttpServletRequest request, String activeScenario) {
        if (activeScenario != null) {
            Optional<Scenario> sc = scenarioRepo.findByActiveTrue();
            if (sc.isPresent()) {
                Optional<MockResponse> scenResp = sc.get().getMappings().stream()
                        .filter(m2 -> m2.getMockApi().getId().equals(api.getId()))
                        .map(m2 -> m2.getMockResponse())
                        .filter(r -> r != null && r.isEnabled())
                        .findFirst();
                if (scenResp.isPresent())
                    return scenResp.get();
            }
        }

        List<MockResponse> responses = responseRepo.findByRequestMatcherIdAndEnabledTrue(matcher.getId());
        if (responses.isEmpty())
            return null;

        return switch (matcher.getResponseSelectionMode()) {
            case "RANDOM" -> selectRandom(responses);
            case "SEQUENTIAL" -> selectSequential(matcher, responses);
            default -> responses.stream().filter(MockResponse::isActive).findFirst()
                    .orElse(responses.get(0));
        };
    }

    private MockResponse selectRandom(List<MockResponse> responses) {
        int totalWeight = responses.stream().mapToInt(MockResponse::getWeight).sum();
        if (totalWeight <= 0)
            return responses.get(0);
        int rand = new Random().nextInt(totalWeight);
        int cumulative = 0;
        for (MockResponse r : responses) {
            cumulative += r.getWeight();
            if (rand < cumulative)
                return r;
        }
        return responses.get(responses.size() - 1);
    }

    private MockResponse selectSequential(RequestMatcher matcher, List<MockResponse> responses) {
        int idx = matcher.getSequentialIndex() % responses.size();
        MockResponse selected = responses.get(idx);
        matcher.setSequentialIndex(idx + 1);
        matcherRepo.save(matcher);
        return selected;
    }

    /**
     * Determine state key for stateful flow — supports GLOBAL, PER_CLIENT,
     * PER_SESSION.
     */
    public String resolveStateKey(MockApi api, HttpServletRequest request) {
        List<StatefulFlow> flows = stateRepo.findByMockApiId(api.getId());
        if (flows.isEmpty())
            return "GLOBAL";
        StatefulFlow flow = flows.get(0);
        return switch (flow.getTrackingMode()) {
            case "PER_CLIENT" -> request.getRemoteAddr();
            case "PER_SESSION" -> {
                String header = flow.getSessionHeader();
                String val = (header != null && !header.isBlank()) ? request.getHeader(header) : null;
                yield val != null ? val : "GLOBAL";
            }
            default -> "GLOBAL";
        };
    }
}
