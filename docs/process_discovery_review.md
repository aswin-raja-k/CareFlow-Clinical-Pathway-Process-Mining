# Process Discovery Review and Team Decisions

**Project:** CareFlow — Clinical Pathway Process Mining  
**Date:** 15 October 2026  
**Branch:** `aswin-process-mining-dashboard`  
**Status:** Initial review documented; team verification pending

## 1. Process Discovery Review

The initial PM4Py process-discovery workflow was implemented and committed in `d044faa`.

The workflow generates a prepared event log, a process-tree visualization, and a process-discovery summary.

**Review checklist:**
- [ ] Inspect the generated process tree for understandable activity paths and branching.
- [ ] Verify the discovery summary against the prepared event log.
- [ ] Review the discovered model with the team before interpreting it.

The discovered process tree is an initial model for exploration, not a confirmed clinical pathway or evidence of hospital performance.

## 2. Dataset and Data-Quality Findings

The initial validation reported:

| Check | Finding |
|---|---:|
| Source rows | 15,214 |
| Rows missing case IDs | 24 |
| Missing activity names | 0 |
| Missing or invalid timestamps | 0 |
| Exact duplicate full rows | 1 |
| Rows with all required fields usable before deduplication | 15,190 |
| Duplicate combinations of the three process-mining fields removed from the working copy | 7 |
| Events in the prepared log | 15,183 |
| Cases in the prepared log | 1,049 |
| Activities in the prepared log | 16 |

The seven duplicate combinations refer to the case ID, activity and timestamp fields. They are not necessarily seven exact duplicate rows in the original dataset.

The original dataset must remain unchanged. Cleaning and deduplication apply only to the working copy.

**Timestamp limitation:** The source documentation states that timestamps are randomized. Calendar-based trend analysis and conclusions about real-world clinical timing must therefore be avoided.

## 3. Proposed Event-Log Preparation Rules

The team should review and agree on these rules before finalizing cleaning decisions:

1. Preserve the original downloaded dataset unchanged.
2. Keep the raw dataset out of GitHub until redistribution terms have been checked; do not commit it.
3. Use `case:concept:name`, `concept:name` and `time:timestamp` as the core process-mining fields.
4. Exclude records missing required fields from the prepared working copy, and document the number removed and the reason.
5. Remove duplicate combinations of the three core fields only in the working copy, while recording the rule and count.
6. Sort events by case ID and timestamp before process discovery.
7. Retain a clear record of every cleaning step so the workflow is reproducible.
8. Treat discovered patterns as exploratory findings, not clinical conclusions.

**Decision status:** Proposed rules; team agreement is pending.

## 4. Team Deliverable Review

| Team member | Assigned area | Review status |
|---|---|---|
| Poojitha | Dataset preparation and documentation | Verify documentation against the actual CSV headers, source details and redistribution terms. |
| Prasuna | Data validation and quality report | Check that reported counts match the validation results and limitations. |
| Srivaishnavi | SQL analysis and KPI tables | Verify database execution, result counts and KPI calculations against the actual dataset. |
| Team lead | Process discovery and integration | Review outputs, coordinate preparation rules and plan integration after team review. |

These are review actions, not claims that all teammates' deliverables have already been verified.

## 5. Blockers and Risks

- Team agreement on preparation and deduplication rules is still required.
- Dataset documentation and data-quality findings need cross-checking before integration.
- SQL analysis results need execution and validation against the actual dataset.
- Redistribution terms for the source dataset must be checked before sharing raw data.
- Randomized timestamps limit calendar-based analysis and interpretation of elapsed-time findings.

## 6. Next Integration Steps

1. Review each teammate's deliverables and latest commits on their assigned branch.
2. Record corrections and blockers in the relevant project issues.
3. Agree on the event-log preparation rules and document the final decisions.
4. Verify that the process-discovery outputs can be reproduced from the prepared event log.
5. Review SQL results and data-quality findings against the same agreed preparation rules.
6. Review the complete set of deliverables as a team before integrating branches.
7. Merge into `main` only after the team review is complete.

## 7. Git and Data-Safety Rules

- Work on `aswin-process-mining-dashboard` for this task.
- Commit meaningful documentation and code changes to the assigned branch.
- Do not commit the raw dataset or unapproved data extracts.
- Do not merge into `main` before team review and approval.

