-- ============================================================
-- CareFlow: Clinical Pathway Process Mining
-- Project: Sepsis Event Log Analysis
-- Database: careflow
-- Raw source table: sepsis_raw_import
-- Typed analysis table: sepsis_event_log
--
-- Purpose:
--   1. Validate source and destination row counts
--   2. Check missing IDs, activity frequencies and duplicates
--   3. Calculate five process-analysis KPIs
--   4. Document data-quality and timestamp considerations
-- ============================================================

USE careflow;


-- EXPECTED COUNT VALIDATION
-- Treat placeholder case IDs as invalid.

SELECT
    source_rows,
    destination_rows,
    valid_cases,
    distinct_activities,
    invalid_case_id_rows,
    missing_timestamps,
    CASE
        WHEN source_rows = 15214
         AND destination_rows = 15214
         AND valid_cases = 1049
         AND distinct_activities = 16
         AND invalid_case_id_rows = 24
         AND missing_timestamps = 0
        THEN 'PASS'
        ELSE 'REVIEW REQUIRED'
    END AS validation_status
FROM (
    SELECT
        (SELECT COUNT(*)
         FROM sepsis_raw_import) AS source_rows,

        (SELECT COUNT(*)
         FROM sepsis_event_log) AS destination_rows,

        (SELECT COUNT(DISTINCT TRIM(`case:concept:name`))
         FROM sepsis_event_log
         WHERE `case:concept:name` IS NOT NULL
           AND TRIM(`case:concept:name`) <> ''
           AND UPPER(TRIM(`case:concept:name`))
               NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
        ) AS valid_cases,

        (SELECT COUNT(DISTINCT TRIM(`concept:name`))
         FROM sepsis_event_log
         WHERE `concept:name` IS NOT NULL
           AND TRIM(`concept:name`) <> ''
        ) AS distinct_activities,

        (SELECT COUNT(*)
         FROM sepsis_event_log
         WHERE `case:concept:name` IS NULL
            OR TRIM(`case:concept:name`) = ''
            OR UPPER(TRIM(`case:concept:name`))
               IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
        ) AS invalid_case_id_rows,

        (SELECT COUNT(*)
         FROM sepsis_event_log
         WHERE `time:timestamp` IS NULL
        ) AS missing_timestamps
) AS validation;



-- 1. DATASET OVERVIEW: RAW SOURCE

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT CASE
        WHEN `case:concept:name` IS NOT NULL
         AND TRIM(`case:concept:name`) <> ''
         AND UPPER(TRIM(`case:concept:name`))
             NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
        THEN TRIM(`case:concept:name`)
    END) AS valid_cases,
    COUNT(DISTINCT NULLIF(TRIM(`concept:name`), ''))
        AS distinct_activities,
    SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`))
           IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
    ) AS invalid_case_id_rows
FROM sepsis_raw_import;


-- 1B. TYPED DESTINATION TABLE VALIDATION

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT CASE
        WHEN `case:concept:name` IS NOT NULL
         AND TRIM(`case:concept:name`) <> ''
         AND UPPER(TRIM(`case:concept:name`))
             NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
        THEN TRIM(`case:concept:name`)
    END) AS valid_cases,
    COUNT(DISTINCT NULLIF(TRIM(`concept:name`), ''))
        AS distinct_activities,
    SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`))
           IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
    ) AS invalid_case_id_rows,
    SUM(`time:timestamp` IS NULL) AS missing_timestamps
FROM sepsis_event_log;




-- ============================================================
-- 2. CHECK MISSING CASE IDS
-- Count records with a NULL or blank case ID.
-- ============================================================

SELECT COUNT(*) AS invalid_case_id_rows
FROM sepsis_raw_import
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = ''
   OR UPPER(TRIM(`case:concept:name`))
      IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE');


-- DISPLAY INVALID CASE-ID RECORDS FOR INVESTIGATION

SELECT
    `case:concept:name` AS case_id,
    `concept:name` AS activity_name,
    `time:timestamp` AS event_timestamp,
    `org:group` AS organization_group,
    `lifecycle:transition` AS lifecycle_transition
FROM sepsis_raw_import
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = ''
   OR UPPER(TRIM(`case:concept:name`))
      IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
ORDER BY `time:timestamp`;


-- ============================================================
-- 3. EVENT FREQUENCY BY ACTIVITY
-- Identify the most frequently recorded activities.
-- Uses the typed destination table.
-- ============================================================

SELECT
    `concept:name` AS activity_name,
    COUNT(*) AS event_count
