package com.example.mockserver.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "app_settings")
public class AppSettings {
    @Id
    @Column(name = "setting_key", length = 255)
    private String key;

    @Column(name = "setting_value", columnDefinition = "TEXT")
    private String value;

    public AppSettings() {}
    public AppSettings(String key, String value) { this.key = key; this.value = value; }

    public String getKey() { return key; }
    public void setKey(String key) { this.key = key; }
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}
