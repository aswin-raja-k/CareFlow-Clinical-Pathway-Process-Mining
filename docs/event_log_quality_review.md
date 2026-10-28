# Data Validation & Quality Report

**Report date:** 15 October 2026  
**Source file:** `Sepsis Cases - Event Log.csv`  
**Scope:** Case IDs (`case:concept:name`), activity names (`concept:name`), event timestamps (`time:timestamp`), duplicate records, and within-case chronological order.  
**Change control:** Diagnostic review only. The source CSV was not modified, and no records were deleted.

## 1. Dataset overview

- **Rows:** 15,214
- **Columns:** 33 (including the exported row-index column `Unnamed: 0`)
- **Distinct non-missing case IDs:** 1,049
- **Timestamp range parsed as UTC:** 2013-11-07 08:18:29 to 2015-06-05 12:25:11

## 2. Missing-value validation

| Field | Missing values | Result |
|---|---:|---|
| Case ID (`case:concept:name`) | 24 | Issue found |
| Activity name (`concept:name`) | 0 | Pass |
| Timestamp (`time:timestamp`) | 0 | Pass |

The 24 missing case IDs are a contiguous block at zero-based source index 441–464 (the 442nd–465th data records, excluding the header). The activity names and timestamps are present, but the records cannot be safely assigned to a case based on the case ID field alone.

**Impact:** These events may be omitted from case-level summaries, sequence analysis, or process-mining results, and their correct case membership cannot be established from this column alone.

**Recommended rule:** Treat a missing case ID as a blocking data-quality issue for case-level analysis. Check the original export/source system and obtain team-lead approval before assigning IDs. Do not infer IDs only from neighboring rows.

## 3. Duplicate-record validation

The exported `Unnamed: 0` column is a row/index field rather than event content. Comparing all 33 columns literally reports no duplicates because this index differs. Excluding that export index and comparing the remaining 32 data columns identifies **one duplicate full row (one repeated extra occurrence, two matching rows)**:

- Zero-based source indices **7160 and 7161** (data records 7161 and 7162, excluding the header)
- Case ID: `ES`
- Activity: `Leucocytes`
- Timestamp: `2014-11-08 05:50:00+00:00`
- Leucocytes value: `12.6`
- Other event fields match, including organization group `B` and lifecycle transition `complete`.

The data also has **7 repeated `(case ID, activity name, timestamp)` combinations**, affecting 14 rows in total. These are not all full-row duplicates: several repeated event keys have differing event measurements or other fields. Repeated `(case ID, timestamp)` values are common in event logs and are not, by themselves, evidence of an error.

**Impact:** Counting the confirmed duplicate full row as a separate measurement may double-count that event and affect summary statistics. Automatically removing all repeated event keys could instead erase legitimate same-time observations.

**Recommended rule:** Flag exact duplicate event-content rows for review after excluding export-only index columns. Verify against the source record and team-lead approval before deduplication. Preserve repeated event keys when their content differs or when they represent valid observations.

## 4. Timestamp validation and randomized timestamps

- Missing timestamps: **0**
- Non-empty timestamps that failed parsing: **0**
- Parsed timestamps: all 15,214 values parsed successfully as timezone-aware UTC timestamps.
- Observed timestamp range: **2013-11-07 08:18:29+00:00** to **2015-06-05 12:25:11+00:00**.

**Timestamp caveat:** The task context states that timestamps were randomized. Therefore, successful parsing confirms only their syntactic validity; it does **not** establish that the timestamp values reflect actual clinical/event times or preserve real-world timing intervals. Chronology and duration-based conclusions should be treated as limited unless the timestamp randomization process and its effect on event order are documented.

**Impact:** Randomized timestamps can undermine time-to-event calculations, interval/duration analysis, and interpretations of real-world event timing. If randomization changed event order, sequence conclusions based on timestamps may also be unreliable.

**Recommended rule:** Keep the supplied timestamp values unchanged in the source dataset. Document the randomization caveat and, if true event timing is needed, request the authoritative timestamps or a documented transformation from the data owner. Do not attempt to reverse randomization by guessing.

## 5. Chronological event-order check

Using the current CSV row order, parseable timestamps were compared with the preceding timestamp within each non-missing case ID:

