
-- ============================================================
-- CareFlow: Clinical Pathway Process Mining
-- Project: Sepsis Event Log Analysis
-- Database: careflow
-- Source table: sepsis_raw_import
-- Purpose:
--   1. Summarize events, cases, and activities
--   2. Identify missing case IDs and duplicate records
--   3. Calculate five process-analysis KPIs
-- ============================================================

USE careflow;


-- ============================================================
-- 1. DATASET OVERVIEW
-- Count total event records, unique cases, and activities.
-- Blank and NULL IDs/names are excluded from distinct counts.
-- ============================================================

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT NULLIF(TRIM(`case:concept:name`), ''))
        AS unique_cases,
    COUNT(DISTINCT NULLIF(TRIM(`concept:name`), ''))
        AS distinct_activities
FROM sepsis_raw_import;


-- ============================================================
-- 2. CHECK MISSING CASE IDS
-- Count records with a NULL or blank case ID.
-- ============================================================

SELECT
    COUNT(*) AS missing_case_id_rows
FROM sepsis_raw_import
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = '';


-- Display records with missing case IDs for investigation.
SELECT
    `concept:name` AS activity_name,
    `time:timestamp` AS event_timestamp,
    `org:group` AS organization_group,
    `lifecycle:transition` AS lifecycle_transition
FROM sepsis_raw_import
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = ''
ORDER BY `time:timestamp`;


-- ============================================================
-- 3. EVENT FREQUENCY BY ACTIVITY
-- Identify the most frequently recorded activities.
-- ============================================================

SELECT
    `concept:name` AS activity_name,
    COUNT(*) AS event_count
FROM sepsis_raw_import
WHERE `concept:name` IS NOT NULL
  AND TRIM(`concept:name`) <> ''
GROUP BY `concept:name`
ORDER BY event_count DESC;


-- Display only the ten most frequent activities.
SELECT
    `concept:name` AS activity_name,
    COUNT(*) AS event_count
FROM sepsis_raw_import
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
    AVG(events_per_case) AS avg_events_per_case
FROM (
    SELECT
        `case:concept:name` AS case_id,
        COUNT(*) AS events_per_case
    FROM sepsis_raw_import
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
    GROUP BY `case:concept:name`
) AS case_event_counts;


-- ============================================================
-- KPI 2. AVERAGE CASE DURATION IN MINUTES
-- Formula: last event timestamp - first event timestamp.
-- The source timestamp may include a timezone suffix (+00:00),
-- so the first 19 characters are parsed as a MySQL DATETIME.
-- ============================================================

SELECT
    AVG(duration_minutes) AS avg_case_duration_minutes
FROM (
    SELECT
        `case:concept:name` AS case_id,
        TIMESTAMPDIFF(
            SECOND,
            MIN(
                STR_TO_DATE(
                    LEFT(CAST(`time:timestamp` AS CHAR), 19),
                    '%Y-%m-%d %H:%i:%s'
                )
            ),
            MAX(
                STR_TO_DATE(
                    LEFT(CAST(`time:timestamp` AS CHAR), 19),
                    '%Y-%m-%d %H:%i:%s'
                )
            )
        ) / 60.0 AS duration_minutes
    FROM sepsis_raw_import
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND `time:timestamp` IS NOT NULL
    GROUP BY `case:concept:name`
) AS case_durations;


-- ============================================================
-- KPI 3. AVERAGE TIME BETWEEN CONSECUTIVE EVENTS
-- Uses LAG() to compare each event with the preceding event
-- within the same case. Requires MySQL 8.0 or later.
-- ============================================================

WITH parsed_events AS (
    SELECT
        `case:concept:name` AS case_id,
        STR_TO_DATE(
            LEFT(CAST(`time:timestamp` AS CHAR), 19),
            '%Y-%m-%d %H:%i:%s'
        ) AS event_time
    FROM sepsis_raw_import
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND `time:timestamp` IS NOT NULL
),
ordered_events AS (
    SELECT
        case_id,
        event_time,
        LAG(event_time) OVER (
            PARTITION BY case_id
            ORDER BY event_time
        ) AS previous_event_time
    FROM parsed_events
)
SELECT
    AVG(
        TIMESTAMPDIFF(
            SECOND,
            previous_event_time,
            event_time
        ) / 60.0
    ) AS avg_minutes_between_events
FROM ordered_events
WHERE previous_event_time IS NOT NULL;


-- ============================================================
-- KPI 4. PERCENTAGE OF CASES WITH REPEATED ACTIVITIES
-- A case qualifies when the same activity occurs more than once.
-- Repetition may indicate rework, but does not prove an error.
-- ============================================================

WITH activity_repeats AS (
    SELECT
        `case:concept:name` AS case_id,
        `concept:name` AS activity_name,
        COUNT(*) AS activity_count
    FROM sepsis_raw_import
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND `concept:name` IS NOT NULL
      AND TRIM(`concept:name`) <> ''
    GROUP BY
        `case:concept:name`,
        `concept:name`
),
case_repeat_flags AS (
    SELECT
        case_id,
        MAX(
            CASE
                WHEN activity_count > 1 THEN 1
                ELSE 0
            END
        ) AS has_repeated_activity
    FROM activity_repeats
    GROUP BY case_id
)
SELECT
    100.0 * SUM(has_repeated_activity) / NULLIF(COUNT(*), 0)
        AS pct_cases_with_repeated_activities
FROM case_repeat_flags;


-- ============================================================
-- KPI 5. PERCENTAGE OF CASES WITH A RETURN TO ER
-- Formula:
-- Cases containing "Return ER" / all valid cases * 100
-- ============================================================

SELECT
    100.0 * COUNT(
        DISTINCT CASE
            WHEN TRIM(`concept:name`) = 'Return ER'
            THEN `case:concept:name`
        END
    ) / NULLIF(
        COUNT(
            DISTINCT NULLIF(TRIM(`case:concept:name`), '')
        ),
        0
    ) AS pct_cases_with_return_er
FROM sepsis_raw_import
WHERE `case:concept:name` IS NOT NULL
  AND TRIM(`case:concept:name`) <> '';

USE careflow;

-- Check missing case IDs
SELECT COUNT(*) AS missing_case_id_rows
FROM sepsis_raw_import
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = '';

-- Check cases containing Return ER
SELECT
    COUNT(DISTINCT CASE
        WHEN TRIM(`concept:name`) = 'Return ER'
        THEN TRIM(`case:concept:name`)
    END) AS return_er_cases,
    COUNT(DISTINCT NULLIF(TRIM(`case:concept:name`), ''))
        AS valid_cases,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN TRIM(`concept:name`) = 'Return ER'
            THEN TRIM(`case:concept:name`)
        END)
        / NULLIF(
            COUNT(DISTINCT NULLIF(TRIM(`case:concept:name`), '')),
            0
        ),
        2
    ) AS return_er_percentage
FROM sepsis_raw_import;

-- ============================================================
-- END OF CAREFLOW SEPSIS EVENT LOG ANALYSIS
-- ============================================================
