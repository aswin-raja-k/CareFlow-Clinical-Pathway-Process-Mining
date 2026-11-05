USE careflow;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Sepsis Cases - Event Log.csv'
INTO TABLE sepsis_event_log
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @row_num,
    @infection,
    @org_group,
    @blood,
    @disfunc,
    @tachypnea,
    @hypotensie,
    @heart_rate,
    @infusion,
    @art_astrup,
    `concept:name`,
    @age,
    @diagnostic_ic,
    @sputum,
    @liquor,
    @other,
    @sirs_criteria,
    @xthorax,
    @temperature,
    @event_time,
    @urinary_culture,
    @sirs_leucos,
    @oligurie,
    @lactic_test,
    `lifecycle:transition`,
    Diagnose,
    @hypoxie,
    @urinary_sediment,
    @ecg,
    `case:concept:name`,
	@leucocytes,
	@crp,
	@lactic_acid
)
SET
    InfectionSuspected = CASE LOWER(@infection) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    `org:group` = @org_group,
    Age = NULLIF(TRIM(@age), ''),
    DiagnosticBlood = CASE LOWER(@blood) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DisfuncOrg = CASE LOWER(@disfunc) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    SIRSCritTachypnea = CASE LOWER(@tachypnea) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    Hypotensie = CASE LOWER(@hypotensie) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    SIRSCritHeartRate = CASE LOWER(@heart_rate) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    Infusion = CASE LOWER(@infusion) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticArtAstrup = CASE LOWER(@art_astrup) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticIC = CASE LOWER(@diagnostic_ic) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticSputum = CASE LOWER(@sputum) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticLiquor = CASE LOWER(@liquor) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticOther = CASE LOWER(@other) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    SIRSCriteria2OrMore = CASE LOWER(@sirs_criteria) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticXthorax = CASE LOWER(@xthorax) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    SIRSCritTemperature = CASE LOWER(@temperature) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    `time:timestamp` = STR_TO_DATE(LEFT(@event_time, 19), '%Y-%m-%d %H:%i:%s'),
    DiagnosticUrinaryCulture = CASE LOWER(@urinary_culture) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    SIRSCritLeucos = CASE LOWER(@sirs_leucos) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    Oligurie = CASE LOWER(@oligurie) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticLacticAcid = CASE LOWER(@lactic_test) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    Hypoxie = CASE LOWER(@hypoxie) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticUrinarySediment = CASE LOWER(@urinary_sediment) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    DiagnosticECG = CASE LOWER(@ecg) WHEN 'true' THEN 1 WHEN 'false' THEN 0 ELSE NULL END,
    
Leucocytes = NULLIF(TRIM(@leucocytes), ''),
CRP = NULLIF(TRIM(@crp), ''),
LacticAcid = CASE
    WHEN TRIM(@lactic_acid) = '' THEN NULL
    ELSE CAST(@lactic_acid AS DECIMAL(10,2))
END;
    
    
    
    
    
    
    
  SELECT COUNT(*) AS total_rows
FROM careflow.sepsis_event_log;  
    
USE careflow;

SHOW VARIABLES LIKE 'secure_file_priv';
    
    
USE careflow;

SELECT
    @@version AS mysql_version,
    @@local_infile AS local_infile_enabled;
    
    
    
    
 SELECT COUNT(*) AS total_rows
FROM careflow.sepsis_raw_import;   
    
SELECT
    NULLIF(TRIM(''), '') AS cleaned_empty,
    NULLIF(TRIM('  '), '') AS cleaned_spaces,
    NULLIF(TRIM('12.5'), '') AS cleaned_number;
    
    
    
SELECT COUNT(*) AS total_rows
FROM careflow.sepsis_event_log;

USE careflow;

SELECT
    NULLIF(TRIM(''), '') AS test_leucocytes,
    NULLIF(TRIM(''), '') AS test_crp,
    NULLIF(TRIM(''), '') AS test_lactic_acid;