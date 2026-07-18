-- =============================================================
-- Schema migration: drop stale columns + fix boolean defaults
-- Run ONCE against your mockserver database.
-- =============================================================

SET @db = DATABASE();

-- Helper: only DROP if column exists (MySQL 8.0 compatible)
-- mock_api
SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='mock_api' AND column_name='enabled'),
    'ALTER TABLE mock_api DROP COLUMN enabled', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE mock_api MODIFY COLUMN is_enabled TINYINT(1) NOT NULL DEFAULT 1;

-- request_matcher
SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='request_matcher' AND column_name='enabled'),
    'ALTER TABLE request_matcher DROP COLUMN enabled', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE request_matcher MODIFY COLUMN is_enabled TINYINT(1) NOT NULL DEFAULT 1;

-- mock_response
SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='mock_response' AND column_name='enabled'),
    'ALTER TABLE mock_response DROP COLUMN enabled', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='mock_response' AND column_name='active'),
    'ALTER TABLE mock_response DROP COLUMN active', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE mock_response
    MODIFY COLUMN is_enabled TINYINT(1) NOT NULL DEFAULT 1,
    MODIFY COLUMN is_active  TINYINT(1) NOT NULL DEFAULT 0;

-- scenario
SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='scenario' AND column_name='active'),
    'ALTER TABLE scenario DROP COLUMN active', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE scenario MODIFY COLUMN is_active TINYINT(1) NOT NULL DEFAULT 0;

-- proxy_recording
SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='proxy_recording' AND column_name='imported'),
    'ALTER TABLE proxy_recording DROP COLUMN imported', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='proxy_recording' AND column_name='timestamp'),
    'ALTER TABLE proxy_recording DROP COLUMN `timestamp`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE proxy_recording MODIFY COLUMN is_imported TINYINT(1) NOT NULL DEFAULT 0;

-- call_log
SET @sql = IF(EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema=@db AND table_name='call_log' AND column_name='timestamp'),
    'ALTER TABLE call_log DROP COLUMN `timestamp`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Verify: should return 0 rows
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name IN ('mock_api','request_matcher','mock_response','scenario','proxy_recording','call_log')
  AND column_name IN ('enabled','active','imported','timestamp');
