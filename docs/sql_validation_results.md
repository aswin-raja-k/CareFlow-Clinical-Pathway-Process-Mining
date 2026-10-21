# CareFlow: Clinical Pathway Process Mining
## Sepsis Event Log — SQL Analysis and Validation Report

### 1. Objective

The objective of this task was to analyze the Sepsis event log using MySQL, validate data quality, calculate key performance indicators (KPIs), and identify patterns in clinical pathway activities.

### 2. Tools and Technologies

- **Database:** MySQL
- **SQL Editor:** MySQL Workbench
- **Dataset:** Sepsis Event Log
- **Schema:** `careflow`
- **Tables:** `sepsis_raw_import`, `sepsis_event_log`

### 3. Data Validation

The source dataset was compared with the destination analysis table to verify that the data was loaded correctly.

| Validation check | Result |
|---|---:|
| Source rows | 15,214 |
| Destination rows | 15,214 |
| Row difference | 0 |
| Unique cases | 1,050 |
| Distinct activities | 16 |
| Missing case IDs | 0 |
| Missing timestamps | 0 |
| Overall validation status | PASS |

**Observation:** The source and destination tables contain the same number of records. No missing case IDs or timestamps were identified in the analysis table.

### 4. Activity Frequency Analysis

Activity frequency was calculated to understand which clinical activities occur most often in the dataset.

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

**Observation:** Leucocytes and CRP are the most frequent activities, followed by LacticAcid. The release activities occur less frequently, with Release E having the lowest event count.

### 5. Key Performance Indicators (KPIs)

Five KPIs were calculated using SQL queries on the Sepsis event log.

| KPI | Actual result |
|---|---:|
| Average events per case | 14.4895 |
| Average case duration | 40,995.85138 minutes |
| Average time between consecutive events | 3,039.08811 minutes |
| Cases with repeated activities | 744 |
| Percentage of cases with repeated activities | 70.85714% |
| Cases with Return ER | 294 |
| Percentage of cases with Return ER | 28.00000% |

#### KPI 1: Average Events per Case

**Result:** 14.4895 events per case.

This KPI measures the average number of recorded events associated with each case.

#### KPI 2: Average Case Duration

**Result:** 40,995.85138 minutes.

This KPI measures the average elapsed time between the first and last recorded events for each case.

#### KPI 3: Average Time Between Consecutive Events

**Result:** 3,039.08811 minutes.

This KPI measures the average time gap between consecutive events within a case, based on the event ordering used in the SQL query.

#### KPI 4: Repeated Activities

**Result:** 744 out of 1,050 cases, or 70.85714%.

This KPI identifies cases in which at least one activity occurs more than once. Repeated activities can be investigated further to understand potential rework or repeated clinical procedures.

#### KPI 5: Return ER

**Result:** 294 out of 1,050 cases, or 28.00000%.

This KPI identifies cases containing a `Return ER` activity. These cases may warrant further process analysis to understand the circumstances surrounding emergency-room returns.

### 6. Key Findings

1. The dataset contains 15,214 events across 1,050 unique cases.
2. All 16 distinct activities were identified in the event log.
3. The source and destination row counts match, with no missing case IDs or timestamps.
4. Repeated activities were identified in 744 cases (70.85714%).
5. The `Return ER` activity appears 294 times, corresponding to 28% of unique cases containing this activity.
6. The activity-frequency results show that laboratory-related activities, particularly Leucocytes and CRP, occur most frequently.

These findings highlight areas for further investigation in clinical pathway process mining. Repeated activities and emergency-room returns should be examined alongside case timelines and clinical context before drawing conclusions about bottlenecks or avoidable rework.

### 7. Conclusion

SQL-based validation and KPI analysis were completed on the Sepsis event log. The validation query returned `PASS`, confirming that the source and destination row counts match and that the checked case IDs and timestamps are complete.

The calculated KPIs provide an initial overview of case activity, elapsed duration, event timing, repeated activities, and emergency-room returns. These results can support subsequent process-mining analysis and visualization in the CareFlow project.

### 8. Validation Status

**Status: SQL analysis executed and expected counts validated.**

The reported figures reflect the query outputs obtained in MySQL Workbench. Further process interpretation should be supported by reviewing case-level event sequences and timestamps.
