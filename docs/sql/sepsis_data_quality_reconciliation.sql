-- Reproducible Sepsis event-log data-quality validation
-- Read-only checks for careflow; no source data is modified.
-- Invalid case ID: NULL, blank/whitespace, or configured placeholder.
-- Full-row duplicate checks exclude generated event_id.

USE careflow;

-- 1. Case-ID validity and distinct valid cases in both tables.
SELECT 'sepsis_raw_import' AS table_name, COUNT(*) AS total_rows,
 SUM(`case:concept:name` IS NULL OR TRIM(`case:concept:name`)='' OR
 UPPER(TRIM(`case:concept:name`)) IN ('NA','NAN','NULL','NONE','N/A','?')) AS invalid_case_id_rows,
 COUNT(*)-SUM(`case:concept:name` IS NULL OR TRIM(`case:concept:name`)='' OR
 UPPER(TRIM(`case:concept:name`)) IN ('NA','NAN','NULL','NONE','N/A','?')) AS valid_case_id_rows,
 COUNT(DISTINCT CASE WHEN `case:concept:name` IS NOT NULL AND TRIM(`case:concept:name`)<>''
 AND UPPER(TRIM(`case:concept:name`)) NOT IN ('NA','NAN','NULL','NONE','N/A','?')
 THEN TRIM(`case:concept:name`) END) AS distinct_valid_case_ids
FROM sepsis_raw_import
UNION ALL
SELECT 'sepsis_event_log', COUNT(*),
 SUM(`case:concept:name` IS NULL OR TRIM(`case:concept:name`)='' OR
 UPPER(TRIM(`case:concept:name`)) IN ('NA','NAN','NULL','NONE','N/A','?')),
 COUNT(*)-SUM(`case:concept:name` IS NULL OR TRIM(`case:concept:name`)='' OR
 UPPER(TRIM(`case:concept:name`)) IN ('NA','NAN','NULL','NONE','N/A','?')),
 COUNT(DISTINCT CASE WHEN `case:concept:name` IS NOT NULL AND TRIM(`case:concept:name`)<>''
 AND UPPER(TRIM(`case:concept:name`)) NOT IN ('NA','NAN','NULL','NONE','N/A','?')
 THEN TRIM(`case:concept:name`) END)
FROM sepsis_event_log;

-- 2. Repeated case/activity/timestamp keys (not full-row duplicates).
SELECT 'sepsis_raw_import' AS table_name, COUNT(*) AS repeated_key_groups,
 COALESCE(SUM(n),0) AS rows_in_repeated_groups, COALESCE(SUM(n-1),0) AS extra_occurrences
FROM (SELECT COUNT(*) n FROM sepsis_raw_import
 WHERE `case:concept:name` IS NOT NULL AND TRIM(`case:concept:name`)<>''
 AND UPPER(TRIM(`case:concept:name`)) NOT IN ('NA','NAN','NULL','NONE','N/A','?')
 GROUP BY `case:concept:name`,`concept:name`,`time` HAVING COUNT(*)>1) q
UNION ALL
SELECT 'sepsis_event_log', COUNT(*), COALESCE(SUM(n),0), COALESCE(SUM(n-1),0)
FROM (SELECT COUNT(*) n FROM sepsis_event_log
 WHERE `case:concept:name` IS NOT NULL AND TRIM(`case:concept:name`)<>''
 AND UPPER(TRIM(`case:concept:name`)) NOT IN ('NA','NAN','NULL','NONE','N/A','?')
 GROUP BY `case:concept:name`,`concept:name`,`time` HAVING COUNT(*)>1) q;

-- 3. Generate exact full-row duplicate queries using all columns except event_id.
-- Review the generated SQL, then copy and execute each generated statement.
SET SESSION group_concat_max_len=1000000;
SELECT GROUP_CONCAT(CONCAT('`',REPLACE(COLUMN_NAME,'`','``'),'`')
 ORDER BY ORDINAL_POSITION SEPARATOR ', ') INTO @raw_cols
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sepsis_raw_import' AND COLUMN_NAME<>'event_id';
SELECT GROUP_CONCAT(CONCAT('`',REPLACE(COLUMN_NAME,'`','``'),'`')
 ORDER BY ORDINAL_POSITION SEPARATOR ', ') INTO @event_cols
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sepsis_event_log' AND COLUMN_NAME<>'event_id';
SET @raw_dup_sql=CONCAT('SELECT COUNT(*) duplicate_groups, COALESCE(SUM(n),0) rows_in_duplicate_groups, ',
 'COALESCE(SUM(n-1),0) extra_occurrences FROM (SELECT COUNT(*) n FROM sepsis_raw_import GROUP BY ',
 @raw_cols,' HAVING COUNT(*)>1) d');
SET @event_dup_sql=CONCAT('SELECT COUNT(*) duplicate_groups, COALESCE(SUM(n),0) rows_in_duplicate_groups, ',
 'COALESCE(SUM(n-1),0) extra_occurrences FROM (SELECT COUNT(*) n FROM sepsis_event_log GROUP BY ',
 @event_cols,' HAVING COUNT(*)>1) d');
SELECT @raw_dup_sql AS generated_raw_duplicate_query;
SELECT @event_dup_sql AS generated_event_log_duplicate_query;

-- 4. Row counts. Equal counts do not prove row-level equality.
SELECT 'sepsis_raw_import' table_name, COUNT(*) total_rows FROM sepsis_raw_import
UNION ALL SELECT 'sepsis_event_log', COUNT(*) FROM sepsis_event_log;

-- 5. Schema mapping comparison.
SELECT r.COLUMN_NAME raw_column, e.COLUMN_NAME event_log_column,
 IF(e.COLUMN_NAME IS NULL,'MISSING FROM EVENT LOG','PRESENT IN BOTH') schema_comparison
FROM INFORMATION_SCHEMA.COLUMNS r
LEFT JOIN INFORMATION_SCHEMA.COLUMNS e
 ON e.TABLE_SCHEMA=r.TABLE_SCHEMA AND e.TABLE_NAME='sepsis_event_log' AND e.COLUMN_NAME=r.COLUMN_NAME
WHERE r.TABLE_SCHEMA=DATABASE() AND r.TABLE_NAME='sepsis_raw_import'
UNION ALL
SELECT NULL,e.COLUMN_NAME,'EXTRA IN EVENT LOG'
FROM INFORMATION_SCHEMA.COLUMNS e
LEFT JOIN INFORMATION_SCHEMA.COLUMNS r
 ON r.TABLE_SCHEMA=e.TABLE_SCHEMA AND r.TABLE_NAME='sepsis_raw_import' AND r.COLUMN_NAME=e.COLUMN_NAME
WHERE e.TABLE_SCHEMA=DATABASE() AND e.TABLE_NAME='sepsis_event_log' AND r.COLUMN_NAME IS NULL;

-- 6. NULL timestamp counts only; parsing and clinical validity are separate.
SELECT 'sepsis_raw_import' table_name, SUM(`time` IS NULL) null_timestamps
FROM sepsis_raw_import
UNION ALL SELECT 'sepsis_event_log', SUM(`time` IS NULL) FROM sepsis_event_log;

-- 7. The 31-row raw/prepared difference is NOT explained by duplicate counts alone.
-- Compare normalized row contents using a stable source-row key or a documented
-- hash of all mapped event-content columns. If no stable key exists, document it.
-- Compare actual CSV and MySQL with identical normalization rules. Never edit data.
