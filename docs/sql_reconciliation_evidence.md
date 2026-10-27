# SQL Reconciliation Evidence — 27 October 2026

## 1. Objective

This document records the MySQL validation results used to reconcile missing case IDs, distinct case counts, and duplicate-event checks for the CareFlow sepsis event log.

**Branch:** `prasuna-data-validation`  
**Database:** `careflow`  
**Tables:** `sepsis_raw_import` and `sepsis_event_log`  
**Evidence:** MySQL Workbench result-grid screenshots captured on 27 October 2026.

## 2. Verified SQL Results

The following results were visible in the supplied MySQL Workbench screenshots.

| Validation | `sepsis_raw_import` | `sepsis_event_log` |
|---|---:|---:|
| Total rows | 15,214 | 15,214 |
| Missing/invalid case-ID rows | 24 | 24 |
| Distinct valid case IDs | 1,049 | 1,049 |

The missing-ID query returned a grouped value displayed as `[NA]`, with a row count of 24.

The two tables have matching row counts and matching case-ID validation results in the captured output.

## 3. Case-ID Validation Query

The following query checks for NULL, blank, and common placeholder case IDs in both tables.

```sql
USE careflow;

SELECT
    'sepsis_raw_import' AS table_name,
    COUNT(*) AS total_rows,
    SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`)) IN
           ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
    ) AS missing_case_id_rows,
    COUNT(DISTINCT CASE
        WHEN `case:concept:name` IS NOT NULL
         AND TRIM(`case:concept:name`) <> ''
         AND UPPER(TRIM(`case:concept:name`)) NOT IN
             ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
        THEN TRIM(`case:concept:name`)
    END) AS distinct_valid_case_ids
FROM sepsis_raw_import

UNION ALL

SELECT
    'sepsis_event_log' AS table_name,
    COUNT(*) AS total_rows,
    SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`)) IN
           ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
    ) AS missing_case_id_rows,
    COUNT(DISTINCT CASE
        WHEN `case:concept:name` IS NOT NULL
         AND TRIM(`case:concept:name`) <> ''
         AND UPPER(TRIM(`case:concept:name`)) NOT IN
             ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
        THEN TRIM(`case:concept:name`)
    END) AS distinct_valid_case_ids
FROM sepsis_event_log;
```

**Captured result:** Both tables returned 15,214 total rows, 24 missing/invalid case-ID rows, and 1,049 distinct valid case IDs.

## 4. Missing Case-ID Details Query

```sql
SELECT
    CONCAT('[', `case:concept:name`, ']') AS case_id_value,
    LENGTH(`case:concept:name`) AS value_length,
    COUNT(*) AS row_count
FROM sepsis_raw_import
GROUP BY `case:concept:name`
HAVING `case:concept:name` IS NULL
    OR TRIM(`case:concept:name`) = ''
    OR UPPER(TRIM(`case:concept:name`)) IN
       ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?');
```

**Captured result:** The result grid displayed `[NA]`, a value length of 2, and a row count of 24. This identifies the 24 rows grouped under that displayed value. The exact underlying stored values should be interpreted using the SQL predicate and source data.

## 5. Duplicate Validation

The supplied SQL result grids showed:

| Check | Result |
|---|---:|
| Repeated case/activity/timestamp groups | 7 |
| Rows belonging to those repeated groups | 14 |
| Extra occurrences beyond one per group | 7 |
| Separate duplicate-group check | 0 groups |
| Rows in those duplicate groups | 0 |
| Extra occurrences in those duplicate groups | 0 |

Repeated case/activity/timestamp combinations are not necessarily identical full rows. The seven repeated event-key groups affect 14 rows and represent seven extra occurrences beyond one row per group.

The CSV review also found:
- Zero exact duplicate rows when all 33 columns, including the exported `Unnamed: 0` index column, were compared.
- One repeated row when the exported index column was excluded from the comparison.

These results use different comparison definitions and should not be treated as contradictory. The separate SQL duplicate-group result applies only to the columns and comparison method used in that query.

## 6. Reconciliation of Earlier Counts

An earlier SQL summary reported zero missing case IDs and 1,050 unique cases. The captured validation results from 27 October instead show 24 missing/invalid case-ID rows and 1,049 distinct valid case IDs in both tables.

The earlier counts are therefore inconsistent with the latest captured results. The latest results are documented here, using the displayed SQL validation rules. The older figures should not be used as the verified outcome unless a different counting rule is explicitly documented and justified.

## 7. Data Handling and Limitations

- No source CSV file was modified.
- No records were deleted.
- The original dataset remains unchanged.
- The SQL results above are transcribed from the supplied MySQL Workbench screenshots.
- The complete duplicate-check query and its exact comparison-column list were not fully visible in the supplied screenshots. Therefore, the separate SQL duplicate-group result cannot be independently reproduced from the screenshots alone.
- The screenshots support the displayed counts, but the underlying database import process and the equality of every source row to its destination counterpart have not been independently audited in this document.

## 8. Conclusion

The captured MySQL validation results show 15,214 rows in each table, 24 missing/invalid case-ID rows, and 1,049 distinct valid case IDs in each table. Seven repeated case/activity/timestamp groups affect 14 rows, while the separate SQL duplicate-group check returned zero groups under its specific comparison method.

The different duplicate counts reflect different validation definitions. The earlier report of zero missing IDs and 1,050 unique cases remains inconsistent with the captured 27 October results and should be treated as unresolved historical output rather than the verified result.
