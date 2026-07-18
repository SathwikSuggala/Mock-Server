package com.example.mockserver.service;

import com.example.mockserver.entity.AppSettings;
import com.example.mockserver.repository.AppSettingsRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
public class SettingsService {

    private final AppSettingsRepository repo;

    public SettingsService(AppSettingsRepository repo) {
        this.repo = repo;
    }

    @Transactional(readOnly = true)
    public Map<String, String> getAll() {
        return repo.findAll().stream().collect(Collectors.toMap(AppSettings::getKey, AppSettings::getValue));
    }

    @Transactional(readOnly = true)
    public String get(String key, String defaultValue) {
        return repo.findById(key).map(AppSettings::getValue).orElse(defaultValue);
    }

    public void set(String key, String value) {
        repo.save(new AppSettings(key, value));
    }

    public void saveAll(Map<String, String> settings) {
        settings.forEach((k, v) -> repo.save(new AppSettings(k, v)));
    }
}
