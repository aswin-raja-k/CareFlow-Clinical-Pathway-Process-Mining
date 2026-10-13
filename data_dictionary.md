# CareFlow – Dataset Data Dictionary

## 1. Introduction

The purpose of this data dictionary is to describe the fields in the Sepsis Cases – Event Log dataset selected for the CareFlow: Clinical Pathway Process Mining project. It explains the meaning of each field, its data type, and its importance for process mining.

## 2. Dataset Information

- **Dataset Name:** Sepsis Cases – Event Log
- **Author:** Felix Mannhardt
- **Publication Year:** 2016
- **Source:** 4TU.ResearchData
- **DOI:** 10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- **Domain:** Healthcare
- **Format:** CSV (confirm against the downloaded file)
- **Project:** CareFlow – Clinical Pathway Process Mining

## 3. Core Fields Required for Process Mining

### 3.1 Case Identifier — `case:concept:name`

- **Meaning:** Identifies the case to which an event belongs.
- **Expected Data Type:** Identifier; verify the actual storage type.
- **Purpose:** Groups all events associated with the same case.
- **Process-Mining Relevance:** Allows the sequence of activities for each case to be reconstructed.

### 3.2 Activity Name — `concept:name`

- **Meaning:** Identifies the activity performed during an event.
- **Expected Data Type:** Text or categorical value; verify the actual type.
- **Purpose:** Describes the steps recorded in the process.
- **Process-Mining Relevance:** Helps identify common activity sequences, repeated steps, and possible process bottlenecks.

### 3.3 Event Timestamp — `time:timestamp`

- **Meaning:** Records the date and time associated with an event.
- **Expected Data Type:** Date/time; verify the actual storage format.
- **Purpose:** Provides the temporal information associated with an activity.
- **Process-Mining Relevance:** Helps arrange events chronologically within each case and calculate time intervals between events, subject to the dataset's timestamp limitations.

## 4. Additional Dataset Fields

Document all other columns present in the downloaded dataset. Do not assume that every column listed below exists.

| Column Name | Meaning | Data Type | Relevance to Process Mining |
|---|---|---|---|
| Add actual column name | Describe what the field represents | Verify from file | Explain its analytical use |
| Add actual column name | Describe what the field represents | Verify from file | Explain its analytical use |

Replace these example rows with the actual remaining columns before submitting the document.

## 5. Data Dictionary Summary

| Core Field | Main Purpose |
|---|---|
| `case:concept:name` | Groups events belonging to the same case |
| `concept:name` | Identifies the activity performed |
| `time:timestamp` | Supports event ordering and time-interval analysis |

## 6. Dataset Limitations

The dataset's timestamps were randomized while time intervals between events within a case were preserved. Therefore, the timestamps should not be interpreted as reliable real-world calendar dates. Analyses should respect this limitation.

## 7. Data Quality Responsibility

This document describes the dataset structure and field meanings. Missing values, duplicate records, inconsistent timestamps, and other data-quality issues will be investigated separately by the assigned team member. No rows have been deleted or cleaned as part of this documentation task.

## 8. Relevance to the CareFlow Project

The event log can help the team examine healthcare activity sequences, understand variations in process paths, and investigate possible workflow bottlenecks. Findings should be interpreted within the limitations of the dataset.

## 9. Verification Status

- Dataset source and DOI: Check against the official repository record.
- Actual column names: Verify from the downloaded file.
- Data types: Verify from the downloaded file.
- Usage terms: Confirm from the official terms before redistribution.
- Data quality: Pending the assigned quality investigation.
