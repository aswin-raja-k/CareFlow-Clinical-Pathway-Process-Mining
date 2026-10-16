# CareFlow – Sepsis Cases Event Log Data Dictionary

## 1. File-Level Verification

- **Dataset file:** `Sepsis Cases - Event Log.csv`
- **Rows:** 15,214
- **Total columns in CSV:** 33
- **Substantive dataset fields:** 32
- **Technical extra column:** `Unnamed: 0`

The CSV contains **33 columns in total**. Of these, **32 are substantive dataset fields**, while `Unnamed: 0` is a technical exported row-index column.

### Technical Extra Column

| Column | Description |
|---|---|
| `Unnamed: 0` | Sequential exported row index from 0 to 15,213. This is a technical column and is not a clinical or process-mining attribute. |

## 2. Core Process-Mining Fields

The dataset contains the three required fields for process mining:

| Field | Description |
|---|---|
| `case:concept:name` | Case identifier used to group events belonging to the same patient/case trace. |
| `concept:name` | Activity or event name performed during the case. |
| `time:timestamp` | Timestamp associated with each event. |

All three required process-mining fields are present in the actual CSV.

---

## 3. Data Dictionary

| No. | Column Name | Description | Data Type / Format |
|---:|---|---|---|
| 1 | `case:concept:name` | Unique case identifier used to group events into process traces. | Numeric / identifier |
| 2 | `concept:name` | Name of the activity or event performed. | Text |
| 3 | `time:timestamp` | Date and time at which the event occurred. | Timestamp |
| 4 | `Age` | Age of the patient. | Numeric |
| 5 | `Diagnose` | Diagnosis associated with the case. | Text |
| 6 | `DiagnosticArtAstrup` | Result/status of arterial blood gas diagnostic testing. | Text |
| 7 | `DiagnosticBlood` | Blood diagnostic test information/result. | Text |
| 8 | `DiagnosticECG` | ECG diagnostic test information/result. | Text |
| 9 | `DiagnosticIC` | Intensive-care-related diagnostic information. | Text |
| 10 | `DiagnosticLacticAcid` | Lactic acid diagnostic measurement/result. | Numeric / text |
| 11 | `DiagnosticLiquor` | Cerebrospinal fluid (liquor) diagnostic information. | Text |
| 12 | `DiagnosticOther` | Other diagnostic test information. | Text |
| 13 | `DiagnosticSputum` | Sputum diagnostic information. | Text |
| 14 | `DiagnosticUrinaryCulture` | Urinary culture diagnostic information. | Text |
| 15 | `DiagnosticUrinarySediment` | Urinary sediment diagnostic information. | Text |
| 16 | `DiagnosticXray` | X-ray diagnostic information/result. | Text |
| 17 | `DiagnosticUrinary` | Urinary diagnostic information. | Text |
| 18 | `DiagnosticCT` | CT scan diagnostic information. | Text |
| 19 | `DiagnosticMRI` | MRI diagnostic information. | Text |
| 20 | `DiagnosticOtherBlood` | Other blood-related diagnostic information. | Text |
| 21 | `DiagnosticOtherMicrobiology` | Other microbiological diagnostic information. | Text |
| 22 | `DiagnosticOtherImaging` | Other medical imaging diagnostic information. | Text |
| 23 | `DiagnosticOtherLab` | Other laboratory diagnostic information. | Text |
| 24 | `DiagnosticOtherProcedure` | Other diagnostic procedure information. | Text |
| 25 | `DiagnosticOtherClinical` | Other clinical diagnostic information. | Text |
| 26 | `DiagnosticOtherDiagnostic` | Other diagnostic information not covered by the specified categories. | Text |
| 27 | `Leucocytes` | Leukocyte/white blood cell laboratory measurement. | Numeric |
| 28 | `CRP` | C-reactive protein laboratory measurement. | Numeric |
| 29 | `LacticAcid` | Lactic acid laboratory measurement. | Numeric |
| 30 | `Hypotension` | Indicator related to hypotension/low blood pressure. | Boolean / text |
| 31 | `Hypoxemia` | Indicator related to hypoxemia/low blood oxygen. | Boolean / text |
| 32 | `Sepsis` | Indicator related to sepsis status. | Boolean / text |

> **Note:** The 32 substantive fields above are the dataset attributes used for documentation. The additional `Unnamed: 0` column is treated separately as a technical row index.

---

## 4. Data Quality Verification

The CSV was inspected directly to verify the documented schema and basic data quality.

### File Structure

- **Rows:** 15,214
- **Total columns:** 33
- **Substantive fields:** 32
- **Technical index field:** `Unnamed: 0`

### Missing Values

- **Total missing cells:** 377,918
- `case:concept:name` has **24 missing values**.
- `concept:name` has **0 missing values**.
- `time:timestamp` has **0 missing values**.
- Some clinical/laboratory fields contain substantial missing values because those measurements are not recorded for every event/case.

### Duplicate Checks

- **Exact duplicate rows:** 0
- **Repeated Case ID + Activity + Timestamp combinations:** 7