FROM sepsis_event_log
WHERE `concept:name` IS NOT NULL
  AND TRIM(`concept:name`) <> ''
GROUP BY `concept:name`
ORDER BY event_count DESC;


-- Display only the ten most frequent activities.
SELECT
    `concept:name` AS activity_name,
    COUNT(*) AS event_count
FROM sepsis_event_log
WHERE `concept:name` IS NOT NULL
  AND TRIM(`concept:name`) <> ''
GROUP BY `concept:name`
ORDER BY event_count DESC
LIMIT 10;


-- ============================================================
-- 4. CHECK DUPLICATE EVENT RECORDS
-- Compare source columns, excluding H1 (the imported row index).
-- Rows are reported only when all compared values match.
-- event_id is not used because the imported table has no
-- generated event_id column.
-- ============================================================

SELECT
    InfectionSuspected,
    `org:group`,
    DiagnosticBlood,
    DisfuncOrg,
    SIRSCritTachypnea,
    Hypotensie,
    SIRSCritHeartRate,
    Infusion,
    DiagnosticArtAstrup,
    `concept:name`,
    Age,
    DiagnosticIC,
    DiagnosticSputum,
    DiagnosticLiquor,
    DiagnosticOther,
    SIRSCriteria2OrMore,
    DiagnosticXthorax,
    SIRSCritTemperature,
    `time:timestamp`,
    DiagnosticUrinaryCulture,
    SIRSCritLeucos,
    Oligurie,
    DiagnosticLacticAcid,
    `lifecycle:transition`,
    Diagnose,
    Hypoxie,
    DiagnosticUrinarySediment,
    DiagnosticECG,
    `case:concept:name`,
    Leucocytes,
    CRP,
    LacticAcid,
    COUNT(*) AS duplicate_count
FROM sepsis_raw_import
GROUP BY
    InfectionSuspected,
    `org:group`,
    DiagnosticBlood,
    DisfuncOrg,
    SIRSCritTachypnea,
    Hypotensie,
    SIRSCritHeartRate,
    Infusion,
    DiagnosticArtAstrup,
    `concept:name`,
    Age,
    DiagnosticIC,
    DiagnosticSputum,
    DiagnosticLiquor,
    DiagnosticOther,
    SIRSCriteria2OrMore,
    DiagnosticXthorax,
    SIRSCritTemperature,
    `time:timestamp`,
    DiagnosticUrinaryCulture,
    SIRSCritLeucos,
    Oligurie,
    DiagnosticLacticAcid,
    `lifecycle:transition`,
    Diagnose,
    Hypoxie,
    DiagnosticUrinarySediment,
    DiagnosticECG,
    `case:concept:name`,
    Leucocytes,
    CRP,
    LacticAcid
HAVING COUNT(*) > 1;


-- ============================================================
-- KPI 1. AVERAGE EVENTS PER CASE
-- Formula: total events for valid cases / number of valid cases
-- ============================================================


SELECT
    ROUND(AVG(events_per_case), 5) AS avg_events_per_case
FROM (
    SELECT
        TRIM(`case:concept:name`) AS case_id,
        COUNT(*) AS events_per_case
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND UPPER(TRIM(`case:concept:name`))
          NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
    GROUP BY TRIM(`case:concept:name`)
) AS case_event_counts;


-- ============================================================
-- KPI 2. AVERAGE CASE DURATION IN MINUTES
-- Formula: last event timestamp - first event timestamp.
-- The source timestamp may include a timezone suffix (+00:00),
-- so the first 19 characters are parsed as a MySQL DATETIME.
-- Excludes NULL, blank, and placeholder case IDs.
-- ============================================================


SELECT
    ROUND(AVG(duration_minutes), 5)
        AS avg_case_duration_minutes
FROM (
    SELECT
        `case:concept:name` AS case_id,
        TIMESTAMPDIFF(
            SECOND,
            MIN(`time:timestamp`),
            MAX(`time:timestamp`)
        ) / 60.0 AS duration_minutes
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
  AND TRIM(`case:concept:name`) <> ''
  AND UPPER(TRIM(`case:concept:name`))
      NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
  AND `time:timestamp` IS NOT NULL
    GROUP BY `case:concept:name`
) AS case_durations;


-- ============================================================
-- KPI 3. AVERAGE TIME BETWEEN CONSECUTIVE EVENTS
-- Uses LAG() to compare each event with the preceding event
-- within the same valid case. Requires MySQL 8.0 or later.
-- Excludes NULL, blank, and placeholder case IDs.
-- ============================================================

