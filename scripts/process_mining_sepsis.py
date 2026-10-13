
from pathlib import Path
import pandas as pd

# CareFlow: Sepsis event-log validation
BASE_DIR = Path(__file__).resolve().parent.parent
CSV_PATH = BASE_DIR / "sepsis_event_log.csv"
REPORT_DIR = BASE_DIR / "reports"
REPORT_PATH = REPORT_DIR / "sepsis_validation_report.txt"

CASE = "case:concept:name"
ACTIVITY = "concept:name"
TIMESTAMP = "time:timestamp"


def main():
    if not CSV_PATH.exists():
        raise FileNotFoundError(
            f"Dataset not found: {CSV_PATH}\n"
            "Place the approved CSV in the repository root."
        )

    df = pd.read_csv(CSV_PATH, low_memory=False)

    required = [CASE, ACTIVITY, TIMESTAMP]
    missing_columns = [col for col in required if col not in df.columns]

    if missing_columns:
        raise ValueError(
            f"Required event-log columns missing: {missing_columns}\n"
            f"Available columns: {df.columns.tolist()}"
        )

    # Preserve the original data; analyse a separate copy.
    original = df.copy()
    analysis = df.copy()

    analysis[TIMESTAMP] = pd.to_datetime(
        analysis[TIMESTAMP], errors="coerce", utc=True
    )

    missing_cases = analysis[CASE].isna().sum()
    missing_activities = analysis[ACTIVITY].isna().sum()
    missing_timestamps = analysis[TIMESTAMP].isna().sum()
    duplicate_rows = analysis.duplicated().sum()

    valid_cases = analysis[CASE].notna()
    valid_activities = analysis[ACTIVITY].notna()
    valid_timestamps = analysis[TIMESTAMP].notna()

    usable = analysis[
        valid_cases & valid_activities & valid_timestamps
    ].copy()

    # Check whether events were already chronologically ordered
    # within each case in the original CSV.
    ordered = usable.sort_values(
        [CASE, TIMESTAMP], kind="stable"
    )
    chronological_issues = 0

    for _, group in usable.groupby(CASE, sort=False):
        times = group[TIMESTAMP]
        chronological_issues += int((times.diff().dropna() < pd.Timedelta(0)).sum())

    REPORT_DIR.mkdir(exist_ok=True)

    lines = [
        "CAREFLOW — SEPSIS EVENT-LOG VALIDATION",
        "=" * 42,
        f"CSV file: {CSV_PATH.name}",
        f"Total rows: {len(original):,}",
        f"Total columns: {len(original.columns)}",
        f"Unique non-null case IDs: {analysis[CASE].nunique():,}",
        f"Unique non-null activities: {analysis[ACTIVITY].nunique():,}",
        f"Missing case IDs: {missing_cases:,}",
        f"Missing activity names: {missing_activities:,}",
        f"Missing or invalid timestamps: {missing_timestamps:,}",
        f"Duplicate full rows: {duplicate_rows:,}",
        f"Rows with all three required fields usable: {len(usable):,}",
        f"Within-case chronological inversions: {chronological_issues:,}",
        "",
        "Timestamp limitation:",
        "The source documentation states that timestamps were",
        "randomised. Interpret calendar-based conclusions cautiously.",
        "",
        "No source records were deleted or overwritten by this script.",
        "Cleaning decisions and process discovery remain pending review.",
    ]

    if not usable.empty:
        lines.extend([
            f"Earliest usable timestamp: {usable[TIMESTAMP].min()}",
            f"Latest usable timestamp: {usable[TIMESTAMP].max()}",
        ])

    REPORT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("\n".join(lines))
    print(f"\nReport saved to: {REPORT_PATH}")


if __name__ == "__main__":
    main()
