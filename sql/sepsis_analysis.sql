
-- CareFlow: Clinical Pathway Process Mining
-- Task: Sepsis Event Log SQL Analysis
-- Purpose: Inspect cases, events, activities, missing IDs and KPIs.

-- =====================================================
-- 1. CREATE A TABLE MATCHING THE SEPSIS EVENT LOG
-- =====================================================

CREATE TABLE IF NOT EXISTS sepsis_event_log (
    event_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    InfectionSuspected BOOLEAN NULL,
    `org:group` VARCHAR(20) NULL,
    DiagnosticBlood BOOLEAN NULL,
    DisfuncOrg BOOLEAN NULL,
    SIRSCritTachypnea BOOLEAN NULL,
    Hypotensie BOOLEAN NULL,
    SIRSCritHeartRate BOOLEAN NULL,
    Infusion BOOLEAN NULL,
    DiagnosticArtAstrup BOOLEAN NULL,
    `concept:name` VARCHAR(100) NULL,
    Age DECIMAL(5,2) NULL,
    DiagnosticIC BOOLEAN NULL,
    DiagnosticSputum BOOLEAN NULL,
    DiagnosticLiquor BOOLEAN NULL,
    DiagnosticOther BOOLEAN NULL,
    SIRSCriteria2OrMore BOOLEAN NULL,
    DiagnosticXthorax BOOLEAN NULL,
    SIRSCritTemperature BOOLEAN NULL,
    `time:timestamp` DATETIME NULL,
    DiagnosticUrinaryCulture BOOLEAN NULL,
    SIRSCritLeucos BOOLEAN NULL,
    Oligurie BOOLEAN NULL,
    DiagnosticLacticAcid BOOLEAN NULL,
    `lifecycle:transition` VARCHAR(30) NULL,
    Diagnose VARCHAR(30) NULL,
    Hypoxie BOOLEAN NULL,
    DiagnosticUrinarySediment BOOLEAN NULL,
    DiagnosticECG BOOLEAN NULL,
    `case:concept:name` VARCHAR(50) NULL,
    Leucocytes DECIMAL(10,2) NULL,
    CRP DECIMAL(10,2) NULL,
    LacticAcid DECIMAL(10,2) NULL,

    INDEX idx_case_id (`case:concept:name`),
    INDEX idx_activity (`concept:name`),
    INDEX idx_event_timestamp (`time:timestamp`)
);

-- =====================================================
-- 2. COUNT TOTAL EVENTS
-- Each row represents an event record.
-- =====================================================

SELECT COUNT(*) AS total_events
FROM sepsis_event_log;

-- =====================================================
-- 3. COUNT DISTINCT CASES
-- Ignore NULL and blank case IDs.
-- =====================================================

SELECT COUNT(DISTINCT NULLIF(TRIM(`case:concept:name`), ''))
       AS total_cases
FROM sepsis_event_log;

-- =====================================================
-- 4. COUNT DISTINCT ACTIVITIES
-- =====================================================

SELECT COUNT(DISTINCT NULLIF(TRIM(`concept:name`), ''))
       AS distinct_activities
FROM sepsis_event_log;

-- =====================================================
-- 5. IDENTIFY MISSING CASE IDS
-- =====================================================

SELECT COUNT(*) AS missing_case_id_rows
FROM sepsis_event_log
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = '';

-- Review affected records rather than inventing IDs.
SELECT event_id, `concept:name`, `time:timestamp`,
       `org:group`, `lifecycle:transition`
FROM sepsis_event_log
WHERE `case:concept:name` IS NULL
   OR TRIM(`case:concept:name`) = ''
ORDER BY `time:timestamp`;

-- =====================================================
-- 6. COUNT EVENTS FOR EACH ACTIVITY
-- =====================================================

SELECT `concept:name` AS activity_name,
       COUNT(*) AS event_count
FROM sepsis_event_log
WHERE `concept:name` IS NOT NULL
  AND TRIM(`concept:name`) <> ''
GROUP BY `concept:name`
ORDER BY event_count DESC;

-- =====================================================
-- 7. KPI 1: AVERAGE EVENTS PER CASE
-- =====================================================

SELECT AVG(events_per_case) AS avg_events_per_case
FROM (
    SELECT `case:concept:name`,
           COUNT(*) AS events_per_case
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
    GROUP BY `case:concept:name`
) AS case_event_counts;

-- =====================================================
-- 8. KPI 2: AVERAGE CASE DURATION IN MINUTES
-- Duration = last event time - first event time.
-- =====================================================

SELECT AVG(duration_minutes) AS avg_case_duration_minutes
FROM (
    SELECT `case:concept:name`,
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

-- =====================================================
-- 9. KPI 3: AVERAGE TIME BETWEEN CONSECUTIVE EVENTS
-- Requires MySQL 8.0+ because it uses LAG().
-- =====================================================

WITH ordered_events AS (
    SELECT
        `case:concept:name` AS case_id,
        `time:timestamp` AS event_time,
        LAG(`time:timestamp`) OVER (
            PARTITION BY `case:concept:name`
            ORDER BY `time:timestamp`, event_id
        ) AS previous_event_time
    FROM sepsis_event_log
    WHERE `case:concept:name` IS NOT NULL
      AND TRIM(`case:concept:name`) <> ''
      AND `time:timestamp` IS NOT NULL
)
SELECT AVG(
    TIMESTAMPDIFF(SECOND, previous_event_time, event_time) / 60.0
) AS avg_minutes_between_events
FROM ordered_events
WHERE previous_event_time IS NOT NULL;

-- =====================================================
-- 10. KPI 4: PERCENTAGE OF CASES WITH REPEATED ACTIVITIES
-- Repetition may indicate rework; it is not proof of error.
-- =====================================================

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
    GROUP BY `case:concept:name`, `concept:name`
),
case_repeat_flags AS (
    SELECT
        case_id,
        MAX(CASE WHEN activity_count > 1 THEN 1 ELSE 0 END)
            AS has_repeated_activity
    FROM activity_repeats
    GROUP BY case_id
)
SELECT
    100.0 * SUM(has_repeated_activity) / COUNT(*)
        AS pct_cases_with_repeated_activities
FROM case_repeat_flags;

-- =====================================================
-- 11. KPI 5: PERCENTAGE OF CASES WITH A RETURN TO ER
-- Uses the exact activity label "Return ER".
-- =====================================================

SELECT
    100.0 * COUNT(DISTINCT CASE
        WHEN `concept:name` = 'Return ER'
        THEN `case:concept:name`
    END)
    / NULLIF(COUNT(DISTINCT `case:concept:name`), 0)
        AS pct_cases_with_return_er
FROM sepsis_event_log
WHERE `case:concept:name` IS NOT NULL
  AND TRIM(`case:concept:name`) <> '';
