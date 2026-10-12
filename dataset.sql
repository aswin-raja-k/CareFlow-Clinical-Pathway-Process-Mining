-- CareFlow: Clinical Pathway Process Mining
-- Step 2: Create database and patient table

CREATE DATABASE IF NOT EXISTS CareFlow;

USE CareFlow;

-- Create Patients table
CREATE TABLE IF NOT EXISTS Patients (
    Patient_ID INT PRIMARY KEY AUTO_INCREMENT,
    Patient_Name VARCHAR(100) NOT NULL,
    Age INT CHECK (Age BETWEEN 0 AND 120),
    Department VARCHAR(50) NOT NULL,
    Waiting_Time INT DEFAULT 0 CHECK (Waiting_Time >= 0),
    Patient_Status VARCHAR(30) DEFAULT 'Waiting'
);

-- Insert sample patient records
INSERT INTO Patients
    (Patient_Name, Age, Department, Waiting_Time, Patient_Status)
VALUES
    ('Patient A', 45, 'Cardiology', 35, 'Waiting'),
    ('Patient B', 30, 'Orthopedics', 20, 'In Progress'),
    ('Patient C', 62, 'Neurology', 50, 'Waiting'),
    ('Patient D', 25, 'General Medicine', 15, 'Completed'),
    ('Patient E', 54, 'Cardiology', 40, 'In Progress');

-- Display all patient records
SELECT * FROM Patients;

-- Analyze average waiting time by department
SELECT
    Department,
    COUNT(*) AS Total_Patients,
    ROUND(AVG(Waiting_Time), 2) AS Average_Waiting_Time
FROM Patients
GROUP BY Department
ORDER BY Average_Waiting_Time DESC;