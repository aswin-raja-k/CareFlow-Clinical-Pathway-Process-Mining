CREATE DATABASE CareFlow;

USE CareFlow;

CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(50),
    Age INT,
    Department VARCHAR(50),
    Waiting_Time INT
);