- Backward timestamp transitions found: **0**
- Cases with a backward transition found: **0**
- Rows with missing case IDs excluded from case-specific ordering checks: **24**

No timestamp regressions were found in the available case-grouped source-row sequence. This result must be interpreted with the randomized-timestamp caveat above: it is a check of the supplied file, not proof of the true clinical chronology. Events sharing the same timestamp are allowed by this check and do not count as backward transitions.

**Recommended rule:** Re-run chronology checks after any approved case-ID resolution. Keep the original row order and timestamps available for audit, and separately record any approved ordering or timestamp corrections. Do not reorder or alter the original CSV as part of this report task.

## 6. Recommended cleaning and governance rules

1. **Missing case IDs:** Investigate all 24 records against an authoritative source. Assign IDs only with evidence and approval; otherwise retain them as unresolved and exclude them from case-specific calculations with the exclusion documented.
2. **Exact duplicate row:** Flag the matching rows at source indices 7160 and 7161. Confirm whether one is an accidental duplicate before any removal; do not delete at this stage.
3. **Repeated event keys:** Review the 7 repeated `(case ID, activity, timestamp)` combinations. Do not treat a repeated key alone as a duplicate.
4. **Timestamps:** Validate format and timezone consistently; preserve raw values. Explicitly disclose that timestamps were randomized and avoid claims about true durations or chronology unless supported by source documentation.
5. **Audit trail:** For every approved future correction, record the row identifier, original value, proposed value, rationale, approver, and date in a separate change log.
6. **Approval gate:** Do not modify the original CSV or delete records without team-lead approval. Make approved cleaning changes to a separate derived copy, not the source file.
7. **Revalidation:** After approved changes, rerun missing-value, duplicate, timestamp parsing, and per-case ordering checks and compare results with this baseline.

## 7. Summary

The checks found **24 missing case IDs**, no missing activity names or timestamps, no timestamp parse failures, and **one exact duplicate full row when the export-only row index is excluded**. Seven repeated case/activity/timestamp combinations require contextual review rather than automatic removal. No backward timestamp transitions were found in the available per-case source-row sequence, but timestamps were randomized, so this does not validate real-world chronology. The report is diagnostic only: the original CSV remains unchanged and no records have been deleted.


## 8. Cross-Report Reconciliation and Revalidation

**Review date:** 24 October 2026

The reports `data_quality_report.md` and `event_log_quality_review.md` were compared. Their findings were reviewed against the uploaded CSV and the available output from `sepsis_analysis.sql`.

### Verified Results

- Total source rows: 15,214
- Total destination rows reported by SQL: 15,214
- Total columns in the CSV: 33, including the exported `Unnamed: 0` index column
- Distinct nonblank case IDs: 1,049
- Rows with missing or blank case IDs: 24
- Missing activity names: 0
- Missing timestamps: 0
- Non-empty timestamps that failed parsing: 0
- Exact duplicate rows across all 33 columns, including the exported index: 0
- Duplicate occurrence after excluding the exported index column: 1, consisting of two matching rows
- Repeated case/activity/timestamp combinations: 7 groups affecting 14 rows
- Backward timestamp transitions in source-row order within non-missing cases: 0

### Reconciliation Notes

The displayed SQL results support 24 missing or invalid case IDs and 1,049 distinct nonblank case IDs. An earlier SQL summary reported zero missing case IDs and 1,050 unique cases; that summary conflicts with the displayed validation results and should not be treated as the final result.

Duplicate checks depend on the columns being compared. Repeated case/activity/timestamp combinations do not necessarily mean the complete event records are duplicates. The duplicate counts above are based on the CSV review and should be interpreted according to each check's definition.

### Interpretation and Limitations

The source and destination row counts match at 15,214 rows according to the SQL output. However, matching row counts do not mean that all data-quality issues are absent.

The timestamps were reported as randomized. Therefore, the absence of backward timestamp transitions in source-row order does not establish that the events reflect actual clinical chronology.

### Recommended Actions

1. Investigate the 24 rows with missing or blank case IDs.
2. Review duplicate records and repeated event combinations before proposing any changes.
3. Do not invent missing case IDs or delete records without supporting evidence and team-lead approval.
4. Preserve the original CSV and document any approved cleaning decisions.
5. Recheck the complete SQL duplicate-query output if the SQL and CSV duplicate counts differ.

