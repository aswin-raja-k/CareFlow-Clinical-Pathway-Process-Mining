# CareFlow – Sepsis Dataset Source Documentation

## Source verification

- **Dataset title:** Sepsis Cases – Event Log
- **Creator:** Felix Mannhardt
- **Year / version:** 2016, Version 1
- **Repository / publisher:** 4TU.ResearchData; Eindhoven University of Technology
- **Official record:** https://data.4tu.nl/articles/_/12707639/1
- **DOI:** https://doi.org/10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- **Usage terms shown on the official record:** 4TU General Terms of Use
- **Verification note:** The title, citation, DOI, usage-term label, event-log description, and timestamp limitation were checked against the official 4TU.ResearchData record on 14 October 2026.

## Citation

Mannhardt, Felix (2016): *Sepsis Cases – Event Log*. Version 1. 4TU.ResearchData. Dataset. https://doi.org/10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460

## Use and redistribution

The source record lists the **4TU General Terms of Use**. Review the terms at https://data.4tu.nl/info/about-our-services/terms-of-use before redistributing the dataset or committing a full copy to a public repository. Do not describe the dataset as CC-BY unless the official record says so.

## Dataset description

The official record describes about 1,000 cases, approximately 15,000 events, 16 activity types, and anonymized events/attribute values. The record describes 39 data attributes for the original event log. A tabular representation inspected for this documentation exposes 32 columns; confirm the header row of the exact CSV selected by the team before treating the 32-column list as verified for that file.

## Timestamp limitation

The official record states that event timestamps were randomized, while the time between events within each trace was not altered. Therefore:
- Do not interpret the dates as reliable real-world calendar dates.
- Do not claim real calendar trends, shifts, weekdays, or seasonal patterns.
- Elapsed intervals within a case may be studied cautiously because within-trace intervals were preserved.
- Do not claim that process analysis proves actual hospital performance or a causal improvement.

## Status

- Official citation and DOI: **Verified against official record**
- Usage-term label: **Verified; redistribution permission must be reviewed before sharing the data file**
- Exact local CSV header and its storage types: **Pending comparison with the selected CSV file**