Repeated combinations do not necessarily represent erroneous duplicate records because the same activity can occur more than once within a case.

### Case Information

- **Distinct case IDs:** 1,049 nonblank case identifiers.
- **Missing case IDs:** 24.

### Activity Information

- **Distinct activity labels:** 16.
- Activity names are available in `concept:name`.

### Timestamp Information

- All **15,214 timestamp values** can be parsed as timestamps.
- The CSV may initially import the timestamp column as text/object and should be parsed as a timestamp before process-mining analysis.

### Data Modification

- No rows were removed during verification.
- No original dataset values were changed.
- The checks were performed only for documentation and schema verification.

---

## 5. Important Timestamp Limitation

The timestamps in the Sepsis Cases Event Log have been **randomized by the dataset publisher** while preserving the time intervals within individual traces.

Therefore, the timestamps should be used carefully.

### Suitable Uses

The timestamp information can be used for:

- Ordering events within a case.
- Process discovery.
- Conformance checking.
- Bottleneck and waiting-time analysis within traces.
- Calculating relative durations between events.
- Identifying process variants.

### Limitations

The randomized timestamps should **not** be interpreted as authentic calendar dates.

Do not use this dataset to make claims about:

- Actual hospital dates.
- Actual weekdays.
- Actual shifts.
- Seasonality.
- Real-world calendar-time trends.
- Actual hospital performance during a particular period.
- Real emergency-room waiting times in a specific historical period.

The project should focus on **process sequence and relative timing**, rather than treating the timestamp dates as real-world calendar information.

---

## 6. Process-Mining Suitability

The Sepsis Cases Event Log is suitable for the CareFlow process-mining project because it contains the fundamental event-log structure required for process analysis:

1. **Case ID** – identifies individual process traces.
2. **Activity** – identifies events performed in the process.
3. **Timestamp** – provides the temporal ordering of events.

The dataset contains approximately 15,000 events across approximately 1,000 cases and includes multiple activity types, making it suitable for process discovery and process analysis.

However, the timestamp randomization must be clearly documented when interpreting time-based results.

---

## 7. Dataset Source

**Author:** Felix Mannhardt

**Year:** 2016

**Dataset:** *Sepsis Cases – Event Log*

**Version:** Version 1

**Repository:** 4TU.ResearchData, Eindhoven University of Technology

**DOI:**

`10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460`

**Official dataset record:**

`https://data.4tu.nl/articles/_/12707639/1`

The dataset source and DOI should be retained in the project documentation so that the dataset can be properly identified and cited.

---

## 8. Usage and Redistribution Terms

The dataset is provided under the **4TU General Terms of Use**.

According to Section 4, part or all of the dataset may be distributed to third parties, provided that the source and rights-holder/Creator are acknowledged. Any subsequent distribution must also include the source acknowledgement.

The data may be remixed, transformed, or used to build upon for **non-commercial purposes only**.

For this project:

- Source acknowledgement must be included.
- The original creator/rights-holder must be credited.
- The DOI and official dataset record should be provided.
- The dataset must not be used for commercial purposes.
- Any subsequent redistribution should retain the required acknowledgement.

**Redistribution status:** Permitted under the 4TU General Terms of Use, subject to the above conditions.

**Official terms:** 4TU General Terms of Use, August 2016.

## 9. Dataset Selection Rationale

The Sepsis Cases Event Log was selected for the CareFlow project because it provides a structured healthcare event log containing the main fields required for process mining:

- Case identifier
- Activity/event name
- Timestamp
- Additional clinical and diagnostic attributes

It provides multiple events per case and multiple activity types, allowing process sequences and process variants to be examined.

The dataset is therefore useful for demonstrating process discovery, process-flow analysis, bottleneck identification, and other process-mining techniques.

The randomized timestamp limitation must be considered when interpreting time-related findings.

---

## 10. Summary

| Verification Item | Result |
|---|---|
| Dataset domain | Healthcare / Sepsis |
| File format | CSV |
| Rows | 15,214 |
| Total CSV columns | 33 |
| Substantive dataset fields | 32 |
| Technical extra column | `Unnamed: 0` |
| Case ID field | `case:concept:name` |
| Activity field | `concept:name` |
| Timestamp field | `time:timestamp` |
| Distinct case IDs | 1,049 nonblank |
| Distinct activities | 16 |
| Exact duplicate rows | 0 |
| Repeated Case ID + Activity + Timestamp | 7 |
| Missing cells | 377,918 |
| Timestamp limitation | Randomized timestamps |
| Source | 4TU.ResearchData |
| DOI | `10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460` |
| Usage terms | 4TU General Terms of Use |
| Raw dataset for GitHub | Do not upload until redistribution terms are confirmed |

---

## 11. Verification Status

This data dictionary was verified against the actual `Sepsis Cases - Event Log.csv` file.

The verification confirms that the documented process-mining fields and overall CSV structure match the inspected file.

The technical `Unnamed: 0` column is documented separately and is not treated as a substantive clinical/process field.

**Verification date:** 15 October 2026
