# CareFlow – Sepsis Cases Event Log Data Dictionary

## 1. Purpose

This data dictionary documents the fields in a 32-column tabular representation of the Sepsis Cases – Event Log and explains how they relate to clinical process mining.

**Verification boundary:** The public tabular schema lists the 32 columns below. The selected CSV file itself was not attached to this review, so the exact local CSV header and its inferred/imported data types must still be checked before marking the local-file verification complete. Data types below are the types shown by the public tabular representation; CSV readers may infer different types, especially when columns contain blanks.

## 2. Dataset reference

- **Title:** Sepsis Cases – Event Log
- **Creator:** Felix Mannhardt
- **Year / version:** 2016, Version 1
- **Official record:** https://data.4tu.nl/articles/_/12707639/1
- **DOI:** https://doi.org/10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- **Usage terms:** 4TU General Terms of Use
- **Important limitation:** The source says timestamps were randomized while within-case intervals were preserved.

## 3. Core process-mining fields

| Column | Meaning | Public schema type | Process-mining relevance |
|---|---|---|---|
| `case:concept:name` | Case identifier; groups events belonging to one patient pathway. | String | Required to group events into cases/traces. |
| `concept:name` | Activity label for the event, such as ER Registration, ER Triage, CRP, Leucocytes, IV Antibiotics, or discharge/release activities. | String / categorical | Required to discover activity sequences and process variants. |
| `time:timestamp` | Timestamp associated with an event. | Timestamp (UTC in public tabular schema) | Supports within-case event ordering and elapsed-interval analysis, subject to randomized timestamp limitation. |

## 4. All 32 columns

Descriptions for clinical indicators are plain-language interpretations of field names and the public tabular schema. Where a field’s precise operational definition is not explicitly stated in the schema, verify it against the source README or paper before making clinical claims.

