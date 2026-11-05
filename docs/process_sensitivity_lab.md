# CareFlow — Process Discovery and Sensitivity Analysis



**Date:** 5 November 2026



## 1. Objective



Develop an initial PM4Py process discovery pipeline and evaluate how duplicate-handling decisions affect process-mining metrics.



## 2. Dataset profile



| Metric | Result |

|---|---:|

| Source events | 15,214 |

| Events with missing case IDs | 24 |

| Usable events | 15,190 |

| Cases | 1,049 |

| Activities | 16 |



## 3. Process discovery



- Process discovery algorithm: Inductive Miner.

- Prepared events after removing duplicate model-field combinations: 15,183.

- Generated process tree visualization.

- Measured 844 unique timestamp-ordered pathway variants.



## 4. Process Sensitivity Lab



Two preparation scenarios were compared.



| Metric | Scenario A: Retain | Scenario B: Remove |

|---|---:|---:|

| Events | 15,190 | 15,183 |

| Cases | 1,049 | 1,049 |

| Activities | 16 | 16 |

| Unique variants | 845 | 844 |

| Cases with repeated activities | 743 | 742 |

| Extra repeated occurrences | 5,610 | 5,603 |



### Findings



Removing seven repeated Case ID + Activity + Timestamp combinations resulted in:

- Seven fewer events.

- One fewer unique pathway variant.

- One fewer case with repeated activities.

- Seven fewer extra repeated occurrences.



Repeated activities are not automatically data errors and were retained in both scenarios.



## 5. Generated artifacts



- `scripts/discover\_sepsis\_process.py`

- `scripts/process\_sensitivity\_lab.py`

- `outputs/run\_20261105/sepsis\_process\_tree.png`

- `outputs/run\_20261105/process\_sensitivity\_comparison.csv`

- `reports/run\_20261105/sepsis\_process\_discovery\_summary.txt`



## 6. Limitations



- Source documentation states that timestamps were randomized.

- Timestamp-based pathway ordering is exploratory and must not be interpreted as reliable clinical chronology.

- The discovered process tree is not a clinically validated pathway.

- Duplicate removal applies to the three PM4Py model fields, not necessarily complete original rows.

- Repeated activities may represent legitimate repeated events.

- The seven-row difference between the scenarios is a preparation sensitivity result, not proof of data corruption.



## 7. Next steps



1\. Validate preparation rules with the Excel and SQL team members.

2\. Reconcile the 742 versus 743 repeated-activity case count.

3\. Expand sensitivity analysis with additional defensible preparation scenarios.

4\. Integrate validated metrics into the Power BI dashboard.