**Deliverable:** Initial process-discovery review, proposed preparation rules, team review checklist, blockers and integration plan.

## 8. Follow-up Review — 21 October 2026

### Output verification

The generated process-discovery summary and required output files were checked.

- **Source rows:** 15,214
- **Rows with missing case IDs:** 24
- **Rows with missing activity names:** 0
- **Rows with missing or invalid timestamps:** 0
- **Usable rows before deduplication:** 15,190
- **Duplicate model-field rows removed:** 7
- **Events in the prepared working log:** 15,183
- **Cases in the working log:** 1,049
- **Activities in the working log:** 16

### Generated artifacts

- `outputs/sepsis_process_tree.png` — confirmed to exist.
- `outputs/prepared_sepsis_event_log.csv` — confirmed to exist.
- `reports/sepsis_process_discovery_summary.txt` — reviewed.

The summary identifies the Inductive Miner process tree as the discovery method and records the preparation limitations.

### Review outcome

The summary counts are consistent with the previously recorded validation figures. The visualization's existence was verified, but detailed interpretation of its branches remains pending.

The prepared log is a derived working copy. The original dataset remains unchanged and must not be committed to GitHub.

### Outstanding actions

1. Review the process-tree branches and activity paths.
2. Obtain team agreement on event-log preparation and deduplication rules.
3. Verify the teammates' data-quality and SQL results.
4. Complete team review before planning any integration into `main`.

**Status:** Output existence and summary review completed; visual interpretation and team approval remain pending.

## 9. Visual Process-Tree Review — 23 October 2026

### Initial structural observations

The generated Inductive Miner process tree contains sequential (`seq`), parallel (`and`), exclusive-choice (`xor`), and loop (`xor loop`) operators.

Visible activities include ER Registration, Admission NC, ER Triage, ER Sepsis Triage, IV Antibiotics, IV Liquid, Leucocytes, CRP, LacticAcid, Return ER, and release activities.

### Interpretation limitations

These observations describe the structure of the discovered model only. They do not establish actual clinical decisions, causes of repeated activities, or confirmed hospital bottlenecks.

Further validation is required against the prepared event log and team-agreed event-log preparation rules.

**Status:** Initial visual inspection completed; detailed path validation and team review remain pending.

## 10. Team Validation and Integration Checklist — 26 October 2026

### Validation baseline

The initial Python validation recorded:

- Source rows: 15,214
- Rows with missing case IDs: 24
- Usable rows before deduplication: 15,190
- Duplicate model-field rows removed: 7
- Events in the prepared working log: 15,183
- Cases in the working log: 1,049
- Activities in the working log: 16

These are Python validation and process-discovery figures. SQL results must be independently verified before declaring the analyses reconciled.

### Team review requirements

- **Dataset documentation:** Verify the documented fields against the actual CSV headers and confirm the source and redistribution terms.
- **SQL analysis:** Verify actual MySQL query outputs, duplicate definitions, and all five KPIs against the documented validation rules.
- **Data quality:** Reconcile exact duplicate rows with repeated case/activity/timestamp combinations and document any remaining SQL discrepancies.
- **Process mining:** Review the discovered process-tree paths and confirm the event-log preparation rules with the team.

### Integration safeguards

1. Keep each teammate's work on their assigned branch until reviewed.
2. Do not commit the raw source CSV or the local prepared CSV.
3. Do not merge into `main` until documentation, SQL results, and data-quality findings have been reviewed.
4. Record unresolved discrepancies explicitly rather than treating them as verified results.

### Current status

The initial process-discovery output and visual structure have been documented. Team verification of SQL outputs, dataset documentation, data-quality findings, and preparation rules remains necessary before integration.

**Status:** Integration pending team validation and review.

## 11. Team Deliverable Review — 27 October 2026

### Dataset documentation — Poojitha

The latest reviewed commit (`61d556d`) updates the source, citation and redistribution section in `data_dictionary.md`. The direct official source URL was no longer found in the file during review.

**Required follow-up:** Restore the official dataset source URL and provide evidence that all 32 substantive field names match the CSV headers.

**Status:** Correction requested; review pending.

### Data quality — Prasuna