| # | Column name | Meaning | Public schema type | Process-mining relevance / note |
|---:|---|---|---|---|
| 1 | `case:concept:name` | Identifier for a patient case/pathway. | String | Groups events into a trace; core field. |
| 2 | `InfectionSuspected` | Indicator that infection was suspected. | Boolean | Case/event context; may help describe pathways. Blank values must not automatically be treated as `false`. |
| 3 | `org:group` | Group or organizational unit associated with the event. | String / category | Can help compare activity routing or responsible groups; category codes need source interpretation. |
| 4 | `DiagnosticBlood` | Indicator associated with blood diagnostics. | Boolean | Context about diagnostic work; exact coding should be confirmed from source documentation. |
| 5 | `DisfuncOrg` | Indicator for organ dysfunction. | Boolean | Clinical context; not an activity name. Confirm exact definition in source documentation. |
| 6 | `SIRSCritTachypnea` | Indicator for the SIRS tachypnea (rapid breathing) criterion. | Boolean | Clinical context that may describe a case; confirm source definition. |
| 7 | `Hypotensie` | Indicator for hypotension (low blood pressure). | Boolean | Clinical context; confirm source definition. |
| 8 | `SIRSCritHeartRate` | Indicator for the SIRS heart-rate criterion. | Boolean | Clinical context; confirm source definition. |
| 9 | `Infusion` | Indicator associated with infusion treatment. | Boolean | Treatment context; the activity label may separately identify IV Liquid. |
| 10 | `DiagnosticArtAstrup` | Indicator associated with an arterial blood-gas/Astrup diagnostic test. | Boolean | Diagnostic context; verify terminology in source documentation. |
| 11 | `concept:name` | Name of the event/activity. | String / category | Core activity field; used to build the process map. |
| 12 | `Age` | Patient age recorded in the event log. | Float64 / numeric | Case context for descriptive analysis; not a process control field. |
| 13 | `DiagnosticIC` | Diagnostic indicator labelled “IC” in the source data. | Boolean | Meaning of the abbreviation is not fully specified by the public schema snippet; mark exact clinical meaning **unverified** until checked in the source README/paper. |
| 14 | `DiagnosticSputum` | Indicator associated with sputum diagnostics. | Boolean | Diagnostic context; confirm exact coding in source documentation. |
| 15 | `DiagnosticLiquor` | Indicator associated with liquor/CSF diagnostics. | Boolean | Diagnostic context; “Liquor” is used in some European medical terminology for cerebrospinal fluid; confirm source definition. |
| 16 | `DiagnosticOther` | Indicator for other diagnostic activity/category. | Boolean | Diagnostic context; exact category definition should be checked. |
| 17 | `SIRSCriteria2OrMore` | Indicator that two or more SIRS criteria were met. | Boolean | Clinical context; confirm source definition before interpreting medically. |
| 18 | `DiagnosticXthorax` | Indicator associated with chest X-ray diagnostics. | Boolean | Diagnostic context; confirm exact coding in source documentation. |
| 19 | `SIRSCritTemperature` | Indicator for the SIRS temperature criterion. | Boolean | Clinical context; confirm source definition. |
| 20 | `DiagnosticUrinaryCulture` | Indicator associated with urine-culture diagnostics. | Boolean | Diagnostic context; confirm exact coding in source documentation. |
| 21 | `SIRSCritLeucos` | Indicator for the SIRS leukocyte-count criterion. | Boolean | Clinical context; confirm source definition. |
| 22 | `Oligurie` | Indicator for oliguria (low urine output). | Boolean | Clinical context; confirm source definition. |
| 23 | `DiagnosticLacticAcid` | Indicator associated with lactic-acid diagnostics. | Boolean | Diagnostic context; activity field may also contain `LacticAcid`. |
| 24 | `lifecycle:transition` | Lifecycle stage/status for the event; the public examples show `complete`. | String / category | Can help interpret event lifecycle; confirm whether it is constant in the selected CSV. |
| 25 | `Diagnose` | Diagnosis label/category recorded in the source. | String / category | Case context; values may be coded/anonymized. Do not interpret codes without documentation. |
| 26 | `Hypoxie` | Indicator for hypoxia (low oxygen). | Boolean | Clinical context; confirm source definition. |
| 27 | `DiagnosticUrinarySediment` | Indicator associated with urinary-sediment diagnostics. | Boolean | Diagnostic context; confirm exact coding in source documentation. |
| 28 | `DiagnosticECG` | Indicator associated with electrocardiogram diagnostics. | Boolean | Diagnostic context; confirm exact coding in source documentation. |
| 29 | `Leucocytes` | Recorded leucocyte/white-blood-cell laboratory value. | Float64 / numeric | Event-level clinical measurement; values may be present only on relevant lab events. |
| 30 | `CRP` | Recorded C-reactive protein laboratory value. | Float64 / numeric | Event-level clinical measurement; values may be present only on relevant lab events. |
| 31 | `LacticAcid` | Recorded lactic-acid/lactate laboratory value. | Float64 / numeric | Event-level clinical measurement; values may be present only on relevant lab events. |
| 32 | `time:timestamp` | Timestamp associated with the event. | Timestamp (UTC in public tabular schema) | Core event-time field; use cautiously because timestamps were randomized. |

## 5. Important interpretation and type notes

1. The public tabular view reports Boolean types for the clinical indicator fields, strings for case/activity/category fields, numeric values for `Age`, `Leucocytes`, `CRP`, and `LacticAcid`, and a timestamp type for `time:timestamp`.
2. CSV imports can infer different types. Check the actual file with Excel or a data tool and record the type as imported if it differs.
3. Many fields can be blank on events where they do not apply or are not recorded. A blank is not automatically the same as `false`.
4. `case:concept:name`, `concept:name`, and `time:timestamp` are the three core fields for event-log structure.
5. The original 4TU record describes 39 data attributes for the original event log. This particular public tabular representation has 32 columns. Do not state that the original XES file has only 32 attributes.
6. No rows have been deleted or cleaned as part of this documentation. Data-quality investigation is assigned separately.

## 6. Source and limitation

Mannhardt, Felix (2016): *Sepsis Cases – Event Log*. Version 1. 4TU.ResearchData. https://doi.org/10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460

The official record says event timestamps were randomized while intervals between events within a trace were preserved. Do not use these timestamps to claim real calendar trends or definitive real-world hospital performance.
