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
| 1 | `InfectionSuspected` | Indicates whether infection was suspected. | Boolean / text |
| 2 | `org:group` | Organizational group associated with the event. | Text |
| 3 | `DiagnosticBlood` | Blood diagnostic test information/result. | Text |
| 4 | `DisfuncOrg` | Indicates organ dysfunction. | Boolean / text |
| 5 | `SIRSCritTachypnea` | SIRS criterion related to respiratory rate/tachypnea. | Boolean / text |
| 6 | `Hypotensie` | Indicator related to hypotension/low blood pressure. | Boolean / text |
| 7 | `SIRSCritHeartRate` | SIRS criterion related to heart rate. | Boolean / text |
| 8 | `Infusion` | Records an infusion-related event or treatment. | Text |
| 9 | `DiagnosticArtAstrup` | Result/status of arterial blood gas diagnostic testing. | Text |
| 10 | `concept:name` | Name of the activity or event performed. | Text |
| 11 | `Age` | Age of the patient. | Numeric |
| 12 | `DiagnosticIC` | Intensive-care-related diagnostic information. | Text |
| 13 | `DiagnosticSputum` | Sputum diagnostic information. | Text |
| 14 | `DiagnosticLiquor` | Cerebrospinal fluid (liquor) diagnostic information. | Text |
| 15 | `DiagnosticOther` | Other diagnostic test information. | Text |
| 16 | `SIRSCriteria2OrMore` | Indicates whether two or more SIRS criteria were met. | Boolean / text |
| 17 | `DiagnosticXthorax` | X-thorax/X-ray diagnostic information or result. | Text |
| 18 | `SIRSCritTemperature` | SIRS criterion related to temperature. | Boolean / text |
| 19 | `time:timestamp` | Date and time at which the event occurred. | Timestamp |
| 20 | `DiagnosticUrinaryCulture` | Urinary culture diagnostic information. | Text |
| 21 | `SIRSCritLeucos` | SIRS criterion related to leukocyte count. | Boolean / text |
| 22 | `Oligurie` | Indicates oliguria/reduced urine output. | Boolean / text |
| 23 | `DiagnosticLacticAcid` | Lactic acid diagnostic measurement/result. | Numeric / text |
| 24 | `lifecycle:transition` | Records the lifecycle transition of the event. | Text |
| 25 | `Diagnose` | Diagnosis associated with the case. | Text |
| 26 | `Hypoxie` | Indicator related to hypoxia/low blood oxygen. | Boolean / text |
| 27 | `DiagnosticUrinarySediment` | Urinary sediment diagnostic information. | Text |
| 28 | `DiagnosticECG` | ECG diagnostic test information/result. | Text |
| 29 | `case:concept:name` | Unique case identifier used to group events into process traces. | Numeric / identifier |
| 30 | `Leucocytes` | Leukocyte/white blood cell laboratory measurement. | Numeric |
| 31 | `CRP` | C-reactive protein laboratory measurement. | Numeric |
| 32 | `LacticAcid` | Lactic acid laboratory measurement. | Numeric |

**Technical/Index Column**

| Column Name | Description | Data Type / Format |
|---|---|---|
| `Unnamed: 0` | Technical/index column present in the CSV file; not treated as a substantive dataset field. | Numeric / index |
 
**Column Count Verification:**  
- Total CSV columns: **33**
- Substantive dataset fields: **32**
- Technical/index column: **`Unnamed: 0`**

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

## 7. Dataset Source and Citation

**Dataset:** Sepsis Cases - Event Log  
**Creator:** Felix Mannhardt  
**Publisher:** 4TU.ResearchData  
**Version:** 1  
**Official Source:** https://data.4tu.nl/articles/_/12707639/1  
**DOI:** 10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460  
**Licence:** 4TU General Terms of Use  

The dataset is used for the CareFlow clinical pathway process-mining analysis. The official 4TU.ResearchData source and DOI are retained for attribution and dataset identification.

## 8. Usage and Redistribution Terms

The dataset is provided under the **4TU General Terms of Use**.

According to Section 4, part or all of the dataset may be distributed to third parties, provided that the source and rights-holder/Creator are acknowledged. Any subsequent distribution must also include the source acknowledgement.

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
| Raw dataset for GitHub | Permitted under the 4TU General Terms of Use, subject to the stated conditions |

--
## 11. Verification Status

The `Sepsis Cases - Event Log.csv` schema was verified against the 32 substantive fields documented in this data dictionary.

### Verification Evidence

- All 32 substantive field names were compared directly with the actual CSV header row.
- All 32 substantive field names match the actual CSV headers.
- `Unnamed: 0` is documented separately as the technical/index column.
- The three core process-mining fields were verified:
  - `case:concept:name`
  - `concept:name`
  - `time:timestamp`
- The official 4TU.ResearchData source URL was verified and restored.
- The dataset citation and DOI were verified.
- The licence was verified as 4TU General Terms of Use.
- Redistribution terms were documented consistently without duplicate status statements.
- No dataset rows or original values were modified.

Verification date: 27 October 2026
