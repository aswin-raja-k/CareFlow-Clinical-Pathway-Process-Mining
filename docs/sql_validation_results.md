# CareFlow: Clinical Pathway Process Mining
## Sepsis Event Log â€” SQL Validation and KPI Analysis Report

**Project:** CareFlow â€” Clinical Pathway Process Mining
**Analysis:** Sepsis Event Log Validation and KPI Analysis
**Database:** `careflow`
**Source table:** `sepsis_raw_import`
**Analysis table:** `sepsis_event_log`
**SQL script:** `sql/sepsis_analysis.sql`
**Branch:** `srivaishnavi-sql-analysis`
**Report date:** 28 October 2026

---

## 1. Project Overview

This report documents the SQL-based validation and process analysis of the Sepsis event log for the CareFlow project. The analysis uses MySQL to validate the imported dataset, identify invalid case identifiers, examine duplicate records, and calculate five process-analysis Key Performance Indicators (KPIs).

The objective is to establish a consistent dataset for process mining and provide reproducible SQL results for team review and integration.

## 2. Dataset and Validation

The source event log was imported into the `careflow` database. The raw import table preserves the imported data, while the analysis table contains the structured columns used for SQL queries.

### Dataset validation results

| Validation check | Result |
|---|---:|
| Source rows | 15,214 |
| Destination rows | 15,214 |
| Row-count difference | 0 |
| Invalid case-ID rows | 24 |
| Valid case IDs | 1,049 |
| Valid events after case-ID filtering | 15,190 |
| Distinct activities | 16 |
| Missing timestamps | 0 |

The source and destination row counts match, confirming that all 15,214 source rows are represented in the destination table.

The analysis identified 24 events associated with the placeholder case ID `NA`. These records are excluded from the valid-case KPI calculations. The resulting analysis population contains 15,190 events across 1,049 valid cases.

### Case-ID validation rules

The KPI queries exclude case IDs that are:

- SQL `NULL` values
- Empty strings or whitespace-only strings
- `NA`
- `N/A`
- `NAN`
- `NULL` represented as text
- `NONE`

The filtering conditions use `IS NOT NULL`, `TRIM()` and `UPPER()` to handle missing and placeholder identifiers consistently. Time-based KPIs also exclude records with missing timestamps.

## 3. Duplicate Record Analysis

The duplicate-record check identified one duplicate group with one additional matching row.

| Check | Result |
|---|---:|
| Duplicate groups | 1 |
| Additional duplicate rows | 1 |

Duplicate detection is used as a data-quality check. The identified record is documented for review; the duplicate check does not automatically imply that the record should be deleted.

## 4. KPI Analysis and Results

The five KPIs below describe event frequency, case duration, event intervals, repeated activities, and emergency-department returns.

### KPI 1: Average Events per Case

**Purpose:** Measure the average number of recorded events per valid case.

**Calculation:**

Average events per case = Total valid events / Number of valid cases

| Metric | Result |
|---|---:|
| Valid events | 15,190 |
| Valid cases | 1,049 |
| Average events per case | 14.4805 |

**Interpretation:** Each valid case contains approximately 14.48 recorded events on average. This provides a measure of the event-log detail available for process analysis.

### KPI 2: Average Case Duration

**Purpose:** Calculate the average elapsed time between the first and last recorded events for each valid case.

**Calculation:**

Case duration = Last event timestamp âˆ’ First event timestamp

The duration is calculated for each valid case in minutes, after which the case durations are averaged.

| Metric | Result |
|---|---:|
| Average case duration | 41,017.73047 minutes |
| Approximate duration in hours | 683.63 hours |
| Approximate duration in days | 28.48 days |

**Interpretation:** The recorded timestamps produce an average case duration of approximately 28.48 days. This is a timestamp-derived metric and must not be interpreted as actual patient treatment duration without confirming the clinical validity of the timestamps.

### KPI 3: Average Time Between Consecutive Events

**Purpose:** Measure the average time interval between consecutive recorded events within valid cases.

**Calculation:**

Event interval = Current event timestamp âˆ’ Previous event timestamp

The SQL query uses the `LAG()` window function to obtain the preceding event timestamp within each case. The first event in each case has no preceding event and is excluded from the interval calculation.

| Metric | Result |
|---|---:|
| Average time between consecutive events | 3,042.75506 minutes |
| Approximate interval in hours | 50.71 hours |
| Approximate interval in days | 2.11 days |

**Interpretation:** The calculated average interval between consecutive events is approximately 50.71 hours. It represents the intervals derived from the recorded event timestamps, rather than a verified measure of clinical waiting time.

### KPI 4: Cases with Repeated Activities

**Purpose:** Identify valid cases in which the same activity occurs more than once.

| Metric | Result |
|---|---:|
| Valid cases | 1,049 |
| Cases with repeated activities | 743 |
| Percentage of valid cases | 70.83% |

