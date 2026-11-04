# CareFlow: Clinical Pathway Process Mining
## Sepsis Event Log – Data Validation and SQL Performance Analysis

**Project:** CareFlow – Clinical Pathway Process Mining  
**Module:** Sepsis Event Log Analysis  
**Database:** `careflow`  
**Source Table:** `sepsis_raw_import`  
**Target Table:** `sepsis_event_log`  
**SQL Script:** `sql/sepsis_analysis.sql`  
**Report File:** `docs/sql_validation_results.md`  
**Evidence Folder:** `evidence/`  
**Working Branch:** `srivaishnavi-sql-analysis`  
**Report Date:** 04 November 2026

---

## 1. Introduction

CareFlow focuses on understanding clinical workflows through process mining techniques. This report presents the data validation and SQL-based analysis performed on the Sepsis event log.

The analysis was carried out using MySQL to examine data quality, validate case identifiers, detect duplicate records, and calculate five important performance indicators.

The major activities covered in this analysis include:

1. Checking the consistency of imported and destination records.
2. Identifying invalid and placeholder case identifiers.
3. Examining missing timestamps and duplicate entries.
4. Applying consistent filtering conditions to KPI queries.
5. Calculating five process-related KPIs.
6. Executing all five KPI queries in MySQL Workbench.
7. Recording actual SQL execution outputs.
8. Maintaining screenshots and SQL execution evidence.
9. Preparing the analysis documentation for final team review.

This report documents the recorded validation findings, successfully executed KPI results, supporting evidence requirements, and remaining verification activities.

## 2. Dataset Information and Validation

The Sepsis dataset was loaded into the `careflow` database.

Two tables are used in this analysis:

- `sepsis_raw_import`: Stores the imported source records.
- `sepsis_event_log`: Contains the structured event data used for SQL analysis.

### 2.1 Validation Summary

The following results were recorded during dataset validation.

| Validation Metric | Recorded Value |
|---|---:|
| Total source records | 15,214 |
| Total destination records | 15,214 |
| Difference in row counts | 0 |
| Invalid case-ID records | 24 |
| Valid case identifiers | 1,049 |
| Valid event records | 15,190 |
| Unique activities | 16 |
| Missing timestamps | 0 |

Both tables contain the same number of records. This confirms row-count consistency, although it does not independently prove that every imported field is identical.

Out of 15,214 records, 24 records contain the placeholder case identifier `NA`. After excluding these records, 15,190 events remain for analysis, representing 1,049 valid cases.

### 2.2 Invalid Case Identifier Handling

Before performing KPI calculations, invalid case identifiers are excluded from the analysis.

The filtering process considers the following values invalid:

- SQL NULL values
- Empty identifiers
- Identifiers containing only spaces
- `NA`
- `N/A`
- `NAN`
- `NULL`
- `NONE`

The SQL condition used for filtering is:

```sql
WHERE `case:concept:name` IS NOT NULL
  AND TRIM(`case:concept:name`) <> ''
  AND UPPER(TRIM(`case:concept:name`))
      NOT IN ('NA', 'N/A', 'NAN', 'NULL', 'NONE')
```

This condition prevents incomplete identifiers and placeholder text from being treated as genuine case IDs.

The validation results recorded zero SQL NULL identifiers, zero blank identifiers, and 24 placeholder identifiers.

Therefore, the resulting analysis population consists of 1,049 valid cases.

### 2.3 Timestamp Validation

Timestamps are important for calculations involving process duration and event intervals.

The following conditions are considered:

- KPI 2 requires usable timestamps to determine the first and last events of a case.
- KPI 3 requires timestamps to calculate the difference between consecutive activities.
- Records without usable timestamps must not contribute to these time-based calculations.

No missing timestamps were recorded in the validation results. However, the original timestamp format, timezone information, and data interpretation should also be considered.

## 3. Duplicate Record Examination

Duplicate analysis was performed to identify repeated records in the event log.

The recorded results are:

| Duplicate Check | Result |
|---|---:|
| Number of duplicate groups | 1 |
| Additional duplicate records | 1 |

One duplicate group containing one additional matching record was identified.

The duplicate was documented instead of being automatically deleted.

This is important because repeated activities may sometimes be valid events within a clinical process. Further examination of the source data is necessary before deciding whether the identified record is an actual import duplication.

