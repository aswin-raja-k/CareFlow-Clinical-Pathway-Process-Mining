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
**Report Date:** 29 October 2026

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
6. Maintaining screenshots and SQL execution evidence.
7. Preparing the analysis documentation for team review.

The report records the available validation findings, KPI results, and areas that still require final verification.

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

Although no missing timestamps were recorded in the validation results, the original timestamp format, timezone information, and data interpretation should also be considered.

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

The following values are the previously recorded results and require reconciliation with the successful MySQL Workbench screenshots before final confirmation.

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

The calculated average is approximately 14.48 events per case. This indicates the average number of recorded activities associated with each valid case in the dataset.

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

The recorded average case duration is approximately 28.48 days.

This value represents the difference between the earliest and latest stored timestamps for each case. It should not automatically be considered the actual patient treatment duration because the validity and meaning of the timestamps must first be established.

**Verification:** The successful KPI 2 execution screenshot must be checked to ensure that it contains the calculated result rather than the earlier `ONLY_FULL_GROUP_BY` error.

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

The previously recorded average interval is approximately 50.71 hours.

It represents the average difference between consecutive event timestamps. It should be interpreted as a timestamp-based measurement rather than a confirmed clinical waiting-time value.

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

The analysis indicates that 743 cases contain repeated activities, accounting for approximately 70.83% of valid cases.

These repetitions can represent recurring clinical activities, repeated assessments, or other workflow patterns. Their presence alone does not indicate an error or unnecessary process step.

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

A total of 294 valid cases contain the `Return ER` activity, representing approximately 28.03% of all valid cases.

This KPI identifies the occurrence of a particular activity in the event log. It should not be directly interpreted as a clinical readmission rate or an indication of patient outcomes.

## 5. Consolidated KPI Results

The following table provides an overview of all five previously recorded KPI results.

| No. | Key Performance Indicator | Recorded Result |
|---|---|---:|
| 1 | Average events per case | 14.4805 |
| 2 | Average case duration | 41,017.73047 minutes |
| 3 | Average time between events | 3,042.75506 minutes |
| 4 | Cases with repeated activities | 743 (70.83%) |
| 5 | Cases containing Return ER | 294 (28.03%) |

The intended common population for these KPIs is 1,049 valid cases, containing 15,190 valid event records.

The reported results should be compared with the corresponding successful SQL execution outputs before final approval.

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

Screenshots of the validation and KPI execution outputs are organized in the `evidence/` directory.

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

These screenshots provide supporting material for reviewing the SQL validation and KPI calculations.

The following checks are necessary before considering the evidence complete:

- Verify that all five screenshots show successful query executions.
- Compare each displayed KPI result with this report.
- Confirm that KPI 2 does not contain the earlier SQL execution error.
- Ensure that the screenshots correspond to the current SQL implementation.
- Replace incorrect or unsuccessful screenshots when necessary.
- Retain valid existing evidence.

## 8. Work Verification Status

The following table separates recorded completed activities from items that still require confirmation.

| Activity | Current Status |
|---|---|
| Source and destination row-count validation | Recorded as completed |
| Invalid case-ID identification | Recorded as completed |
| Common filtering conditions | Documented in SQL |
| Five KPI queries | Reported as executed |
| KPI values compared with screenshots | Requires confirmation |
| Successful KPI 2 screenshot | Requires confirmation |
| Final SQL report review | Pending final review |
| Git commit and push | Requires confirmation |

The final report should be considered complete only after the execution evidence and recorded results have been reconciled.

## 9. Limitations and Important Considerations

### 9.1 Timestamp Reliability

The dataset timestamps may have been randomized or modified. Consequently, calculated durations and event intervals represent the stored timestamp values.

They should not be treated as actual clinical durations or waiting times without confirming the original timestamp information.

### 9.2 Invalid Case Identifiers

The 24 records associated with the placeholder value `NA` are excluded from valid-case analysis.

This avoids grouping unrelated records under a single invalid identifier.

### 9.3 Duplicate Records

One duplicate group with one additional matching record was identified.

The record remains documented for investigation rather than being automatically deleted.

### 9.4 Consistency of KPI Calculations

All five KPI queries should follow the same invalid case-ID filtering rules.

Any differences in filtering, grouping, or timestamp handling may affect the final results.

### 9.5 Evidence Verification

The values in the report must correspond to successful MySQL Workbench outputs.

Previously recorded values should not be described as newly verified unless the relevant execution evidence has been checked.

### 9.6 Python Result Comparison

This report does not include a comparison with the existing synthetic Python KPI results.

A comparison should only be performed when both implementations use the same dataset, filtering conditions, timestamp handling, and calculation definitions.

### 9.7 Clinical Interpretation

Repeated activities and `Return ER` occurrences are descriptive process indicators.

Additional clinical information is required before using these measurements to draw conclusions about treatment quality, process inefficiency, readmission, or patient outcomes.

## 10. Final Summary

The CareFlow Sepsis event log analysis was performed using MySQL and the `careflow` database.

The validation results recorded 15,214 source records and 15,214 destination records. Among these, 24 records contained the invalid placeholder identifier `NA`.

After excluding these records, the analysis population consisted of 15,190 events and 1,049 valid cases.

Five KPIs were included to examine event frequency, case duration, intervals between consecutive activities, repeated activities, and the occurrence of `Return ER`.

The SQL implementation maintains common case-ID filtering conditions, while the supporting screenshots provide evidence of the validation and KPI calculations.

Final reconciliation of the recorded results with the successful MySQL Workbench screenshots and completion of the repository checks remain necessary.

Overall, this analysis provides a data-validation and SQL-analysis foundation for the CareFlow clinical process-mining workflow, with appropriate consideration of timestamp reliability, duplicate records, and interpretation limitations.

---

**Project:** CareFlow – Clinical Pathway Process Mining  
**Module:** Sepsis Event Log SQL Analysis  
**Database:** `careflow`  
**Primary SQL Script:** `sql/sepsis_analysis.sql`  
**Documentation:** `docs/sql_validation_results.md`  
**Evidence:** `evidence/`  
**Working Branch:** `srivaishnavi-sql-analysis`  
**Report Date:** 29 October 2026