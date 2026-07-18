package com.example.mockserver.service;

import com.example.mockserver.entity.*;
import com.example.mockserver.repository.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@Transactional
public class ImportExportService {

    private final MockApiRepository apiRepo;
    private final ScenarioRepository scenarioRepo;
    private final ObjectMapper objectMapper;

    public ImportExportService(MockApiRepository apiRepo, ScenarioRepository scenarioRepo) {
        this.apiRepo = apiRepo;
        this.scenarioRepo = scenarioRepo;
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    public String exportAll() throws Exception {
        Map<String, Object> export = new LinkedHashMap<>();
        List<MockApi> apis = apiRepo.findAll();
        export.put("apis", apis);
        export.put("scenarios", scenarioRepo.findAll());
        return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(export);
    }

    public void importAll(String json) throws Exception {
        Map<String, Object> data = objectMapper.readValue(json, new TypeReference<>() {});
        // Import APIs
        if (data.containsKey("apis")) {
            List<MockApi> apis = objectMapper.convertValue(data.get("apis"), new TypeReference<>() {});
            for (MockApi api : apis) {
                api.setId(null); // Reset ID to insert new
                if (api.getMatchers() != null) {
                    for (RequestMatcher m : api.getMatchers()) {
                        m.setId(null);
                        m.setMockApi(api);
                        if (m.getResponses() != null) {
                            m.getResponses().forEach(r -> r.setId(null));
                        }
                    }
                }
                if (api.getDefaultResponse() != null) api.getDefaultResponse().setId(null);
                apiRepo.save(api);
            }
        }
    }
}
