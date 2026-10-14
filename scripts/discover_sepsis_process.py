
from pathlib import Path
import pandas as pd
import pm4py

BASE_DIR = Path(__file__).resolve().parent.parent
SOURCE = BASE_DIR / "sepsis_event_log.csv"
OUTPUT_DIR = BASE_DIR / "outputs"
REPORT_DIR = BASE_DIR / "reports"

CASE = "case:concept:name"
ACTIVITY = "concept:name"
TIMESTAMP = "time:timestamp"
REQUIRED = [CASE, ACTIVITY, TIMESTAMP]


def main():
    if not SOURCE.exists():
        raise FileNotFoundError(f"Dataset not found: {SOURCE}")

    OUTPUT_DIR.mkdir(exist_ok=True)
    REPORT_DIR.mkdir(exist_ok=True)

    # Preserve the source and work only on a separate DataFrame.
    original = pd.read_csv(SOURCE, low_memory=False)
    missing_columns = [c for c in REQUIRED if c not in original.columns]
    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    initial_rows = len(original)
    missing_case = int(original[CASE].isna().sum())
    missing_activity = int(original[ACTIVITY].isna().sum())

    work = original[REQUIRED].copy()
    work[TIMESTAMP] = pd.to_datetime(
        work[TIMESTAMP], errors="coerce", utc=True
    )
    invalid_timestamp = int(work[TIMESTAMP].isna().sum())

    # Exclude unusable events only from this working copy.
    work = work.dropna(subset=REQUIRED).copy()
    usable_before_dedup = len(work)

    # Remove exact duplicates among the three model fields.
    # Record the count; never modify the source CSV.
    duplicate_model_rows = int(work.duplicated().sum())
    work = work.drop_duplicates().copy()

    work = work.sort_values(
        [CASE, TIMESTAMP], kind="stable"
    ).reset_index(drop=True)

    if work.empty:
        raise ValueError("No usable events remain for process discovery.")

    prepared_path = OUTPUT_DIR / "prepared_sepsis_event_log.csv"
    work.to_csv(prepared_path, index=False)

    # PM4Py expects case, activity, and timestamp columns.
    event_log = pm4py.convert_to_event_log(
        work,
        case_id_key=CASE,
        activity_key=ACTIVITY,
        timestamp_key=TIMESTAMP,
    )

    process_tree = pm4py.discover_process_tree_inductive(event_log)
    tree_path = OUTPUT_DIR / "sepsis_process_tree.png"
    pm4py.save_vis_process_tree(process_tree, str(tree_path))

    case_count = work[CASE].nunique()
    activity_count = work[ACTIVITY].nunique()
    event_count = len(work)

    summary = [
        "CAREFLOW — INITIAL SEPSIS PROCESS DISCOVERY",
        "=" * 48,
        f"Source rows: {initial_rows:,}",
        f"Rows with missing case IDs: {missing_case:,}",
        f"Rows with missing activity names: {missing_activity:,}",
        f"Rows with invalid/missing timestamps: {invalid_timestamp:,}",
        f"Usable rows before deduplication: {usable_before_dedup:,}",
        f"Duplicate model-field rows removed: {duplicate_model_rows:,}",
        f"Events in working log: {event_count:,}",
        f"Cases in working log: {case_count:,}",
        f"Activities in working log: {activity_count:,}",
        "",
        "Model: Inductive Miner process tree",
        f"Prepared log: {prepared_path.relative_to(BASE_DIR)}",
        f"Visualization: {tree_path.relative_to(BASE_DIR)}",
        "",
        "Limitations:",
        "- Events without case, activity, or valid timestamp are excluded.",
        "- Duplicate removal applies only to the three model fields.",
        "- Original source CSV was not modified.",
        "- Source documentation says timestamps were randomized.",
        "- Do not interpret calendar trends as real clinical trends.",
        "- This is an initial discovered model, not a clinical conclusion.",
    ]

    report_path = REPORT_DIR / "sepsis_process_discovery_summary.txt"
    report_path.write_text("\n".join(summary) + "\n", encoding="utf-8")

    print("\n".join(summary))
    print("\nProcess tree saved successfully.")


if __name__ == "__main__":
    main()