**Calculation:**

Percentage = (Cases with repeated activities / Valid cases) Ã— 100

**Interpretation:** Approximately 70.83% of valid cases contain repeated activities. Repetition may reflect recurring clinical steps, repeated assessments, or other process patterns. The metric alone does not establish whether a repetition is unnecessary or indicates a process problem.

### KPI 5: Cases Containing `Return ER`

**Purpose:** Measure the number and proportion of valid cases containing the `Return ER` activity.

| Metric | Result |
|---|---:|
| Valid cases | 1,049 |
| Cases containing `Return ER` | 294 |
| Percentage of valid cases | 28.03% |

**Calculation:**

Percentage = (Cases containing `Return ER` / Valid cases) Ã— 100

**Interpretation:** The `Return ER` activity occurs in 294 valid cases, representing 28.03% of the valid-case population. This indicates the frequency of the activity in the event log; it does not independently establish a clinical readmission rate or patient outcome.

## 5. Summary of KPI Results

| No. | KPI | Result |
|---:|---|---:|
| 1 | Average events per case | 14.4805 |
| 2 | Average case duration | 41,017.73047 minutes |
| 3 | Average time between consecutive events | 3,042.75506 minutes |
| 4 | Cases with repeated activities | 743 (70.83%) |
| 5 | Cases containing `Return ER` | 294 (28.03%) |

All five KPIs use the valid-case population of 1,049 cases. The corresponding event-level analysis population contains 15,190 events.

## 6. SQL Implementation

The analysis is implemented in `sql/sepsis_analysis.sql` and includes the following operations:

1. Validate source and destination row counts.
2. Check invalid case identifiers and missing timestamps.
3. Inspect duplicate records and activity frequencies.
4. Calculate average events per case.
5. Calculate average case duration using event timestamps.
6. Calculate intervals between consecutive events using `LAG()`.
7. Count cases containing repeated activities.
8. Count cases containing the `Return ER` activity.

The case-ID filters exclude SQL `NULL`, blank identifiers, and the specified placeholder values. Time-based calculations require valid timestamps.

The SQL script is maintained in the `srivaishnavi-sql-analysis` branch of the project repository.

## 7. Evidence and Reproducibility

The following evidence files are maintained in the project's `evidence/` directory:

| Evidence file | Description |
|---|---|
| `01_main_validation.png` | Main dataset validation |
| `02_invalid_case_id_records.png` | Invalid case-ID records |
| `03_case_count_discrepancy.png` | Case-count comparison |
| `04_duplicate_check.png` | Duplicate-record analysis |
| `05_kpi_avg_events_per_case.png` | KPI 1 output |
| `06_kpi_avg_case_duration.png` | KPI 2 output |
| `07_kpi_avg_time_between_events.png` | KPI 3 output |
| `08_kpi_repeated_activities.png` | KPI 4 output |
| `09_kpi_return_er.png` | KPI 5 output |

The SQL script and evidence files provide the basis for reproducing and reviewing the reported calculations in MySQL Workbench.

## 8. Data Limitations and Interpretation

**Timestamp validity:** The event timestamps may have been randomized or otherwise altered in the dataset. Consequently, the calculated case durations and intervals between events describe the stored timestamps and should not be treated as actual clinical durations or waiting times without validating the source timestamp semantics.

**Invalid identifiers:** The 24 events associated with the placeholder case ID `NA` are excluded from the valid-case analysis to avoid treating missing identifiers as a genuine patient case.

**Duplicate records:** One duplicate group with one additional matching row was identified. It is documented as a data-quality finding and is not automatically removed by the analysis.

**Process interpretation:** Repeated activities and `Return ER` occurrences are descriptive indicators. Further clinical and process context is needed before drawing conclusions about care quality, inefficiency, readmission, or patient outcomes.

## 9. Conclusion

The Sepsis event log contains 15,214 imported rows, with matching source and destination row counts. After excluding 24 events associated with invalid case identifiers, the analysis uses 15,190 events across 1,049 valid cases.

The SQL analysis produces five process-analysis KPIs: average events per case, average case duration, average time between consecutive events, cases with repeated activities, and cases containing `Return ER`. The results provide a quantitative foundation for the CareFlow process-mining workflow.

The SQL script, validation report, and supporting evidence are organized in the `srivaishnavi-sql-analysis` branch for team review. The timestamp-validity limitation remains essential when interpreting time-based results.

---

**Project:** CareFlow â€” Clinical Pathway Process Mining
**Module:** Sepsis Event Log SQL Analysis
**Database:** MySQL (`careflow`)
**Primary SQL file:** `sql/sepsis_analysis.sql`
**Documentation:** `docs/sql_validation_results.md`
**Evidence directory:** `evidence/`
**Working branch:** `srivaishnavi-sql-analysis`
