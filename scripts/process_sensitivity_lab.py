from pathlib import Path
from collections import Counter

import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
SOURCE = BASE_DIR / "sepsis_event_log.csv"
OUTPUT_DIR = BASE_DIR / "outputs" / "run_20261105"

CASE = "case:concept:name"
ACTIVITY = "concept:name"
TIMESTAMP = "time:timestamp"


def calculate_metrics(data, scenario):
    data = data.sort_values(
        [CASE, TIMESTAMP], kind="stable"
    )

    variants = data.groupby(CASE)[ACTIVITY].apply(tuple)
    variant_counts = Counter(variants)

    repeated = data.groupby([CASE, ACTIVITY]).size()
    repeated = repeated[repeated > 1]

    return {
        "Scenario": scenario,
        "Events": len(data),
        "Cases": data[CASE].nunique(),
        "Activities": data[ACTIVITY].nunique(),
        "Unique variants": len(variant_counts),
        "Cases with repeated activities":
            repeated.index.get_level_values(0).nunique(),
        "Extra repeated occurrences": int((repeated - 1).sum()),
    }


def main():
    if not SOURCE.exists():
        raise FileNotFoundError(SOURCE)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(SOURCE, low_memory=False)

    required = [CASE, ACTIVITY, TIMESTAMP]
    missing = [column for column in required if column not in df.columns]

    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    work = df[required].copy()

    work[TIMESTAMP] = pd.to_datetime(
        work[TIMESTAMP], errors="coerce", utc=True
    )

    work = work.dropna(subset=required).copy()

    scenario_a = work.copy()

    scenario_b = work.drop_duplicates(
        subset=required
    ).copy()

    results = pd.DataFrame([
        calculate_metrics(
            scenario_a, "A - Retain repeated model rows"
        ),
        calculate_metrics(
            scenario_b, "B - Remove repeated model rows"
        ),
    ])

    output_file = OUTPUT_DIR / "process_sensitivity_comparison.csv"
    results.to_csv(output_file, index=False)

    print("\nCAREFLOW PROCESS SENSITIVITY LAB")
    print("=" * 45)
    print(results.to_string(index=False))
    print(f"\nResults saved: {output_file.relative_to(BASE_DIR)}")

    print("\nLIMITATION:")
    print("Timestamp-based pathway ordering is exploratory.")
    print("Source documentation says timestamps were randomized.")


if __name__ == "__main__":
    main()
