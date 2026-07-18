package com.example.mockserver.service;

import com.example.mockserver.dto.DashboardDto;
import com.example.mockserver.repository.*;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class DashboardService {

    private final MockApiRepository apiRepo;
    private final RequestMatcherRepository matcherRepo;
    private final MockResponseRepository responseRepo;
    private final ScenarioRepository scenarioRepo;
    private final CallLogService logService;

    public DashboardService(MockApiRepository apiRepo, RequestMatcherRepository matcherRepo,
                            MockResponseRepository responseRepo, ScenarioRepository scenarioRepo,
                            CallLogService logService) {
        this.apiRepo = apiRepo;
        this.matcherRepo = matcherRepo;
        this.responseRepo = responseRepo;
        this.scenarioRepo = scenarioRepo;
        this.logService = logService;
    }

    public DashboardDto getDashboard() {
        DashboardDto dto = new DashboardDto();
        dto.setTotalApis(apiRepo.count());
        dto.setTotalMatchers(matcherRepo.count());
        dto.setTotalResponses(responseRepo.count());
        dto.setActiveScenario(scenarioRepo.findByActiveTrue().map(s -> s.getName()).orElse("None"));
        dto.setRequestsToday(logService.countToday());
        dto.setRequestsLastHour(logService.countLastHour());

        List<String[]> topApis = new ArrayList<>();
        for (Object[] row : logService.topCalledApis(5)) {
            topApis.add(new String[]{String.valueOf(row[0]), String.valueOf(row[1])});
        }
        dto.setTopCalledApis(topApis);
        return dto;
    }
}