**Change control:** This review is diagnostic only. The original CSV was not modified, and no records were deleted.



Date:-  26/10/2026


## 9. SQL and Quality Report Cross-Check

### 9.1 Missing Case IDs and Distinct Cases

The CSV quality review identified 24 rows with missing case IDs and 1,049 distinct nonblank case IDs.

The existing SQL validation summary reports 0 missing case IDs and 1,050 unique cases. These results do not agree with the CSV review. The discrepancy remains unresolved because the actual SQL database results have not been independently verified against the same source CSV.

### 9.2 Duplicate Validation

The CSV review identified:

- Exact duplicate rows across all 33 columns, including the exported `Unnamed: 0` index column: 0.
- One repeated full-row occurrence when the exported index column is excluded.
- Seven repeated case/activity/timestamp combinations, affecting 14 rows.

These measures use different definitions. Repeated case/activity/timestamp combinations do not necessarily represent duplicate full records. The SQL summary available for this review does not clearly provide matching duplicate counts, so agreement with SQL cannot yet be confirmed.

### 9.3 Conclusion and Follow-up

The CSV quality findings are documented, but reconciliation with SQL remains pending. The raw CSV has not been modified, and no records have been deleted.

The team should verify the source and destination tables, missing case IDs, distinct case counts, and duplicate queries using the same dataset before marking the discrepancy as resolved.




## 10. Data Quality and SQL Reconciliation — 27 October 2026

### 10.1 Missing Case IDs and Distinct Cases

The MySQL Workbench validation query returned the following results for both `sepsis_raw_import` and `sepsis_event_log`:

| Metric | `sepsis_raw_import` | `sepsis_event_log` |
|---|---:|---:|
| Total rows | 15,214 | 15,214 |
| Missing or invalid case ID rows | 24 | 24 |
| Distinct valid case IDs | 1,049 | 1,049 |

The earlier result reporting zero missing case IDs used a different validation condition. The validation that checks NULL, blank, and configured placeholder values returned 24 invalid case-ID rows in both tables. Therefore, the zero result should not be used as the final missing-ID count.

### 10.2 Repeated Case/Activity/Timestamp Combinations

The SQL result reported:

- Repeated key groups: 7
- Rows belonging to those groups: 14
- Extra occurrences beyond one row per group: 7

These are repeated combinations of case ID, activity name, and timestamp. They are not automatically exact duplicate full rows.

### 10.3 Exact Full-Row Duplicates

The separate SQL duplicate check returned zero duplicate groups, zero rows in duplicate groups, and zero extra occurrences under the columns included in that check.

The CSV review found one repeated row when the exported `Unnamed: 0` index column was excluded from comparison, but zero exact duplicates when all 33 columns, including that index, were compared. This difference is consistent with the index column distinguishing otherwise identical records. The duplicate result must therefore be reported with its comparison method.

### 10.4 SQL Reconciliation and Limitations

The displayed SQL results show that the raw-import and event-log tables have matching row counts and matching case-ID validation counts. They do not, by themselves, prove that every field in both tables is identical.

The earlier SQL summary reporting zero missing IDs and 1,050 unique cases conflicts with the validation output shown on 27 October 2026. The displayed results from the current validation are 24 missing or invalid case-ID rows and 1,049 distinct valid case IDs in each table. The previous summary should be corrected or labelled as superseded after its query logic is reviewed.

### 10.5 Evidence and Data Handling

MySQL Workbench result grids were captured for:
- Row counts, missing/invalid case IDs, and distinct valid case IDs.
- The 24 blank case-ID rows.
- Repeated case/activity/timestamp groups.
- The separate duplicate-group check.

No raw CSV files were modified and no records were deleted as part of this review. The validation findings document the checks performed; they do not authorize changes to the source dataset.

### 10.6 Queries Used

The validation covered:
1. Row counts for `sepsis_raw_import` and `sepsis_event_log`.
2. Missing/invalid case-ID counts using NULL, blank, and configured placeholder checks.
3. Distinct valid case-ID counts.
4. Repeated `(case:concept:name, concept:name, time:timestamp)` combinations.
5. Exact duplicate full-row checks using the columns included in the duplicate comparison.

The SQL script and captured result grids should be retained as evidence alongside this report. Any additional query text should be saved in the repository only after verifying that it matches the query actually executed.



