# CareFlow – Dataset Comparison and Selection Rationale

## Objective

Compare candidate datasets and document why the team selected the Sepsis Cases – Event Log for the CareFlow Clinical Pathway Process Mining project.

## Dataset 1: Sepsis Cases – Event Log

- **Creator:** Felix Mannhardt
- **Year / version:** 2016, Version 1
- **Official source:** https://data.4tu.nl/articles/_/12707639/1
- **DOI:** https://doi.org/10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- **Repository / publisher:** 4TU.ResearchData / Eindhoven University of Technology
- **Usage terms:** 4TU General Terms of Use; review before redistribution.
- **Officially described scale:** About 1,000 cases, approximately 15,000 events, and 16 activity types.
- **Attributes / columns:** The official record describes 39 data attributes for the original event log. The public tabular representation checked for this documentation exposes 32 columns; the exact selected CSV header still needs to be compared directly.
- **Suitability:** Contains case identifiers, activity labels, timestamps, and additional clinical/organizational attributes, which support event-log analysis and process discovery.
- **Limitation:** Timestamps were randomized, but within-case intervals were preserved. Do not infer real calendar trends or claim definitive hospital performance from calendar dates.

## Dataset 2: Hospital Dataset

- **Dataset name:** Hospital Dataset (`hospital_data_sampleee(2).xlsx` was the candidate filename previously shared)
- **Official source URL:** **Unverified** — add the original source page, not a re-upload link.
- **DOI:** **Unverified / not provided**
- **Format:** Excel (.xlsx), based on the candidate file name.
- **Case ID, activity, timestamp fields:** **Must be checked against the actual file headers.**
- **Cases/events:** **Unverified** — count from the file after inspection.
- **Usage terms/license:** **Unverified** — do not redistribute until source and permission are confirmed.
- **Data quality:** **Not assessed here**; the assigned quality investigation belongs to the designated data-quality owner.

## Comparison

| Criterion | Sepsis Cases – Event Log | Hospital Dataset |
|---|---|---|
| Public source | Official 4TU.ResearchData record located | Official source not yet documented |
| DOI / citation | DOI and citation verified against official record | Unverified |
| Case identifier | Public tabular representation has `case:concept:name`; confirm exact CSV header | Verify actual column |
| Activity | Public tabular representation has `concept:name`; confirm exact CSV header | Verify actual column |
| Timestamp | Public tabular representation has `time:timestamp`; confirm exact CSV header | Verify actual column |
| Multiple events per case | Event-log structure is designed around case pathways | Must be verified |
| Number of cases/events | Official record reports about 1,000 cases and 15,000 events | Must be counted |
| Data quality | No new quality check performed in this documentation review | Not assessed |
| Usage terms | 4TU General Terms of Use; review redistribution terms | Unverified |
| Timestamp caveat | Randomized timestamps; within-case intervals preserved | Must be verified |
| Process-mining fit | Good structural fit as a healthcare event log | Cannot conclude until structure/source are verified |

## Recommendation

**Selected dataset: Sepsis Cases – Event Log**

**Reason for selection:** The official source describes a real-life healthcare event log with case pathways, multiple activities, timestamps, and additional clinical/organizational attributes. The available tabular representation includes the three core process-mining fields (`case:concept:name`, `concept:name`, and `time:timestamp`). This makes it structurally suitable for process discovery and analysis of within-case activity sequences.

**Limitations and cautions:**
- Event timestamps were randomized; do not use them to infer actual calendar trends or make definitive real-world hospital-performance claims.
- Confirm the selected local CSV has the expected 32-column schema before marking the file-level review complete.
- The original 4TU record describes 39 attributes in the original event log; the 32-column count refers to the inspected tabular representation.
- The second candidate’s official source, fields, counts, quality and usage terms remain unverified.
- Data cleaning and row deletion are outside this documentation review and must be handled by the assigned data-quality owner.

## Status

- Official Sepsis citation and DOI: **Verified**
- Usage-term label: **Verified; redistribution permission must be reviewed**
- Public tabular schema: **32 columns identified**
- Exact local selected CSV header/types: **Pending direct comparison**
- Second dataset details: **Partially/unverified**
- Data-quality findings: **Not assessed in this documentation task**
