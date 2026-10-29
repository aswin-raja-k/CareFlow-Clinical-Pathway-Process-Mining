# Data Preparation Plan

## 1. Purpose

This document defines the proposed preparation and validation rules for the Sepsis Cases - Event Log dataset used in the CareFlow: Clinical Pathway Process Mining project.

The goal is to prepare a reliable event log while preserving the original dataset and documenting every preparation decision.

**Important:** The raw and prepared dataset CSV files must not be modified or overwritten as part of this documentation task.

## 2. Dataset Source

- **Dataset:** Sepsis Cases - Event Log
- **Creator:** Felix Mannhardt
- **Publisher:** 4TU.ResearchData
- **Official source:** https://data.4tu.nl/articles/_/12707639/1
- **DOI:** 10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- **Licence:** 4TU General Terms of Use

## 3. Preparation Principles

1. Preserve the raw dataset without modification.
2. Apply preparation rules to a separate working copy.
3. Record the number of rows before and after every preparation stage.
4. Do not remove records without documenting the reason.
5. Keep original values available for traceability.
6. Do not assume that repeated events are errors.
7. Mark unverified counts and decisions clearly.

## 4. Proposed Data Preparation Rules

### 4.1 Case ID Validation

The case identifier is `case:concept:name`.

- Check for missing or blank case IDs.
- Check whether case IDs have valid and consistent formats.
- Do not convert case IDs to numeric values unless the source format and team requirements support this.
- Flag records with missing or invalid case IDs for investigation.
- Exclude invalid case IDs from the prepared event log only after the team approves the rule.
- Record the number of affected rows.

### 4.2 Duplicate Handling

Two types of duplicates must be distinguished.

**Exact duplicate rows**

Rows are exact duplicates when every column has the same value.

- Identify exact duplicate rows.
- Count them separately.
- Remove them from the working copy only if the team approves.
- Preserve the original raw data.

**Repeated case/activity/timestamp combinations**

Rows may share the same `case:concept:name`, `concept:name`, and `time:timestamp` while differing in other columns.

- Do not automatically classify these as exact duplicates.
- Do not automatically delete them.
- Investigate the other field values and event meaning.
- Retain legitimate repeated events unless the team defines a justified removal rule.

### 4.3 Timestamp Validation

The event timestamp is `time:timestamp`.

- Parse timestamps using a consistent datetime format.
- Identify missing or unparseable timestamps.
- Check for timestamps that occur before other events within the same case.
- Sort events by case ID and timestamp for process analysis.
- Investigate events with identical timestamps within a case.
- Do not invent or impute timestamps without an approved method.
- Document any excluded or corrected timestamp records.

The source dataset has been described as having randomized timestamps. This limitation must be retained in the documentation and considered during process-time analysis.

### 4.4 Activity Name Validation

The activity field is `concept:name`.

- Identify missing or blank activity names.
- Inspect leading/trailing whitespace and inconsistent formatting.
- Do not rename activities based only on assumptions.
- Apply activity-name normalization only through an approved mapping.
- Preserve original activity names for traceability.
- Document any mapping or exclusion rule.

## 5. Validation Checkpoints

The following checkpoints are proposed. Row counts must be populated from actual execution of the preparation process.

| Stage | Validation | Expected Row Count | Status |
|---|---|---:|---|
| 0 | Original CSV row count | Not independently verified | Pending |
| 1 | After checking missing/invalid case IDs | Not independently verified | Pending |
| 2 | After identifying exact duplicate rows | Not independently verified | Pending |
| 3 | After applying approved exact-duplicate rule | Not independently verified | Pending |
| 4 | After timestamp validation | Not independently verified | Pending |
| 5 | After activity-name validation | Not independently verified | Pending |
| 6 | Final prepared event log | Not independently verified | Pending |

**Note:** These checkpoints are a proposed validation plan, not reported execution results. Do not fill in row counts based on estimates.

## 6. Existing Dataset Findings

The following schema findings have been checked against the available CSV header:

- Total columns: 33
- Substantive fields: 32
- Technical/index column: `Unnamed: 0`
- Core process-mining fields:
  - `case:concept:name`
  - `concept:name`
  - `time:timestamp`

The number of rows at each preparation stage has not yet been independently verified for this plan.

Any existing team-reported row counts must be labeled as team-reported until confirmed against the dataset and preparation procedure.

## 7. Preparation Workflow

1. Read the raw CSV without changing it.
2. Record its initial row and column counts.
3. Inspect missing values and invalid case IDs.
4. Identify exact duplicate rows.
5. Separately inspect repeated case/activity/timestamp combinations.
6. Validate timestamp formats and within-case ordering.
7. Inspect activity names and propose any mapping.
8. Apply only team-approved preparation rules to a separate working copy.
9. Record row counts and validation results at every checkpoint.
10. Review the prepared event log with the team before use in process mining.

## 8. Limitations and Review

- Timestamp randomization may limit the interpretation of event durations and temporal patterns.
- Repeated events may represent legitimate process behavior.
- The proposed handling rules require team review before implementation.
- No raw or prepared CSV files are modified by this documentation task.

## 9. Review Status

**Status:** Proposed plan — pending team review.
Issue #9 must remain open until the review is approved.
