package com.example.mockserver.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import jakarta.annotation.PostConstruct;
import java.io.File;
import java.sql.Connection;
import java.sql.Statement;

/**
 * SQLite-specific configuration applied after the DataSource is ready.
 *
 * 1. Ensures the ./data/ directory exists before SQLite tries to open the file.
 * 2. Enables WAL (Write-Ahead Logging) mode for better concurrent read performance.
 *    WAL allows multiple readers while a write is in progress, preventing
 *    "database is locked" errors that would occur under the default journal mode.
 */
@Configuration
public class SqliteConfig {

    private static final Logger log = LoggerFactory.getLogger(SqliteConfig.class);

    @Autowired
    private DataSource dataSource;

    @PostConstruct
    public void configureSqlite() {
        // Ensure the data directory exists
        File dataDir = new File("./data");
        if (!dataDir.exists()) {
            boolean created = dataDir.mkdirs();
            if (created) {
                log.info("SQLite: created data directory at {}", dataDir.getAbsolutePath());
            }
        }

        // Enable WAL mode for better concurrent read performance
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("PRAGMA journal_mode=WAL");
            stmt.execute("PRAGMA synchronous=NORMAL");
            stmt.execute("PRAGMA foreign_keys=ON");
            log.info("SQLite: WAL mode enabled, foreign keys ON");
        } catch (Exception e) {
            log.warn("SQLite: could not apply PRAGMAs — {}", e.getMessage());
        }
    }
}
