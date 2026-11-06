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
**Report Date:** 06 November 2026

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
8. Verifying database table structures and timestamp storage.
9. Maintaining screenshots and SQL execution evidence.
10. Preparing the analysis documentation for final team review.

This report documents the recorded validation findings, successfully executed KPI results, database schema verification, timestamp observations, supporting evidence requirements, and remaining verification activities.

---

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

During database schema verification, the timestamp column was identified in both tables as `time:timestamp`.

However, the storage data types differ between the source and destination tables.

| Table | Timestamp Column | Data Type |
|---|---|---|
| `sepsis_raw_import` | `time:timestamp` | TEXT |
| `sepsis_event_log` | `time:timestamp` | DATETIME |

The raw import table stores timestamp values as TEXT.

An inspected example from the raw table is:

```text
2014-10-22 11:15:41+00:00
```

The displayed value contains a UTC offset (`+00:00`).

The destination table stores timestamps using the DATETIME data type.

An inspected example from the destination table is:

```text
2013-11-07 08:18:29
```

The destination timestamp verification returned the following results:

| Verification Metric | Result |
|---|---|
| Timestamp column | `time:timestamp` |
| Data type | DATETIME |
| Earliest timestamp | 2013-11-07 08:18:29 |
| Latest timestamp | 2015-06-05 12:25:11 |
| Non-NULL timestamps | 15,214 |

All 15,214 destination records contain non-NULL timestamps according to the executed validation query.

**Timestamp Observations:**

1. The source table stores timestamps as TEXT with a displayed UTC offset.
2. The destination table stores timestamps as DATETIME without timezone metadata.
3. The destination timestamp column contains 15,214 non-NULL values.
4. The timestamp range in the destination table extends from November 2013 to June 2015.
5. Exact timestamp conversion and timezone preservation have not yet been independently established.

KPI 2 requires timestamps to calculate the difference between the first and last events of a case.

KPI 3 requires timestamps to calculate the difference between consecutive activities.

Therefore, these calculations represent differences based on the stored destination timestamps. They should not automatically be interpreted as actual clinical durations or waiting times.

The raw and destination sample outputs inspected so far are not a row-by-row comparison of matching records. Further verification is required to establish whether timestamp conversion preserved the original time values and timezone interpretation.

---

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

### 3.1 Duplicate Record Handling

The identified duplicate group was retained in the dataset for further investigation.

No records were deleted during this analysis because repeated clinical events may represent valid process activities. Domain-level verification is required before deciding whether a record should be removed.

---

## 4. SQL-Based KPI Analysis

Five KPIs were selected to understand the structure and execution of the clinical event log.

The calculations cover event frequency, case duration, consecutive-event intervals, repeated activities, and cases containing the `Return ER` activity.

All five KPI queries were executed successfully in MySQL Workbench on 04 November 2026. The results below represent the recorded SQL execution outputs.

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

This value represents the average difference between the first and last stored timestamps for each case.

However, the source timestamp is stored as TEXT with a displayed UTC offset, whereas the destination timestamp is stored as DATETIME without timezone metadata.

Therefore, exact timezone preservation and timestamp conversion have not yet been independently confirmed.

This value should be interpreted as a stored timestamp-based calculation rather than confirmed patient treatment duration.

**Verification Status:** SQL execution successful. Actual output: `41017.73047`. Timestamp interpretation remains subject to the documented limitation.

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

It represents the average difference between consecutive event timestamps.

Since timestamp conversion and timezone preservation have not yet been independently established, this value should be interpreted as a timestamp-based measurement rather than a confirmed clinical waiting-time value.

**Verification Status:** SQL execution successful. Actual output: `3042.75506`. Timestamp interpretation remains subject to the documented limitation.

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

This KPI identifies the occurrence of a particular activity in the event log.

It must not be interpreted as a confirmed hospital readmission rate or an indication of patient outcomes.

**Verification Status:** Executed successfully. Actual output: `294`, `1049`, `28.03`.

---

## 5. Consolidated KPI Results

The following table provides the recorded KPI results obtained through MySQL Workbench execution on 04 November 2026.

| No. | Key Performance Indicator | Actual SQL Output | Status |
|---|---|---:|---|
| 1 | Average events per case | 14.4805 | SQL output recorded |
| 2 | Average case duration | 41,017.73047 minutes | SQL output recorded; timestamp limitation applies |
| 3 | Average time between events | 3,042.75506 minutes | SQL output recorded; timestamp limitation applies |
| 4 | Cases with repeated activities | 743 (70.83%) | SQL output recorded |
| 5 | Cases containing Return ER | 294 (28.03%) | SQL output recorded |

The common analysis population consists of 1,049 valid cases containing 15,190 valid event records.

All five KPI outputs were successfully returned by their respective SQL queries.

The recorded KPI values remain the documented results. Final screenshot-to-query reconciliation is part of the remaining evidence verification activity.

---

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

### 6.1 SQL Query Maintainability

