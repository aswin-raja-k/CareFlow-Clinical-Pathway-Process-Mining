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