## 11. Data Quality Reconciliation — 28 October 2026

### 11.1 Case-ID Validation Results

The MySQL Workbench result screenshots supplied for this review show the following results for both `sepsis_raw_import` and `sepsis_event_log`.

| Metric | Raw import | Event log |
|---|---:|---:|
| Total rows | 15,214 | 15,214 |
| Missing or invalid case-ID rows | 24 | 24 |
| Valid case-ID rows | 15,190 | 15,190 |
| Distinct valid case IDs | 1,049 | 1,049 |

A case ID is considered invalid if it is NULL, blank or whitespace-only, or a configured placeholder after trimming and converting to uppercase: `NA`, `NAN`, `NULL`, `NONE`, `N/A`, or `?`.

The valid case-ID row count is calculated as:

`15,214 - 24 = 15,190`

Here, **15,190 valid events** means rows with valid case IDs. It does not certify every other field in those rows as valid.

The captured SQL results support 24 invalid case-ID rows and 1,049 distinct valid case IDs in each table. An older SQL summary reported zero missing IDs and 1,050 unique cases. Those figures conflict with the captured validation results and must not be treated as reconciled.

### 11.2 Duplicate Validation

The CSV review identified one repeated full event-content row when the export-only `Unnamed: 0` index column was excluded from the comparison. The matching rows were at zero-based source indices 7160 and 7161.

Comparing all 33 columns, including the exported index, reports zero exact duplicates because the index values differ.

The supplied SQL result grid separately showed:

- Repeated case/activity/timestamp groups: 7
- Rows in those groups: 14
- Extra occurrences beyond one row per group: 7
- Separate SQL duplicate-group check: 0 groups

These results measure different things. A repeated case/activity/timestamp key does not necessarily mean every event-content field is identical.

The exact SQL duplicate-check query and its full comparison-column list were not completely visible in the supplied screenshots. Therefore, the SQL result of zero duplicate groups cannot yet be confirmed as equivalent to the CSV comparison that found one repeated event-content row. This discrepancy remains unresolved.

### 11.3 Consistent Case-ID Validation Query

The following query applies the same invalid-ID rule to both tables.

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
    ) AS invalid_case_id_rows,
    COUNT(*) - SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`)) IN
           ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
    ) AS valid_case_id_rows,
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
    ) AS invalid_case_id_rows,
    COUNT(*) - SUM(
        `case:concept:name` IS NULL
        OR TRIM(`case:concept:name`) = ''
        OR UPPER(TRIM(`case:concept:name`)) IN
           ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
    ) AS valid_case_id_rows,
    COUNT(DISTINCT CASE
        WHEN `case:concept:name` IS NOT NULL
         AND TRIM(`case:concept:name`) <> ''
         AND UPPER(TRIM(`case:concept:name`)) NOT IN
             ('NA', 'NAN', 'NULL', 'NONE', 'N/A', '?')
        THEN TRIM(`case:concept:name`)
    END) AS distinct_valid_case_ids
FROM sepsis_event_log;
```

The query is included for reproducibility. The counts above are transcribed from the supplied MySQL Workbench screenshots; a fresh execution should be captured before claiming independent revalidation.

### 11.4 Status and Change Control

- Case-ID counts: consistent between both tables in the supplied SQL output.
- Valid case-ID rows: 15,190 per table, calculated from the displayed counts.
- Distinct valid cases: 1,049 per table.
- Repeated event keys: 7 groups, 14 rows, and 7 extra occurrences in the captured SQL output.
- Exact duplicate content: one repeated occurrence in the CSV review when excluding the exported index; equivalence with the separate SQL duplicate-group check remains unverified.
- Source data: no CSV values were changed and no records were deleted.
- Issue #11: keep open until the duplicate comparison is reproduced and the results are independently reviewed and approved.



### Duplicate Validation

The MySQL validation query grouped records by case ID, activity name, and timestamp. The query returned 7 repeated groups, covering 14 rows and 7 extra occurrences.

The CSV review identified one exact duplicate full row when the exported index column was excluded from comparison. These results use different definitions: the full-row check compares all data fields, while the grouped check compares only case ID, activity, and timestamp. Therefore, the counts are not directly equivalent.

The original CSV and database records were not deleted or modified during this validation. The exact-duplicate count should be confirmed against the same database table and column set before final approval.
