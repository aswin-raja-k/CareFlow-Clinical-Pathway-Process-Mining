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
**Report Date:** 07 November 2026

---

## 1. Introduction

CareFlow focuses on understanding clinical workflows through process mining techniques. This report documents the data validation and SQL-based analysis performed on the Sepsis event log.

MySQL was used to examine data quality, validate case identifiers, identify duplicate records, inspect timestamp information, and calculate five important Key Performance Indicators (KPIs).

The main activities covered in this analysis include:

1. Comparing source and destination record counts.
2. Identifying invalid and placeholder case identifiers.
3. Examining missing timestamps and duplicate entries.
4. Applying consistent filtering conditions across KPI queries.
5. Calculating five process-related KPIs.
6. Executing all five KPI queries in MySQL Workbench.
7. Recording actual SQL execution outputs.
8. Verifying database table structures and timestamp storage.
9. Maintaining SQL execution and validation documentation.
10. Documenting the analysis findings and technical considerations.

This report presents the recorded validation findings, successfully executed KPI results, database schema observations, timestamp details, and supporting analysis documentation.

---

## 2. Dataset Information and Validation

The Sepsis dataset was imported into the `careflow` database.

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

Both tables contain the same number of records, indicating consistency in their overall row counts. However, matching row counts alone do not establish that every imported field is identical.

Out of 15,214 records, 24 contain the placeholder case identifier `NA`. After excluding these records, 15,190 valid events remain for analysis, representing 1,049 valid cases.

### 2.2 Invalid Case Identifier Handling

Before performing KPI calculations, invalid case identifiers are excluded from the analysis.

The filtering process considers the following values invalid:

- SQL NULL values.
- Empty identifiers.
- Identifiers containing only spaces.
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

This condition removes incomplete identifiers and placeholder values from the valid case population.

The validation results recorded zero SQL NULL identifiers, zero blank identifiers, and 24 placeholder identifiers.

Therefore, the resulting analysis population consists of 1,049 valid cases and 15,190 valid events.

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
5. Exact timestamp conversion and timezone preservation have not been independently established.

KPI 2 requires timestamps to calculate the difference between the first and last events of a case.

KPI 3 requires timestamps to calculate the difference between consecutive activities.

Therefore, these calculations represent differences based on the stored destination timestamps. They should not automatically be interpreted as actual clinical durations or waiting times.

The inspected raw and destination examples are not a row-by-row comparison of matching records. Consequently, exact preservation of the original timestamp values and timezone interpretation has not been established.

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

### 3.1 Duplicate Record Handling

The identified duplicate group was retained in the dataset for examination.

Repeated activities may sometimes represent valid events within a clinical process. Removing such records without understanding their meaning could affect the accuracy of process analysis.

Therefore, the identified duplicate remains documented rather than being automatically treated as an import error.

---

## 4. SQL-Based KPI Analysis

Five KPIs were selected to understand the structure and execution of the clinical event log.

The calculations cover event frequency, case duration, consecutive-event intervals, repeated activities, and cases containing the `Return ER` activity.

All five KPI queries were successfully executed in MySQL Workbench on 04 November 2026. The following sections document the recorded SQL execution outputs.

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

**Verification Status:** Successfully executed. Actual output: `14.4805`.

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

**Verification Status:** SQL execution successful. Actual output: `41017.73047`. Timestamp interpretation is subject to the documented limitation.

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

**Verification Status:** SQL execution successful. Actual output: `3042.75506`. Timestamp interpretation is subject to the documented limitation.

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

**Verification Status:** Successfully executed. Actual outputs: `743`, `1049`, `70.83`.

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

**Verification Status:** Successfully executed. Actual outputs: `294`, `1049`, `28.03`.

---

## 5. Consolidated KPI Results

The following table summarizes the KPI results obtained through MySQL Workbench execution on 04 November 2026.

| No. | Key Performance Indicator | Actual SQL Output | Execution Status |
|---|---|---:|---|
| 1 | Average events per case | 14.4805 | Successfully executed |
| 2 | Average case duration | 41,017.73047 minutes | Successfully executed |
| 3 | Average time between events | 3,042.75506 minutes | Successfully executed |
| 4 | Cases with repeated activities | 743 (70.83%) | Successfully executed |
| 5 | Cases containing Return ER | 294 (28.03%) | Successfully executed |

The common analysis population consists of 1,049 valid cases containing 15,190 valid event records.

All five KPI outputs were successfully returned by their respective SQL queries.

The timestamp-related interpretation of KPI 2 and KPI 3 remains subject to the documented data storage limitations.

---

## 6. SQL Implementation and Maintainability

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
- SQL queries are maintained in a centralized script for easier execution and review.
- Query results are documented in this report for reference.
- Calculation methods and data limitations are recorded alongside the results.

These practices improve the maintainability and clarity of the SQL analysis.

---

## 7. Supporting Evidence

Screenshots of the validation and KPI execution outputs are organized in the `evidence/` directory and its supporting subfolders.

The following filenames are used for organizing the validation and KPI evidence.

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

The five KPI execution outputs were obtained through MySQL Workbench.

