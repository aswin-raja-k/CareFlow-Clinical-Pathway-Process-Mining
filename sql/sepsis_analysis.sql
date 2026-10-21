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

-- ============================================================
-- TODAY'S TASK: EXPECTED COUNT VALIDATION
-- Compare actual dataset counts with expected values.
-- ============================================================

SELECT
    source_rows,
    destination_rows,
    unique_cases,
    distinct_activities,
    missing_case_ids,
    missing_timestamps,
    CASE
        WHEN source_rows = 15214
         AND destination_rows = 15214
         AND unique_cases = 1050
         AND distinct_activities = 16
         AND missing_case_ids = 0
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

        (SELECT COUNT(DISTINCT NULLIF(
            TRIM(`case:concept:name`), ''
         ))
         FROM sepsis_event_log) AS unique_cases,

        (SELECT COUNT(DISTINCT NULLIF(
            TRIM(`concept:name`), ''
         ))
         FROM sepsis_event_log) AS distinct_activities,

        (SELECT COUNT(*)
         FROM sepsis_event_log
         WHERE `case:concept:name` IS NULL
            OR TRIM(`case:concept:name`) = ''
        ) AS missing_case_ids,

        (SELECT COUNT(*)
         FROM sepsis_event_log
         WHERE `time:timestamp` IS NULL
        ) AS missing_timestamps
) AS validation;


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
-- 1B. TYPED DESTINATION TABLE VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT NULLIF(TRIM(`case:concept:name`), ''))
        AS unique_cases,
    COUNT(DISTINCT NULLIF(TRIM(`concept:name`), ''))
        AS distinct_activities,
    SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
    ) AS missing_case_id_rows,
    SUM(`time:timestamp` IS NULL) AS missing_timestamps
FROM sepsis_event_log;


-- Compare raw source and typed destination row counts.
SELECT
    (SELECT COUNT(*) FROM sepsis_raw_import) AS source_rows,
    (SELECT COUNT(*) FROM sepsis_event_log) AS destination_rows,
    (SELECT COUNT(*) FROM sepsis_raw_import)
      - (SELECT COUNT(*) FROM sepsis_event_log) AS row_difference;
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
        `case:concept:name` AS case_id,
        COUNT(*) AS events_per_case
    FROM sepsis_event_log
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
      AND `time:timestamp` IS NOT NULL
    GROUP BY `case:concept:name`
) AS case_durations;


-- ============================================================
-- KPI 3. AVERAGE TIME BETWEEN CONSECUTIVE EVENTS
-- Uses LAG() to compare each event with the preceding event
-- within the same case. Requires MySQL 8.0 or later.
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


WITH activity_repeats AS (
    SELECT
        `case:concept:name` AS case_id,
        `concept:name` AS activity_name,
        COUNT(*) AS activity_count
    FROM sepsis_event_log
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
    SUM(has_repeated_activity) AS repeated_activity_cases,
    COUNT(*) AS total_cases,
    ROUND(
        100.0 * SUM(has_repeated_activity)
        / NULLIF(COUNT(*), 0),
        5
    ) AS pct_cases_with_repeated_activities
FROM case_repeat_flags;


-- ============================================================
-- KPI 5. PERCENTAGE OF CASES WITH A RETURN TO ER
-- Formula:
-- Cases containing "Return ER" / all valid cases * 100
-- ============================================================


SELECT
    COUNT(
        DISTINCT CASE
            WHEN TRIM(`concept:name`) = 'Return ER'
            THEN TRIM(`case:concept:name`)
        END
    ) AS cases_with_return_er,

    COUNT(
        DISTINCT NULLIF(TRIM(`case:concept:name`), '')
    ) AS total_cases,

    ROUND(
        100.0 * COUNT(
            DISTINCT CASE
                WHEN TRIM(`concept:name`) = 'Return ER'
                THEN TRIM(`case:concept:name`)
            END
        )
        / NULLIF(
            COUNT(
                DISTINCT NULLIF(TRIM(`case:concept:name`), '')
            ),
            0
        ),
        5
    ) AS pct_cases_with_return_er
FROM sepsis_event_log;




-- ============================================================
-- DATA-QUALITY NOTES
--
-- Source rows: 15214
-- Destination rows: 15214
-- Row difference: 0
-- Unique cases: 1050
-- Distinct activities: 16
-- Missing case IDs: 0
-- Missing timestamps: 0
-- Unparseable source timestamps: 0
-- Source timestamps include the +00:00 UTC offset.
-- Destination DATETIME values retain the date/time portion
-- and are interpreted as UTC.
-- Clinical measurement columns contain missing values.
-- Duplicate groups must be checked against the raw source.
-- No duplicate records were deleted.
-- ============================================================

-- END OF CAREFLOW SEPSIS EVENT LOG ANALYSIS