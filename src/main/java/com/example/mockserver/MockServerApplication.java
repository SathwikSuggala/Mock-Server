package com.example.mockserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.io.File;

@SpringBootApplication
@EnableAsync
@EnableScheduling
public class MockServerApplication extends SpringBootServletInitializer {
    public static void main(String[] args) {
        // Ensure the SQLite data directory exists before the connection pool starts.
        // HikariCP initializes before any @PostConstruct bean, so this must happen here.
        new File("data").mkdirs();
        SpringApplication.run(MockServerApplication.class, args);
    }
}
