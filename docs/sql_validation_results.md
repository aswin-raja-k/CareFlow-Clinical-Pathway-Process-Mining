# CareFlow: Clinical Pathway Process Mining

## Sepsis Event Log — SQL Analysis and Validation Report

### 1. Objective

The objective of this task was to validate the Sepsis event log using MySQL, investigate data-quality issues, calculate key performance indicators (KPIs), and analyze clinical pathway activity patterns.

The analysis also addressed a discrepancy between SQL and Python results caused by inconsistent treatment of the literal value `NA` in case identifiers.

### 2. Tools and Technologies

- **Database:** MySQL
- **SQL Editor:** MySQL Workbench
- **Dataset:** Sepsis Event Log
- **Schema:** `careflow`
- **Source table:** `sepsis_raw_import`
- **Analysis table:** `sepsis_event_log`
- **Version control:** Git and GitHub

### 3. Data Validation

The source dataset was compared with the destination analysis table to verify successful data loading and consistency in the total number of records.

| Validation check | Result |
|---|---:|
| Source rows | 15,214 |
| Destination rows | 15,214 |
| Row-count difference | 0 |
| Distinct activities | 16 |
| Records with case ID `NA` | 24 |
| Valid distinct cases | 1,049 |
| Valid events after excluding invalid case IDs | 15,190 |
| Missing timestamps | 0 |
| Duplicate groups matching the selected columns | 1 |
| Overall row-count validation | PASS |

**Observations**

The source and destination tables contain the same number of records, confirming that their total row counts match. The validation also identified 24 records containing the literal text `NA` in the case identifier field. These records were excluded from the corrected case-based KPI calculations.

The duplicate investigation identified one group with matching values across the selected columns. The records were retained to preserve the original data and avoid deleting records without sufficient evidence.

### 4. Activity Frequency Analysis

Activity frequency was analyzed to identify the most common clinical activities in the original event log.

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

**Observations**

Leucocytes and CRP are the most frequent activities, followed by LacticAcid. Release E has the lowest event count.

These frequencies represent the original event log, including records excluded from the corrected KPI calculations because of invalid case identifiers.

### 5. Key Performance Indicators (KPIs)

Five KPIs were calculated using SQL queries. The corrected calculations exclude events associated with invalid case identifiers.

| KPI | Corrected result |
|---|---:|
| Average events per case | 14.4805 |
| Average case duration | 41,017.73 minutes |
| Average time between consecutive events | 3,042.76 minutes |
| Cases with repeated activities | 743 |
| Cases with repeated activities (%) | 70.83% |
| Cases containing `Return ER` | 294 |
| Cases containing `Return ER` (%) | 28.03% |

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

The average case duration is calculated across valid cases with usable timestamps. It represents elapsed time between recorded events rather than active treatment time.

#### KPI 3: Average Time Between Consecutive Events

**Result:** 3,042.76 minutes.

This KPI measures the average time gap between consecutive events within a case.

**Calculation:**

Time between events = Current event timestamp − Previous event timestamp

Events are ordered by timestamp within each case. This KPI describes the elapsed time between recorded events.

#### KPI 4: Repeated Activities

**Result:** 743 out of 1,049 valid cases, approximately 70.83%.

This KPI identifies cases in which at least one activity occurs more than once.

Repeated activities can indicate recurring tests, repeated procedures, or other patterns in the clinical pathway. Their interpretation depends on the sequence of events and the clinical context.

#### KPI 5: Return ER

**Result:** 294 out of 1,049 valid cases, approximately 28.03%.

This KPI identifies valid cases containing the `Return ER` activity.

The result indicates how frequently this activity appears across valid cases and supports further analysis of the event sequences associated with emergency-room returns.

### 6. Key Findings

1. The source and destination tables contain 15,214 rows each, with no difference in total row counts.
2. The original event log contains 16 distinct activities.
3. Twenty-four records contain the literal value `NA` in the case identifier field.
4. After excluding these records, the corrected analysis uses 15,190 valid events across 1,049 valid cases.
5. Repeated activities were identified in 743 valid cases, representing approximately 70.83% of valid cases.
6. The `Return ER` activity was found in 294 valid cases, representing approximately 28.03% of valid cases.
7. Leucocytes and CRP are the most frequent activities in the original event log.
8. One duplicate group was identified using the selected-column duplicate check and retained without deleting the records.
9. Explicit handling of invalid case identifiers provides consistent filtering for case-based KPI calculations.

### 7. Data-Quality Considerations

The discrepancy between the earlier SQL and Python results arose from inconsistent handling of the literal text `NA` in case identifiers.

SQL conditions that check only for `NULL` values or empty strings do not identify the literal text `NA`. The corrected validation explicitly identifies these placeholder values before calculating valid case counts and case-based KPIs.

The duplicate investigation compared selected event columns and identified one matching group. The records were retained, and no deletion was performed during this validation task.

Activity-frequency results describe the original event log, while the corrected case-based KPIs use the filtered data. This distinction is maintained throughout the report.

### 8. Conclusion

SQL-based validation and KPI analysis were performed on the Sepsis event log as part of the CareFlow: Clinical Pathway Process Mining project.

The source and destination tables were verified to contain 15,214 records each. The validation identified 24 records with the literal value `NA` in the case identifier field. After excluding these records, the corrected analysis covered 15,190 valid events across 1,049 valid cases.

The analysis quantified clinical activity frequencies, average case duration, average time between consecutive events, repeated activities, and the occurrence of the `Return ER` activity. These results provide insights into event distribution and clinical pathway patterns and support further process-mining analysis.

### 9. Final Validation Status

- **Row-count validation:** PASS — source and destination tables each contain 15,214 rows.
- **Case identifier validation:** 24 records containing the literal value `NA` identified and excluded from corrected KPI calculations.
- **Valid analysis dataset:** 15,190 events across 1,049 valid cases.
- **KPI analysis:** Five KPI categories documented with their calculated results.
- **Duplicate review:** One selected-column duplicate group identified; records retained.
- **SQL–Python discrepancy:** Inconsistent handling of `NA` identified as the cause of the earlier difference in case counts.

The SQL validation and KPI analysis establish a documented baseline for the CareFlow project and support further investigation of clinical pathway patterns using process-mining techniques.