The evidence structure provides an organized reference for:

- Dataset validation results.
- Invalid case identifier checks.
- Duplicate record examination.
- Individual KPI execution outputs.
- Source and destination table structures.
- Timestamp validation details.

The evidence filenames follow a numbered naming convention to make the validation and KPI outputs easier to identify and reference.

---

## 8. Database Table Structure and Schema Verification

As part of the SQL verification process, the structures of both database tables were retrieved using the `DESCRIBE` command in MySQL Workbench on 05 November 2026.

The commands used were:

```sql
USE careflow;

DESCRIBE sepsis_raw_import;

DESCRIBE sepsis_event_log;
```

The `DESCRIBE` command provides information about:

- Column names.
- Data types.
- NULL permissions.
- Key information.
- Default values.
- Extra attributes.

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

**Schema Verification Status:** Both table structures were successfully retrieved and reviewed on 05 November 2026.

---

## 9. Data Quality and Analysis Considerations

### 9.1 Timestamp Reliability

The raw import table stores `time:timestamp` as TEXT, with inspected examples displaying a `+00:00` UTC offset.

The destination table stores the same-named column as DATETIME, which does not retain timezone metadata.

The destination timestamp verification returned:

- Earliest timestamp: 2013-11-07 08:18:29.
- Latest timestamp: 2015-06-05 12:25:11.
- Non-NULL timestamps: 15,214.

Although all destination records contain non-NULL timestamps, exact timestamp conversion and timezone preservation have not been independently established.

KPI 2 and KPI 3 therefore represent calculations based on stored destination timestamps. They should not be treated as confirmed clinical durations or waiting times.

### 9.2 Invalid Case Identifiers

The 24 records associated with the placeholder value `NA` are excluded from valid-case analysis.

This avoids grouping unrelated records under a single invalid identifier.

### 9.3 Duplicate Records

One duplicate group with one additional matching record was identified.

The record remains documented instead of being automatically deleted because repeated clinical events may represent valid process activities.

### 9.4 Consistency of KPI Calculations

All five KPI queries follow common invalid case-ID filtering rules.

Consistent filtering, grouping, and timestamp handling are important for maintaining comparable KPI results.

### 9.5 Clinical Interpretation

Repeated activities and `Return ER` occurrences are descriptive process indicators.

The `Return ER` activity count represents cases containing that event in the dataset. It must not be described as a confirmed hospital readmission rate.

Additional clinical information is required before using these measurements to draw conclusions about treatment quality, process inefficiency, readmission, or patient outcomes.

### 9.6 Python Result Comparison

This report is based on SQL validation and KPI execution in MySQL.

No comparison with synthetic Python KPI results has been performed or included in this analysis.

---

## 10. Final Summary

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

The SQL implementation maintains consistent case-ID filtering conditions, while the supporting documentation organizes the validation findings, schema observations, KPI calculations, and technical considerations.

Overall, this analysis provides a data-validation and SQL-analysis foundation for the CareFlow clinical process-mining workflow, with appropriate consideration of timestamp reliability, duplicate records, and clinical interpretation limitations.

---

**Project:** CareFlow – Clinical Pathway Process Mining  
**Module:** Sepsis Event Log SQL Analysis  
**Database:** `careflow`  
**Primary SQL Script:** `sql/sepsis_analysis.sql`  
**Documentation:** `docs/sql_validation_results.md`  
**Evidence:** `evidence/`  
**Working Branch:** `srivaishnavi-sql-analysis`  
**Report Date:** 07 November 2026

---

## 11. Reproducibility and Maintenance Notes

To maintain consistency and reliability in the CareFlow analysis, the following practices are followed:

1. Preserve the original imported dataset before performing modifications.
2. Apply consistent filtering conditions across all KPI queries.
3. Use proper timestamp ordering when calculating event sequences and time intervals.
4. Review duplicate records before deciding whether they should be removed.
5. Maintain clear documentation of SQL queries, validation results, and calculation methods.
6. Compare SQL execution outputs with the documented KPI values.
7. Organize SQL execution evidence using consistent filenames.
8. Maintain database schema information for reference.
9. Consider timestamp conversion and timezone handling when interpreting duration-based calculations.
10. Keep SQL queries organized in the designated analysis script.
11. Maintain the analysis on the designated feature branch.

These practices help improve data reliability, maintain consistency, and make the SQL analysis easier to understand, reproduce, and maintain.

---

## 12. Report Revision History

| Date | Updates |
|---|---|
| 04 November 2026 | Recorded the execution results of the five SQL KPI queries. |
| 05 November 2026 | Updated schema observations, timestamp details, and validation documentation. |
| 06 November 2026 | Improved report organization, clarified duplicate record handling, and added SQL query maintainability notes. |
| 07 November 2026 | Refined technical explanations, improved section organization, standardized terminology, and strengthened the documentation of data quality and analysis considerations. |

**Revision Note:** The updates made on 07 November 2026 are documentation improvements only. No new SQL validation results or KPI values were generated as part of this revision. Previously recorded numerical results and technical limitations remain unchanged.