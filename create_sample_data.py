
import pandas as pd

events = [
    ["C001", "Registration", "2026-10-01 09:00:00"],
    ["C001", "Triage", "2026-10-01 09:15:00"],
    ["C001", "Doctor Consultation", "2026-10-01 09:40:00"],
    ["C001", "Lab Test", "2026-10-01 10:00:00"],
    ["C001", "Discharge", "2026-10-01 11:00:00"],

    ["C002", "Registration", "2026-10-01 09:10:00"],
    ["C002", "Triage", "2026-10-01 09:25:00"],
    ["C002", "Doctor Consultation", "2026-10-01 09:50:00"],
    ["C002", "Discharge", "2026-10-01 10:30:00"],

    ["C003", "Registration", "2026-10-01 10:00:00"],
    ["C003", "Triage", "2026-10-01 10:20:00"],
    ["C003", "Doctor Consultation", "2026-10-01 10:45:00"],
    ["C003", "Lab Test", "2026-10-01 11:00:00"],
    ["C003", "Doctor Consultation", "2026-10-01 11:40:00"],
    ["C003", "Discharge", "2026-10-01 12:10:00"],

    ["C004", "Registration", "2026-10-01 11:00:00"],
    ["C004", "Triage", "2026-10-01 11:12:00"],
    ["C004", "Doctor Consultation", "2026-10-01 11:35:00"],
    ["C004", "Discharge", "2026-10-01 12:00:00"],
]

df = pd.DataFrame(
    events, columns=["Case_ID", "Activity_Name", "Timestamp"]
)
df["Timestamp"] = pd.to_datetime(df["Timestamp"])
df.to_csv("sample_event_log.csv", index=False)

print("Sample event log created successfully!")
print(f"Cases: {df['Case_ID'].nunique()}")
print(f"Events: {len(df)}")
print(df.head())
