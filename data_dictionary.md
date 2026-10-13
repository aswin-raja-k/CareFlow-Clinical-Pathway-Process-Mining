# CareFlow – Data Dictionary

## 1. Dataset Information

- Dataset Name: Sepsis Cases – Event Log
- Author: Felix Mannhardt
- Year: 2016
- Source: 4TU.ResearchData
- DOI: 10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- Purpose: Clinical Pathway Process Mining

## 2. Core Fields

| Field Name | Meaning | Data Type | Relevance to Process Mining |
|---|---|---|---|
| case:concept:name | Identifies the case or patient pathway | Identifier; confirm actual storage type | Groups events belonging to the same case |
| concept:name | Identifies the activity performed | Text/category; confirm actual type | Shows the steps in a healthcare process |
| time:timestamp | Records when an event occurred | Date/time; confirm actual type | Helps arrange activities in chronological order |

## 3. Other Columns

Add all remaining column names from the actual dataset and document their meanings, data types and relevance.

## 4. Dataset Limitations

The dataset's timestamps were randomized. Real-world calendar-time conclusions should not be drawn from them.

## 5. Data Quality Status

This document describes the dataset structure. Missing values, duplicates and other data-quality issues will be investigated separately.

## 6. Purpose in CareFlow

The dataset will be used to study healthcare activity sequences and explore possible workflow bottlenecks through process mining.