WITH ordered_events AS (
    SELECT
        `case:concept:name` AS case_id,
        `time:timestamp` AS event_time,
        LAG(`time:timestamp`) OVER (
            PARTITION BY `case:concept:name`
            ORDER BY
                `time:timestamp`,
                `concept:name`,
                `lifecycle:transition`,
                `org:group`
        ) AS previous_event_time
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
  AND TRIM(`case:concept:name`) <> ''
  AND UPPER(TRIM(`case:concept:name`))
      NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
  AND `time:timestamp` IS NOT NULL
)
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                SECOND,
                previous_event_time,
                event_time
            ) / 60.0
        ),
        5
    ) AS avg_minutes_between_events
FROM ordered_events
WHERE previous_event_time IS NOT NULL;


-- ============================================================
-- KPI 4. PERCENTAGE OF CASES WITH REPEATED ACTIVITIES
-- A case qualifies when the same activity occurs more than once.
-- Repetition may indicate rework, but does not prove an error.
-- ============================================================


WITH repeated_cases AS (
    SELECT
        TRIM(`case:concept:name`) AS case_id
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND UPPER(TRIM(`case:concept:name`))
          NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
      AND `concept:name` IS NOT NULL
      AND TRIM(`concept:name`) <> ''
    GROUP BY
        TRIM(`case:concept:name`),
        TRIM(`concept:name`)
    HAVING COUNT(*) > 1
),
valid_cases AS (
    SELECT COUNT(DISTINCT TRIM(`case:concept:name`)) AS total_cases
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND UPPER(TRIM(`case:concept:name`))
          NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
)
SELECT
    COUNT(DISTINCT r.case_id) AS repeated_activity_cases,
    v.total_cases AS total_valid_cases,
    ROUND(
        100.0 * COUNT(DISTINCT r.case_id)
        / NULLIF(v.total_cases, 0),
        2
    ) AS repeated_activity_percentage
FROM repeated_cases r
CROSS JOIN valid_cases v
GROUP BY v.total_cases;




-- ============================================================
-- KPI 5. PERCENTAGE OF CASES WITH A RETURN TO ER
-- Formula:
-- Cases containing "Return ER" / all valid cases * 100
-- ============================================================


-- KPI 5: Valid cases containing Return ER

SELECT
    COUNT(DISTINCT CASE
        WHEN LOWER(TRIM(`concept:name`)) = 'return er'
        THEN TRIM(`case:concept:name`)
    END) AS return_er_cases,

    COUNT(DISTINCT TRIM(`case:concept:name`))
        AS total_valid_cases,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN LOWER(TRIM(`concept:name`)) = 'return er'
            THEN TRIM(`case:concept:name`)
        END) /
        NULLIF(COUNT(DISTINCT TRIM(`case:concept:name`)), 0),
        2
    ) AS pct_cases_with_return_er

FROM sepsis_event_log
WHERE `case:concept:name` IS NOT NULL
  AND TRIM(`case:concept:name`) <> ''
  AND UPPER(TRIM(`case:concept:name`))
      NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE');






SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT CASE
        WHEN `case:concept:name` IS NOT NULL
         AND TRIM(`case:concept:name`) <> ''
         AND UPPER(TRIM(`case:concept:name`))
             NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
        THEN TRIM(`case:concept:name`)
    END) AS valid_cases,
    COUNT(DISTINCT NULLIF(TRIM(`concept:name`), ''))
        AS distinct_activities,
    SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`))
           IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
    ) AS invalid_case_id_rows
FROM sepsis_event_log;




-- CHECK THE STORED TIMESTAMP TYPE AND FORMAT

DESCRIBE sepsis_event_log;

SELECT `time:timestamp`
FROM sepsis_event_log
WHERE `time:timestamp` IS NOT NULL
LIMIT 5;

-- ============================================================
-- DATA-QUALITY NOTES
--
-- Source rows: 15214
-- Destination rows: 15214
-- Row difference: 0
-- Invalid case-ID rows: 24
-- Valid cases: 1049
-- Valid events after excluding invalid case IDs: 15190
-- Distinct activities: 16
-- Missing timestamps: 0
-- Duplicate groups in selected source columns: 1
-- Extra duplicate rows in selected source columns: 1
-- Duplicate group requires full-row verification.
-- No records were deleted.
-- Timestamp parsing and timezone handling must be verified.
-- Repeated activities may indicate rework but do not prove error.
-- ============================================================



-- END OF CAREFLOW SEPSIS EVENT LOG ANALYSIS