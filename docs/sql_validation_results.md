# CareFlow: Clinical Pathway Process Mining
## Sepsis Event Log — SQL Analysis and Validation Report

### 1. Objective

The objective of this task was to validate the Sepsis event log using MySQL, investigate data-quality issues, calculate key performance indicators (KPIs), and analyze clinical pathway activity patterns.

The analysis also addressed a discrepancy between SQL and Python results caused by the treatment of the literal value `NA` in case identifiers.

### 2. Tools and Technologies

- **Database:** MySQL
- **SQL Editor:** MySQL Workbench
- **Dataset:** Sepsis Event Log
- **Schema:** `careflow`
- **Source table:** `sepsis_raw_import`
- **Analysis table:** `sepsis_event_log`
- **Version control:** Git and GitHub

### 3. Data Validation

The source dataset was compared with the destination analysis table to verify the successful loading and consistency of the records.

| Validation check | Result |
|---|---:|
| Source rows | 15,214 |
| Destination rows | 15,214 |
| Row difference | 0 |
| Distinct activities | 16 |
| Invalid case identifiers (`NA`) | 24 |
| Valid distinct cases | 1,049 |
| Valid events after excluding invalid case IDs | 15,190 |
| Missing timestamps | 0 |
| Duplicate selected-column groups | 1 |
| Overall row-count validation | PASS |

**Observation:** The source and destination tables contain the same number of records. However, matching row counts alone do not guarantee that all records are suitable for process analysis.

A further investigation identified 24 records with the literal value `NA` in the case identifier field. These records were excluded from the corrected KPI calculations.

The duplicate check identified one group of records with matching values across the selected columns. The record was retained rather than deleted without further investigation.

### 4. Activity Frequency Analysis

Activity frequency was analyzed to identify the most common clinical activities in the event log.

The following counts represent the activity-frequency results obtained from the original event log.

| Activity | Event count |
|---|---:|
| Leucocytes | 3,383 |
| CRP | 3,262 |
| LacticAcid | 1,466 |
| Admission NC | 1,182 |
| ER Triage | 1,053 |
| ER Registration | 1,050 |
| ER Sepsis Triage | 1,049 |
| IV Antibiotics | 823 |
| IV Liquid | 753 |
| Release A | 671 |
| Return ER | 294 |
| Admission IC | 117 |
| Release B | 56 |
| Release C | 25 |
| Release D | 24 |
| Release E | 6 |
| **Total events** | **15,214** |

**Observation:** Leucocytes and CRP are the most frequent activities, followed by LacticAcid. Release E has the lowest event count.

These counts describe the original event log, including records that were subsequently excluded from the corrected KPI calculations because of invalid case identifiers.

### 5. Key Performance Indicators (KPIs)

Five KPIs were calculated using SQL queries on the validated event data. The corrected calculations exclude events associated with invalid case identifiers.

| KPI | Corrected result |
|---|---:|
| Average events per case | 14.4805 |
| Average case duration | 41,017.73 minutes |
| Average time between consecutive events | 3,042.76 minutes |
| Cases with repeated activities | 743 |
| Percentage of cases with repeated activities | 70.83% |
| Cases containing `Return ER` | 294 |
| Percentage of cases containing `Return ER` | 28.03% |

#### KPI 1: Average Events per Case

**Result:** 14.4805 events per case.

This KPI measures the average number of valid recorded events associated with each valid case.

**Calculation:**

Average events per case = Valid events / Valid distinct cases

#### KPI 2: Average Case Duration

**Result:** 41,017.73 minutes.

This KPI measures the average elapsed time between the first and last recorded events for each case.

**Calculation:**

Case duration = Last event timestamp − First event timestamp

The average is calculated across valid cases with usable timestamps. The duration represents elapsed time and should not automatically be interpreted as active treatment time.

#### KPI 3: Average Time Between Consecutive Events

**Result:** 3,042.76 minutes.

This KPI measures the average time gap between consecutive events within a case.

**Calculation:**

Time between events = Current event timestamp − Previous event timestamp

The calculation depends on the event ordering used by the SQL query. The result represents elapsed time between recorded events, not necessarily the duration of a specific clinical activity.

#### KPI 4: Repeated Activities

**Result:** 743 out of 1,049 valid cases, or approximately 70.83%.

This KPI identifies cases in which at least one activity occurs more than once.

Repeated activities may indicate rework, repeated testing, or legitimate clinical procedures. Case-level event sequences must be examined before interpreting these patterns.

#### KPI 5: Return ER

**Result:** 294 out of 1,049 valid cases, or approximately 28.03%.

This KPI identifies valid cases containing the `Return ER` activity.

These cases may warrant further investigation to understand the sequence of events preceding and following an emergency-room return.

### 6. Key Findings

1. The source and destination tables contain 15,214 rows each, with no row-count difference.
2. The event log contains 16 distinct activities.
3. Twenty-four records contain the literal value `NA` in the case identifier field and were excluded from the corrected KPI analysis.
4. The corrected analysis uses 15,190 valid events across 1,049 valid cases.
5. Repeated activities were identified in 743 cases, representing approximately 70.83% of valid cases.
6. The `Return ER` activity was found in 294 valid cases, representing approximately 28.03% of valid cases.
7. Leucocytes and CRP are the most frequent activities in the original event log.
8. One duplicate group was identified using the selected-column duplicate check and retained for further review.

### 7. Data-Quality Considerations

During validation, SQL and Python produced different results because the literal text `NA` was not treated consistently as a missing or invalid case identifier.

The corrected analysis explicitly excludes invalid case identifiers before calculating case-based KPIs. This ensures that the denominators and event counts used in the analysis are consistent.

The duplicate check was limited to the columns included in the query. Therefore, the identified group should not automatically be considered a confirmed duplicate clinical event. Further investigation using the full event record and relevant identifiers is required before removing any data.

### 8. Conclusion

SQL-based validation and KPI analysis were performed on the Sepsis event log as part of the CareFlow: Clinical Pathway Process Mining project.

The source and destination row counts matched, and the investigation identified 24 records with invalid case identifiers. After excluding these records from the corrected KPI calculations, the analysis used 15,190 valid events across 1,049 valid cases.

The calculated KPIs provide an initial overview of clinical activity frequency, case duration, event timing, repeated activities, and emergency-room returns. These results support further process-mining analysis to investigate clinical pathway patterns and potential bottlenecks.

Further interpretation should be based on case-level event sequences, timestamp validation, and clinical context.

### 9. Final Validation Status

**Row-count validation: PASS**

**Case identifier validation: 24 invalid `NA` records identified and excluded from corrected KPI calculations.**

**KPI analysis: Completed using the corrected case filtering.**

**Duplicate review: One selected-column duplicate group identified and retained pending further investigation.**

The report reflects the corrected SQL results obtained during the validation task. The row-count validation status should not be interpreted as confirmation that every record is free of data-quality issues.