## 4. SQL-Based KPI Analysis

Five KPIs were selected to understand the structure and execution of the clinical event log.

The calculations cover event frequency, case duration, consecutive-event intervals, repeated activities, and cases containing the `Return ER` activity.

All five KPI queries were executed successfully in MySQL Workbench on 04 November 2026. The results below represent the actual outputs shared from the SQL execution.

### 4.1 KPI 1 – Average Events per Case

**Objective:** Determine the average number of activities recorded for each valid case.

**Calculation:**

Average Events per Case = Total Valid Events / Total Valid Cases

| Parameter | Value |
|---|---:|
| Valid event records | 15,190 |
| Valid cases | 1,049 |
| Average events per case | 14.4805 |

**Result Analysis:**

The calculated average is 14.4805 events per case.

This indicates the average number of recorded activities associated with each valid case in the dataset.

**Verification Status:** Executed successfully. Actual output: `14.4805`.

### 4.2 KPI 2 – Average Case Duration

**Objective:** Calculate the average time between the first and final recorded events of each valid case.

**Calculation:**

Case Duration = Last Event Timestamp − First Event Timestamp

The SQL analysis calculates individual case durations in minutes and then obtains their average.

Valid case identifiers are normalized using `TRIM()`, and records with missing timestamps are excluded.

| Parameter | Value |
|---|---:|
| Average duration in minutes | 41,017.73047 |
| Approximate duration in hours | 683.63 |
| Approximate duration in days | 28.48 |

**Result Analysis:**

The actual SQL output is 41,017.73047 minutes, which is approximately 683.63 hours or 28.48 days.

This value represents the difference between the earliest and latest stored timestamps for each case. It should not automatically be considered the actual patient treatment duration because the validity and meaning of the timestamps must first be established.

**Verification Status:** Executed successfully. Actual output: `41017.73047`.

### 4.3 KPI 3 – Average Time Between Consecutive Events

**Objective:** Measure the average time difference between successive activities within valid cases.

**Calculation:**

Event Interval = Current Event Timestamp − Previous Event Timestamp

The SQL implementation uses the `LAG()` window function to retrieve the timestamp of the previous event within the same case.

The first event in each case does not have a preceding event, so it is excluded from the interval calculation.

| Parameter | Value |
|---|---:|
| Average interval in minutes | 3,042.75506 |
| Approximate interval in hours | 50.71 |
| Approximate interval in days | 2.11 |

**Result Analysis:**

The actual SQL output is 3,042.75506 minutes, approximately 50.71 hours.

It represents the average difference between consecutive event timestamps. It should be interpreted as a timestamp-based measurement rather than a confirmed clinical waiting-time value.

**Verification Status:** Executed successfully. Actual output: `3042.75506`.

### 4.4 KPI 4 – Cases Containing Repeated Activities

**Objective:** Identify cases in which the same activity occurs multiple times.

| Parameter | Value |
|---|---:|
| Total valid cases | 1,049 |
| Cases with repeated activities | 743 |
| Percentage of repeated-activity cases | 70.83% |

**Calculation:**

Percentage = (Repeated Activity Cases / Total Valid Cases) × 100

**Result Analysis:**

The SQL execution returned 743 cases containing repeated activities out of 1,049 valid cases.

The percentage is 70.83%.

These repetitions can represent recurring clinical activities, repeated assessments, or other workflow patterns. Their presence alone does not indicate an error or unnecessary process step.

**Verification Status:** Executed successfully. Actual output: `743`, `1049`, `70.83`.

### 4.5 KPI 5 – Cases Containing Return ER Activity

**Objective:** Count valid cases that contain the `Return ER` activity.

| Parameter | Value |
|---|---:|
| Total valid cases | 1,049 |
| Cases containing Return ER | 294 |
| Percentage | 28.03% |

**Calculation:**

Percentage = (Cases Containing Return ER / Total Valid Cases) × 100

**Result Analysis:**

The SQL execution returned 294 valid cases containing the `Return ER` activity out of 1,049 valid cases.

The percentage is 28.03%.

This KPI identifies the occurrence of a particular activity in the event log. It should not be directly interpreted as a clinical readmission rate or an indication of patient outcomes.

**Verification Status:** Executed successfully. Actual output: `294`, `1049`, `28.03`.

