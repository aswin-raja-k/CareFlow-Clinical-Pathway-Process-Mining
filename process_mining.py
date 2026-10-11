
import pandas as pd
import pm4py

# Load the synthetic event log
df = pd.read_csv("sample_event_log.csv")
df["Timestamp"] = pd.to_datetime(df["Timestamp"])

# Convert data into a PM4Py event log
event_log = pm4py.format_dataframe(
    df,
    case_id="Case_ID",
    activity_key="Activity_Name",
    timestamp_key="Timestamp"
)

# Discover the process model
process_tree = pm4py.discover_process_tree_inductive(event_log)

# Export the model as a PNG image
pm4py.save_vis_process_tree(
    process_tree,
    "careflow_sample_process_tree.png"
)

# Calculate total duration for each case
case_times = df.groupby("Case_ID")["Timestamp"].agg(
    start="min", end="max"
)
case_times["duration_minutes"] = (
    case_times["end"] - case_times["start"]
).dt.total_seconds() / 60

print("\nCase duration (minutes):")
print(case_times[["duration_minutes"]])

# Find repeated activities within each case
repeats = df.groupby(["Case_ID", "Activity_Name"]).size()
repeats = repeats[repeats > 1]

print("\nRepeated activities:")
print(repeats if not repeats.empty else "None found")

print("\nProcess tree saved as careflow_sample_process_tree.png")
