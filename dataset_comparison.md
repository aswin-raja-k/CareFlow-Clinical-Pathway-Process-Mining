# CareFlow – Dataset Comparison

## Objective
To select a suitable public healthcare event log for clinical pathway process mining.

## Dataset 1: Sepsis Cases – Event Log
- **Source:** 4TU.ResearchData
- **Official Source URL:** https://data.4tu.nl/articles/_/12707639/1
- **DOI:** 10.4121/uuid:915d2bfb-7e84-49ad-a286-dc35f063a460
- **Cases:** Approximately 1,050
- **Events:** Approximately 15,214
- **Activities:** 16
- **Format:** CSV (confirm the downloaded file format)
- **License/Terms:** 4TU General Terms of Use (check the terms before redistributing the file)
- **Limitations:** Timestamps were randomized, so the dataset should not be used to draw conclusions about actual calendar dates or real-world hospital performance.

## Dataset 2: Hospital Dataset
- **Dataset Name:** Hospital Dataset
- **Official Source URL:** Add the original download/source link
- **DOI:** Add the DOI if available; otherwise, write “Not available”
- **Format:** Excel (.xlsx)
- **Number of Cases/Events:** Verify from the dataset
- **Required Columns Available:** Verify Case ID, Activity, and Timestamp
- **License/Terms:** Check the original source's license or terms of use
- **Data Quality Observations:** Check for missing values, duplicate records, and inconsistent timestamps
- **Limitations:** Document any limitations found during inspection

## Comparison
Compare both datasets based on the following criteria:

1. Availability of Case ID, Activity, and Timestamp fields.
2. Multiple events recorded for each case.
3. Missing values and duplicate records.
4. Timestamp consistency and chronological ordering.
5. Public source availability and usage terms.
6. Suitability for clinical pathway process mining.

## Recommendation

- **Selected Dataset:** Sepsis Cases – Event Log
- **Reason:** It is a healthcare event log containing multiple patient-related activities and timestamps. Its event-based structure supports process mining and analysis of activity sequences and possible workflow bottlenecks.
- **Limitations:** The timestamps were randomized. Missing values and duplicate records in the downloaded CSV should also be checked and documented before analysis.
- **Final Status:** FINALIZED – SELECTED FOR CAREFLOW PROJECT ANALYSIS

## Conclusion
After considering the available dataset options, the Sepsis Cases – Event Log dataset was selected for the CareFlow project. The second dataset is retained as a comparison candidate. Before analysis, the selected dataset's structure, data quality, and usage terms should be verified and documented.