## 5. Consolidated KPI Results

The following table provides the final KPI results obtained through MySQL Workbench execution on 04 November 2026.

| No. | Key Performance Indicator | Actual SQL Output | Status |
|---|---|---:|---|
| 1 | Average events per case | 14.4805 | Verified |
| 2 | Average case duration | 41,017.73047 minutes | Verified |
| 3 | Average time between events | 3,042.75506 minutes | Verified |
| 4 | Cases with repeated activities | 743 (70.83%) | Verified |
| 5 | Cases containing Return ER | 294 (28.03%) | Verified |

The common analysis population consists of 1,049 valid cases containing 15,190 valid event records.

All five KPI outputs were successfully returned by their respective SQL queries.

The current results match the previously recorded KPI values.

## 6. SQL Implementation Details

The primary analysis is maintained in `sql/sepsis_analysis.sql`.

The SQL script covers the following operations:

1. Source and destination record-count comparison.
2. Identification of invalid case identifiers.
3. Examination of missing timestamps.
4. Detection of duplicate records.
5. Calculation of average events per case.
6. Calculation of average case duration.
7. Calculation of consecutive-event intervals using `LAG()`.
8. Identification of cases with repeated activities.
9. Detection of cases containing the `Return ER` activity.

Consistent filtering is important because different case-ID conditions can produce different KPI results.

The queries exclude SQL NULL values, blank identifiers, whitespace-only values, and the specified placeholder identifiers.

For duration calculations, case identifiers are normalized before grouping. For consecutive-event analysis, activities are ordered within each case using their timestamps.

The implementation is maintained on the feature branch `srivaishnavi-sql-analysis` for review before integration into the main project.

## 7. Supporting Evidence

Screenshots of the validation and KPI execution outputs are maintained in the `evidence/` directory.

| File Name | Purpose |
|---|---|
| `01_main_validation.png` | Overall dataset validation |
| `02_invalid_case_id_records.png` | Invalid identifier results |
| `03_case_count_discrepancy.png` | Case-count comparison |
| `04_duplicate_check.png` | Duplicate record results |
| `05_kpi_avg_events_per_case.png` | First KPI execution |
| `06_kpi_avg_case_duration.png` | Second KPI execution |
| `07_kpi_avg_time_between_events.png` | Third KPI execution |
| `08_kpi_repeated_activities.png` | Fourth KPI execution |
| `09_kpi_return_er.png` | Fifth KPI execution |

The five KPI outputs have been successfully obtained through MySQL Workbench execution.

The following evidence-related activities remain necessary:

- Capture and save the five actual KPI execution screenshots.
- Ensure each screenshot displays the successful query output.
- Compare the screenshots with the corresponding KPI values in this report.
- Confirm that KPI 2 displays the calculated result rather than the earlier `ONLY_FULL_GROUP_BY` error.
- Ensure the screenshots correspond to the current SQL implementation.
- Retain valid existing validation screenshots.

The screenshot filenames listed above are the intended evidence organization. Their presence in the repository must be confirmed before marking the evidence section complete.

## 8. Database Table Structure Sharing

As part of the final SQL verification task, the column details of both database tables must be shared with Prasuna.

The following commands are used to retrieve the table structures:

```sql
USE careflow;

DESCRIBE sepsis_raw_import;

DESCRIBE sepsis_event_log;
```

The `DESCRIBE` command provides the following information:

- Column names
- Data types
- NULL permissions
- Key information
- Default values
- Extra attributes

The two table structures provide information about the original imported dataset and the structured event log used for analysis.

**Sharing Status:** Pending confirmation.

The column details should be shared with Prasuna through the team's usual communication channel or the relevant GitHub discussion.

## 9. Work Verification Status

The following table separates completed activities from the remaining tasks for Issue #10.

| Activity | Current Status |
|---|---|
| Source and destination row-count validation | Previously verified |
| Invalid case-ID identification | Previously verified |
| Common filtering conditions | Documented in SQL |
| KPI 1 execution | Verified |
| KPI 2 execution | Verified |
| KPI 3 execution | Verified |
| KPI 4 execution | Verified |
| KPI 5 execution | Verified |
| KPI outputs recorded in report | Updated |
| Five KPI screenshots | Pending capture/confirmation |
| Screenshot and report reconciliation | Pending |
| Database table structure retrieval | Pending |
| Table details shared with Prasuna | Pending |
| Final SQL report review | Pending |
| Git commit and push | Pending |
| Issue #10 review | Pending |

