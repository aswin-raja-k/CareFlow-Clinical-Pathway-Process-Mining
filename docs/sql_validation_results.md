# CareFlow: Clinical Pathway Process Mining

## Sepsis Event Log — SQL Analysis and Validation Report

### 1. Objective

The objective of this task was to validate the Sepsis event log using MySQL, investigate data-quality issues, calculate key performance indicators (KPIs), and analyze clinical pathway activity patterns.

The analysis investigated the difference between 1,050 distinct IDs and 1,049 valid cases by standardizing the treatment of invalid case identifiers, including the literal value `NA`.

### 2. Tools and Technologies

- **Database:** MySQL
- **SQL Editor:** MySQL Workbench
- **Dataset:** Sepsis Event Log
- **Schema:** `careflow`
- **Source table:** `sepsis_raw_import`
- **Analysis table:** `sepsis_event_log`
- **Version control:** Git and GitHub

### 3. Data Validation

The source dataset was compared with the destination analysis table to verify successful data loading and consistency in total record counts.

| Validation check | Result |
|---|---:|
| Source rows | 15,214 |
| Destination rows | 15,214 |
| Row-count difference | 0 |
| Total events | 15,214 |
| Distinct activities | 16 |
| Rows with invalid case IDs | 24 |
| Distinct IDs including placeholders | 1,050 |
| Distinct valid cases | 1,049 |
| Valid event rows after excluding invalid case IDs | 15,190 |
| Missing timestamps | 0 |
| Overall row-count validation | PASS |

**Observations**

The source and destination tables contain the same number of records, confirming that their total row counts match.

The validation identified 24 event rows associated with the literal case ID `NA`. These rows were excluded from the corrected case-based KPI calculations.

The distinct-ID comparison returned 1,050 when placeholders were included and 1,049 after invalid case IDs were excluded. This explains the difference between the original and corrected valid-case counts.

### 4. Activity Frequency Analysis

Activity frequencies were analyzed to identify the most common clinical activities in the original event log.

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

These frequencies represent the original event log. They include events associated with invalid case identifiers, unlike the corrected case-based KPI calculations.

### 5. Key Performance Indicators (KPIs)

Five KPI categories were calculated using SQL. The corrected case-based analysis excludes invalid case identifiers according to the standardized filtering rule.

| KPI | Result |
|---|---:|
| Average events per case | 14.4805 |
| Average case duration | 41,017.73047 minutes |
| Average time between consecutive events | 3,042.75506 minutes |
| Cases with repeated activities | 743 |
| Cases with repeated activities (%) | 70.83% |
| Cases containing `Return ER` | 294 |
| Cases containing `Return ER` (%) | 28.03% |

#### KPI 1: Average Events per Case

**Result:** 14.4805 events per valid case.

This KPI measures the average number of valid recorded events associated with each valid case.

**Calculation:**

Average events per case = Valid event rows / Valid distinct cases

#### KPI 2: Average Case Duration

**Result:** 41,017.73047 minutes.

This KPI measures the elapsed time between the first and last recorded event for each valid case.

**Calculation:**

Case duration = Last event timestamp − First event timestamp

The average case duration represents elapsed time between recorded events rather than active treatment time.

#### KPI 3: Average Time Between Consecutive Events

**Result:** 3,042.75506 minutes.

This KPI measures the average time gap between consecutive events within valid cases.

**Calculation:**

Time between events = Current event timestamp − Previous event timestamp

Events are ordered by timestamp within each case. The result describes elapsed time between recorded events.

#### KPI 4: Repeated Activities

**Result:** 743 out of 1,049 valid cases, approximately 70.83%.

This KPI identifies valid cases in which at least one activity occurs more than once, according to the implemented SQL query.

Repeated activities can indicate recurring tests, repeated procedures, or other patterns in the clinical pathway. Their interpretation depends on the event sequence and clinical context.

#### KPI 5: Return ER

**Result:** 294 out of 1,049 valid cases, approximately 28.03%.

This KPI identifies valid cases containing the `Return ER` activity.