The SQL analysis script is organized to improve readability, consistency, and reproducibility.

- Validation queries and KPI queries are maintained separately for easier review.
- Consistent filtering conditions are applied to exclude invalid case identifiers.
- The `LAG()` window function is used to identify consecutive event timestamps for time-gap analysis.
- The SQL queries are maintained in a single script, `sql/sepsis_analysis.sql`, for review and future execution.
- Query results are documented in this report for reference and verification.

These practices improve the maintainability and clarity of the SQL analysis.

---

## 7. Supporting Evidence

Screenshots of the validation and KPI execution outputs are maintained in the `evidence/` directory and its supporting subfolders.

The following filenames are used for organizing the validation and KPI evidence:

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
| `10_raw_import_schema.png` | Raw import table structure |
| `11_event_log_schema.png` | Destination event log table structure |
| `12_timestamp_verification.png` | Timestamp verification results |

The five KPI execution outputs have been obtained through MySQL Workbench.

The following evidence verification activities are required:

- Check all five KPI screenshots against their latest SQL queries.
- Confirm that the displayed results match the values documented in this report.
- Ensure that each screenshot displays the successful query output.
- Confirm that KPI 2 displays the calculated result rather than the earlier `ONLY_FULL_GROUP_BY` error.
- Ensure that the screenshots correspond to the current SQL implementation.
- Retain valid existing validation screenshots.
- Save both database schema outputs.
- Save the timestamp verification results.

The schema and timestamp outputs have been inspected. Their screenshots must be saved and confirmed in the evidence folder.

The presence and correctness of all evidence files must be checked before marking the evidence section complete.

---

## 8. Database Table Structure Sharing and Schema Verification

As part of the final SQL verification task, the structures of both database tables were retrieved using the `DESCRIBE` command in MySQL Workbench on 05 November 2026.

The commands used were:

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

### 8.1 Raw Import Table – `sepsis_raw_import`

The schema verification returned the following observations:

- Contains 32 columns.
- `MyUnknownColumn` is stored as `INT`.
- Most imported fields are stored as `TEXT`.
- `time:timestamp` is stored as `TEXT`.
- `case:concept:name` is stored as `TEXT`.
- The timestamp and case identifier columns allow NULL values.

### 8.2 Destination Table – `sepsis_event_log`

The schema verification returned the following observations:

- Contains 32 columns, including `event_id`.
- `event_id` is a `BIGINT` primary key with `AUTO_INCREMENT`.
- Boolean-like fields are stored as `TINYINT(1)`.
- `Age` is stored as `DECIMAL(5,2)`.
- `Leucocytes`, `CRP`, and `LacticAcid` are stored as `DECIMAL(10,2)`.
- `concept:name` is stored as `VARCHAR(100)`.
- `case:concept:name` is stored as `VARCHAR(50)`.
- `time:timestamp` is stored as `DATETIME`.
- Indexes are present on `concept:name`, `case:concept:name`, and `time:timestamp`.

### 8.3 Schema Comparison

| Attribute | `sepsis_raw_import` | `sepsis_event_log` |
|---|---|---|
| Number of columns | 32 | 32 |
| `time:timestamp` | TEXT | DATETIME |
| `case:concept:name` | TEXT | VARCHAR(50) |
| `concept:name` | TEXT | VARCHAR(100) |
| `event_id` | Not present | BIGINT primary key, AUTO_INCREMENT |
| Boolean-like fields | TEXT | TINYINT(1) |
| Numerical measurements | TEXT | DECIMAL |

The schema comparison shows that the destination table uses more specific data types than the raw import table.

This documents the structural transformation between the two tables. However, the schema alone does not establish whether every field was converted without loss or whether timezone information was preserved.

**Schema Verification Status:** Both table structures successfully retrieved and reviewed on 05 November 2026.

**Sharing Status:** Pending confirmation.

The complete schema outputs must be shared with Prasuna and the team through the team's usual communication channel or the relevant GitHub discussion.

---

## 9. Work Verification Status

The following table separates completed activities from the remaining tasks for Issue #10.

| Activity | Current Status |
|---|---|
| Source and destination row-count validation | Previously verified |
| Invalid case-ID identification | Previously verified |
| Common filtering conditions | Documented in SQL |
| KPI 1 execution | Successfully executed |
| KPI 2 execution | Successfully executed; timestamp limitation documented |
| KPI 3 execution | Successfully executed; timestamp limitation documented |
| KPI 4 execution | Successfully executed |
| KPI 5 execution | Successfully executed |
| KPI outputs recorded in report | Updated |
| Database table structure retrieval | Completed on 05 November 2026 |
| Timestamp column and data type identification | Completed |
| Destination timestamp range and NULL verification | Completed |
| Exact timestamp conversion verification | Pending |
| Five KPI screenshot verification against latest SQL | Pending |
| Schema screenshots saved in evidence | Pending confirmation |
| Timestamp verification screenshot saved | Pending confirmation |
| Screenshot and report reconciliation | Pending |
| Table details shared with Prasuna | Pending confirmation |
| Final SQL report review | In progress |
| Git commit and push | Pending |
| Issue #10 team review | Pending |