The final report should be considered complete only after the remaining evidence, communication, and repository activities have been completed.

## 10. Limitations and Important Considerations

### 10.1 Timestamp Reliability

The dataset timestamps may have been randomized or modified. Consequently, calculated durations and event intervals represent the stored timestamp values.

They should not be treated as actual clinical durations or waiting times without confirming the original timestamp information.

### 10.2 Invalid Case Identifiers

The 24 records associated with the placeholder value `NA` are excluded from valid-case analysis.

This avoids grouping unrelated records under a single invalid identifier.

### 10.3 Duplicate Records

One duplicate group with one additional matching record was identified.

The record remains documented for investigation rather than being automatically deleted.

### 10.4 Consistency of KPI Calculations

All five KPI queries should follow the same invalid case-ID filtering rules.

Any differences in filtering, grouping, or timestamp handling may affect the final results.

### 10.5 Evidence Verification

The values in the report must correspond to successful MySQL Workbench outputs.

The five KPI queries have returned the expected results. However, the corresponding screenshots must be saved and checked before the evidence submission is considered complete.

### 10.6 Python Result Comparison

This report does not include a comparison with the existing synthetic Python KPI results.

A comparison should only be performed when both implementations use the same dataset, filtering conditions, timestamp handling, and calculation definitions.

### 10.7 Clinical Interpretation

Repeated activities and `Return ER` occurrences are descriptive process indicators.

Additional clinical information is required before using these measurements to draw conclusions about treatment quality, process inefficiency, readmission, or patient outcomes.

## 11. Final Summary

The CareFlow Sepsis event log analysis was performed using MySQL and the `careflow` database.

The validation results recorded 15,214 source records and 15,214 destination records. Among these, 24 records contained the invalid placeholder identifier `NA`.

After excluding these records, the analysis population consisted of 15,190 events and 1,049 valid cases.

Five KPIs were successfully executed in MySQL Workbench on 04 November 2026.

The final results are:

1. Average events per case: 14.4805.
2. Average case duration: 41,017.73047 minutes.
3. Average time between events: 3,042.75506 minutes.
4. Cases with repeated activities: 743 (70.83%).
5. Cases containing Return ER: 294 (28.03%).

All five outputs match the previously recorded KPI values.

The SQL implementation maintains common case-ID filtering conditions, while the supporting screenshots are intended to provide evidence of the validation and KPI calculations.

The remaining activities include capturing and confirming the five KPI screenshots, sharing the database table structures with Prasuna, completing the final report review, and committing and pushing the changes to the working branch.

Issue #10 will remain open until the results are reviewed. No changes will be merged into `main` as part of this task.

Overall, this analysis provides a data-validation and SQL-analysis foundation for the CareFlow clinical process-mining workflow, with appropriate consideration of timestamp reliability, duplicate records, and interpretation limitations.

---

**Project:** CareFlow – Clinical Pathway Process Mining  
**Module:** Sepsis Event Log SQL Analysis  
**Database:** `careflow`  
**Primary SQL Script:** `sql/sepsis_analysis.sql`  
**Documentation:** `docs/sql_validation_results.md`  
**Evidence:** `evidence/`  
**Working Branch:** `srivaishnavi-sql-analysis`  
**Report Date:** 04 November 2026

## 12. Reproducibility and Maintenance Notes

To maintain consistency and reliability in the CareFlow analysis, the following practices should be followed:

1. Preserve the original imported dataset before performing any modifications.
2. Apply consistent filtering conditions across all KPI queries.
3. Use proper timestamp ordering when calculating event sequences and time intervals.
4. Review duplicate records before deciding whether they should be removed.
5. Maintain clear documentation of SQL queries, validation results, and calculation methods.
6. Compare SQL execution outputs with the documented KPI values.
7. Maintain screenshots of successful SQL executions.
8. Share database table structures with relevant team members.
9. Commit and push the completed changes to the designated feature branch.
10. Keep Issue #10 open until the final results are reviewed.

These practices help improve data reliability, maintain consistency, and make the SQL analysis easier to understand, reproduce, and maintain.