The result indicates how frequently this activity appears across valid cases and supports further investigation of emergency-room return patterns.

### 6. Duplicate Investigation

A duplicate-check query grouped events by case ID, activity name, event timestamp, and lifecycle transition. The query returned seven candidate duplicate groups, each containing two occurrences.

The groups identified were:

| Case ID | Activity | Timestamp | Occurrences |
|---|---|---|---:|
| UM | Leucocytes | 2014-09-25 11:09:00 | 2 |
| ZM | CRP | 2014-04-15 09:00:00 | 2 |
| ZM | Leucocytes | 2014-04-15 09:00:00 | 2 |
| YO | Leucocytes | 2014-06-05 08:00:00 | 2 |
| YO | CRP | 2014-06-05 08:00:00 | 2 |
| ES | Leucocytes | 2014-11-08 05:50:00 | 2 |
| NGA | LacticAcid | 2014-06-18 07:00:00 | 2 |

These are candidate duplicate groups based on the selected columns. Matching values across these columns do not, by themselves, prove that the records are erroneous duplicates. No records were deleted during this validation task.

### 7. Case-Count Discrepancy and Data-Quality Considerations

The distinct-ID validation returned the following results:

- Distinct IDs including placeholders: **1,050**
- Distinct valid cases after excluding placeholders: **1,049**
- Event rows associated with the literal `NA` case ID: **24**

The literal text `NA` is not the same as a SQL `NULL` value. Therefore, a query that checks only for `NULL` or empty strings may still count `NA` as a distinct case identifier.

The corrected SQL filtering rule excludes blank values and recognized placeholder values, including `NA`, `N/A`, `NAN`, `NULL`, and `NONE`, from valid-case calculations.

This explains the SQL case-count difference observed during validation. A Python comparison has not yet been performed, so cross-validation between SQL and Python remains unverified.

Activity-frequency results describe the original event log, while the corrected case-based KPIs use the filtered data. This distinction is maintained throughout the report.

### 8. SQL–Python Comparison Status

A Python validation script was not available for this task, and no Python KPI calculations were performed.

Consequently, the SQL results have not yet been compared with Python results. The case-count discrepancy has been explained using SQL validation outputs, but it should not be described as a confirmed SQL–Python comparison.

If Python comparison is required, a script should be created or obtained and configured to use the same invalid-ID rules, timestamp handling, event ordering, and KPI definitions as the SQL analysis. Any actual differences can then be recorded.

### 9. Conclusion

SQL-based validation and KPI analysis were performed on the Sepsis event log as part of the CareFlow: Clinical Pathway Process Mining project.

The source and destination tables were verified to contain 15,214 rows each. The validation identified 24 event rows associated with the literal `NA` case ID. After excluding invalid case identifiers, the corrected analysis covered 15,190 event rows across 1,049 valid cases.

The analysis documented activity frequencies, average events per case, average case duration, average time between consecutive events, repeated activities, and the occurrence of the `Return ER` activity.

The duplicate investigation identified seven candidate duplicate groups, which were retained pending further investigation. The discrepancy between 1,050 IDs and 1,049 valid cases was explained by the treatment of placeholder case identifiers.

The SQL validation and KPI results provide a documented baseline for further process-mining analysis. Python comparison remains pending.

### 10. Final Validation Status

- **Row-count validation:** PASS — source and destination tables each contain 15,214 rows.
- **Case identifier validation:** 24 event rows associated with the literal `NA` value identified.
- **Distinct case validation:** 1,050 IDs including placeholders; 1,049 valid cases after filtering.
- **Valid analysis dataset:** 15,190 event rows across 1,049 valid cases.
- **Missing timestamps:** 0.
- **Activity analysis:** 16 distinct activities identified.
- **KPI analysis:** All five KPI categories have SQL results recorded.
- **Duplicate review:** Seven candidate duplicate groups identified; records retained.
- **SQL–Python comparison:** Pending; no Python script or comparison results are currently available.
- **Documentation:** Updated report is saved in `docs/sql_validation_results.md`.