The final report should be considered complete only after the remaining evidence, communication, and repository activities have been completed.

---

## 10. Limitations and Important Considerations

### 10.1 Timestamp Reliability

The raw import table stores `time:timestamp` as TEXT, with inspected examples displaying a `+00:00` UTC offset.

The destination table stores the same-named column as DATETIME, which does not retain timezone metadata.

The destination timestamp verification returned:

- Earliest timestamp: 2013-11-07 08:18:29
- Latest timestamp: 2015-06-05 12:25:11
- Non-NULL timestamps: 15,214

Although all destination records contain non-NULL timestamps, exact timestamp conversion and timezone preservation have not yet been independently established.

KPI 2 and KPI 3 therefore represent calculations based on the stored destination timestamps. They should not be treated as confirmed clinical durations or waiting times.

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

The five KPI queries have returned their recorded results. However, the corresponding screenshots must be checked against the latest SQL queries before the evidence submission is considered complete.

### 10.6 Python Result Comparison

This report is based on SQL validation and KPI execution in MySQL.

No comparison with the synthetic Python KPI results has been performed or included in this analysis.

### 10.7 Clinical Interpretation

Repeated activities and `Return ER` occurrences are descriptive process indicators.

The `Return ER` activity count represents cases containing that event in the dataset. It must not be described as a confirmed hospital readmission rate.

Additional clinical information is required before using these measurements to draw conclusions about treatment quality, process inefficiency, readmission, or patient outcomes.

---

## 11. Final Summary

The CareFlow Sepsis event log analysis was performed using MySQL and the `careflow` database.

The validation results recorded 15,214 source records and 15,214 destination records. Among these, 24 records contained the invalid placeholder identifier `NA`.

After excluding these records, the analysis population consisted of 15,190 events and 1,049 valid cases.

Five KPIs were successfully executed in MySQL Workbench on 04 November 2026.

The recorded results are:

1. Average events per case: 14.4805.
2. Average case duration: 41,017.73047 minutes.
3. Average time between events: 3,042.75506 minutes.
4. Cases with repeated activities: 743 (70.83%).
5. Cases containing Return ER: 294 (28.03%).

On 05 November 2026, both database table structures were retrieved and reviewed.

The schema verification identified differences between the raw import and destination table data types. In particular, `time:timestamp` is stored as TEXT in the raw table and DATETIME in the destination table.

The destination timestamp verification returned 15,214 non-NULL values, with timestamps ranging from 2013-11-07 08:18:29 to 2015-06-05 12:25:11.

However, exact timestamp conversion and timezone preservation remain unverified. Therefore, KPI 2 and KPI 3 must be interpreted as stored timestamp-based calculations rather than confirmed clinical durations or waiting times.

The SQL implementation maintains common case-ID filtering conditions, while the supporting screenshots provide evidence of the validation and KPI calculations.

The remaining activities include:

- Verifying all five KPI screenshots against the latest SQL queries.
- Saving and confirming both database schema screenshots.
- Saving timestamp verification evidence.
- Completing timestamp conversion verification.
- Sharing the database table structures with Prasuna.
- Completing the final report review.
- Committing and pushing the changes to the working branch.

Issue #10 will remain open until the results are reviewed by the team. No changes will be merged into `main` as part of this task.

Overall, this analysis provides a data-validation and SQL-analysis foundation for the CareFlow clinical process-mining workflow, with appropriate consideration of timestamp reliability, duplicate records, and interpretation limitations.

---

**Project:** CareFlow – Clinical Pathway Process Mining  
**Module:** Sepsis Event Log SQL Analysis  
**Database:** `careflow`  
**Primary SQL Script:** `sql/sepsis_analysis.sql`  
**Documentation:** `docs/sql_validation_results.md`  
**Evidence:** `evidence/`  
**Working Branch:** `srivaishnavi-sql-analysis`  
**Report Date:** 06 November 2026

---

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
9. Verify timestamp conversion and timezone handling before making clinical interpretations.
10. Commit and push the completed changes to the designated feature branch.
11. Keep Issue #10 open until the final results are reviewed.

These practices help improve data reliability, maintain consistency, and make the SQL analysis easier to understand, reproduce, and maintain.

---

## 13. Report Revision History

| Date | Updates |
|---|---|
| 04 November 2026 | Recorded the execution results of the five SQL KPI queries. |
| 05 November 2026 | Updated schema observations, timestamp details, and validation documentation. |
| 06 November 2026 | Improved report organization, clarified duplicate record handling, and added SQL query maintainability notes. |

**Revision Note:** The updates made on 06 November 2026 are documentation improvements only. No new SQL validation results or KPI values were generated as part of this revision. Previously identified pending tasks and limitations remain unchanged.