The reviewed `event_log_quality_review.md` documents:

- Source rows: 15,214
- Missing or blank case IDs: 24
- Distinct nonblank case IDs: 1,049
- Exact duplicate full rows after excluding the export-only index: one repeated occurrence across two rows
- Repeated case/activity/timestamp combinations: seven groups affecting 14 rows
- Missing activity names and timestamps: zero

The report explicitly states that SQL reconciliation remains pending because the actual SQL database results have not been independently verified against the same source dataset.

**Status:** Findings documented; independent SQL reconciliation pending.

### SQL analysis — Srivaishnavi

The reviewed SQL report documents 15,214 source and destination rows, 1,049 valid cases, 15,190 valid events, 16 activities and five KPI categories.

Review of `sql/sepsis_analysis.sql` identified a filtering inconsistency:

- KPI 1 excludes placeholder case IDs such as `NA`, `N/A`, `NAN`, `NULL` and `NONE`.
- KPI 2 (average case duration) excludes NULL and blank case IDs but does not exclude those placeholders.
- KPI 3 (average time between consecutive events) has the same filtering inconsistency.

**Required follow-up:** Apply consistent valid-case filtering to KPI 2 and KPI 3, execute the corrected queries in MySQL Workbench, and update the report with verified outputs.

**Status:** Correction requested; corrected KPI results and execution evidence pending.

### Process-mining prototype — Team lead

The reviewed `process_mining.py`, `analyze_metrics.py` and `create_sample_data.py` use `sample_event_log.csv`, which is a synthetic dataset containing 19 events across four sample cases.

The current scripts demonstrate the initial PM4Py process-discovery workflow and prototype timing analysis. They do not, by themselves, demonstrate process discovery on the actual Sepsis event log.

**Required follow-up:** Validate the process-discovery workflow using the agreed prepared Sepsis event log, preserve the source dataset unchanged, and document the preparation rules and generated outputs.

### Integration decision

No team branch is approved for merging based solely on this review. Dataset documentation, SQL execution results, data-quality reconciliation and actual-dataset process discovery remain subject to verification.

**Status:** Integration pending evidence review and team approval.

## 12. Actual-Dataset Process Discovery — 28 October 2026

### Dataset validation

The prepared event log at `outputs/prepared_sepsis_event_log.csv` was inspected locally.

- Raw event-log rows: 15,214
- Prepared event rows: 15,183
- Prepared columns: `case:concept:name`, `concept:name`, `time:timestamp`
- Distinct valid cases: 1,049
- Distinct activities: 16
- Invalid case IDs in prepared data: 0
- Missing activity names: 0
- Missing timestamps: 0
- Repeated case/activity/timestamp groups in prepared data: 0

The prepared dataset contains 31 fewer rows than the raw event log. Local verification reconciled this difference: 24 rows had missing case IDs, and 7 rows were removed as duplicate combinations of case ID, activity and timestamp. No rows had missing activity names or invalid timestamps. The team must still confirm agreement on these preparation rules.

### Process discovery execution

The PM4Py Inductive Miner process-discovery workflow was executed successfully against the prepared event log.

- PM4Py version: 2.7.23.9
- Pandas version: 3.0.6
- Events processed: 15,183
- Cases processed: 1,049
- Activities identified: 16
- Generated visualization: `outputs/sepsis_process_tree.png`

The generated process tree was opened and visually inspected. It contains sequential (`seq`), parallel (`and`), exclusive-choice (`xor`), and loop (`xor loop`) operators.

### Interpretation and limitations

This is an initial discovered process model, not a confirmed clinical pathway. The model requires further path validation and team review.

The dataset documentation states that timestamps were randomized while preserving intervals within individual traces. Calendar dates must not be interpreted as authentic hospital dates, and time-based findings must be described with this limitation.

### Next steps

- Obtain team review of the verified row-count reconciliation and confirm agreement on the preparation rules.
- Review discovered paths and process variants.
- Compare SQL and Python results only after confirming equivalent filtering rules and KPI definitions.
- Keep generated outputs and raw/prepared data separate from source files; do not commit `sepsis_event_log.csv` or `outputs/prepared_sepsis_event_log.csv`.

**Status:** Actual-dataset process discovery executed successfully; preparation reconciliation and team validation remain pending.
