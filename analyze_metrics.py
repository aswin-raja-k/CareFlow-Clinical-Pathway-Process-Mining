
import pandas as pd

df = pd.read_csv("sample_event_log.csv")
df["Timestamp"] = pd.to_datetime(df["Timestamp"])
df = df.sort_values(["Case_ID", "Timestamp"])

# Time between consecutive activities in each case
df["Previous_Activity"] = df.groupby("Case_ID")["Activity_Name"].shift(1)
df["Waiting_Minutes"] = (
    df.groupby("Case_ID")["Timestamp"].diff().dt.total_seconds() / 60
)

transitions = df.dropna(subset=["Previous_Activity"]).copy()

transition_summary = (
    transitions.groupby(["Previous_Activity", "Activity_Name"])
    ["Waiting_Minutes"]
    .agg(Event_Count="count", Average_Wait_Minutes="mean",
         Maximum_Wait_Minutes="max")
    .reset_index()
    .sort_values("Average_Wait_Minutes", ascending=False)
)

# Total elapsed time for each case
case_summary = df.groupby("Case_ID")["Timestamp"].agg(
    Start_Time="min", End_Time="max"
).reset_index()

case_summary["Duration_Minutes"] = (
    case_summary["End_Time"] - case_summary["Start_Time"]
).dt.total_seconds() / 60

# Save reports
transition_summary.to_csv("transition_waiting_times.csv", index=False)
case_summary.to_csv("case_duration_report.csv", index=False)

print("\n=== Average waiting time by transition ===")
print(transition_summary.to_string(index=False))

print("\n=== Case duration report ===")
print(case_summary.to_string(index=False))

print("\nReports saved successfully!")
