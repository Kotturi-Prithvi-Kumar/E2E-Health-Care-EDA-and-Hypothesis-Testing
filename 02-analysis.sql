 USE hospital_analytics;


# Top 15 most common primary diagnoses with full ICD description and patient count
SELECT d.icd9_code,
       dd.short_title,
       COUNT(DISTINCT d.hadm_id)          AS admission_count,
       ROUND(AVG(a.los_hours), 1)          AS avg_los_hours
FROM diagnoses_icd d
JOIN d_icd_diagnoses dd ON d.icd9_code = dd.icd9_code
JOIN admissions a       ON d.hadm_id   = a.hadm_id
WHERE d.seq_num = 1
GROUP BY d.icd9_code, dd.short_title
ORDER BY admission_count DESC
LIMIT 15;
# ================================================================
# Rank diagnoses by frequency within each admission type
SELECT a.admission_type, dd.short_title,COUNT(*) AS freq,
       RANK() OVER (PARTITION BY a.admission_type ORDER BY COUNT(*) DESC) AS type_rank
FROM diagnoses_icd d
JOIN admissions a       ON d.hadm_id   = a.hadm_id
JOIN d_icd_diagnoses dd ON d.icd9_code = dd.icd9_code
WHERE d.seq_num = 1
GROUP BY a.admission_type, dd.short_title;
# =================================================================
# Admissions above average LOS (subquery)
SELECT a.hadm_id, p.gender, a.admission_type,
       ROUND(a.los_hours, 1) AS los_hours
FROM admissions a
JOIN patients p ON a.subject_id = p.subject_id
WHERE a.los_hours > (SELECT AVG(los_hours) FROM admissions WHERE los_hours > 0)
ORDER BY los_hours DESC;
# ==================================================================
# Most prescribed drug per admission type using CTE
WITH drug_counts AS (
  SELECT a.admission_type, pr.drug,
         COUNT(*) AS prescriptions,
         RANK() OVER (PARTITION BY a.admission_type ORDER BY COUNT(*) DESC) AS rnk
  FROM prescriptions pr
  JOIN admissions a ON pr.hadm_id = a.hadm_id
  GROUP BY a.admission_type, pr.drug
)
SELECT admission_type, drug, prescriptions
FROM drug_counts WHERE rnk = 1;
#=================================================================
# LEFT JOIN All patients with total number of admissions including patients with zero admissions
SELECT 
    p.subject_id,
    p.gender,
    COUNT(a.hadm_id) AS total_admissions
FROM patients p
LEFT JOIN admissions a ON p.subject_id = a.subject_id
GROUP BY p.subject_id, p.gender
ORDER BY total_admissions DESC;
#=================================================================
# GROUP BY + HAVING Diagnosis codes appearing in more than 5 admissions 
# with average LOS greater than 48 hours
SELECT 
    d.icd9_code,
    dd.short_title,
    COUNT(DISTINCT d.hadm_id)  AS admission_count,
    ROUND(AVG(a.los_hours), 1) AS avg_los_hours
FROM diagnoses_icd d
JOIN d_icd_diagnoses dd ON d.icd9_code = dd.icd9_code
JOIN admissions a       ON d.hadm_id   = a.hadm_id
WHERE a.timestamp_error = 0
GROUP BY d.icd9_code, dd.short_title
HAVING COUNT(DISTINCT d.hadm_id) > 5
   AND AVG(a.los_hours) > 48
ORDER BY avg_los_hours DESC;
#=================================================================
#  WINDOW FUNCTION — RANK() Rank diagnoses by frequency within each admission type
SELECT 
    a.admission_type,
    dd.short_title,
    COUNT(*) AS freq,
    RANK() OVER (
        PARTITION BY a.admission_type 
        ORDER BY COUNT(*) DESC
    ) AS type_rank
FROM diagnoses_icd d
JOIN admissions a       ON d.hadm_id   = a.hadm_id
JOIN d_icd_diagnoses dd ON d.icd9_code = dd.icd9_code
WHERE d.seq_num = 1
GROUP BY a.admission_type, dd.short_title
ORDER BY a.admission_type, type_rank;
#=================================================================
# WINDOW FUNCTION — LAG() Month-over-month change in total admissions
WITH monthly AS (
    SELECT 
        DATE_FORMAT(admittime, '%Y-%m') AS month,
        COUNT(*) AS total_admissions
    FROM admissions
    GROUP BY DATE_FORMAT(admittime, '%Y-%m')
)
SELECT 
    month,
    total_admissions,
    LAG(total_admissions) OVER (ORDER BY month) AS prev_month_admissions,
    total_admissions - LAG(total_admissions) OVER (ORDER BY month) AS mom_change
FROM monthly
ORDER BY month;
#=================================================================
# SUBQUERY IN WHERE Admissions whose LOS exceeds overall average LOS
SELECT 
    a.hadm_id,
    p.gender,
    a.admission_type,
    ROUND(a.los_hours, 1) AS los_hours
FROM admissions a
JOIN patients p ON a.subject_id = p.subject_id
WHERE a.los_hours > (
    SELECT AVG(los_hours) 
    FROM admissions 
    WHERE los_hours > 0 
      AND timestamp_error = 0
)
ORDER BY los_hours DESC;
#=================================================================
#  SUBQUERY IN FROM Avg prescriptions per admission 
# readmitted within 30 days vs not readmitted
SELECT 
    readmission_30d,
    ROUND(AVG(prescription_count), 2) AS avg_prescriptions
FROM (
    SELECT 
        a.hadm_id,
        a.readmission_30d,
        COUNT(pr.row_id) AS prescription_count
    FROM admissions a
    LEFT JOIN prescriptions pr ON a.hadm_id = pr.hadm_id
    GROUP BY a.hadm_id, a.readmission_30d
) AS sub
GROUP BY readmission_30d;


#=================================================================
#  CASE WHEN Classify patients into age groups
SELECT 
    a.hadm_id,
    a.age_at_admission,
    CASE 
        WHEN a.age_at_admission < 18              THEN 'Paediatric'
        WHEN a.age_at_admission BETWEEN 18 AND 64 THEN 'Adult'
        WHEN a.age_at_admission BETWEEN 65 AND 79 THEN 'Senior'
        WHEN a.age_at_admission >= 80             THEN 'Elderly'
        ELSE 'Unknown'
    END AS age_group,
    a.admission_type,
    a.insurance
FROM admissions a
ORDER BY a.age_at_admission;

#=================================================================
# CONCAT + STRING FUNCTIONS Create a descriptive label per admission
SELECT 
    a.hadm_id,
    CONCAT(
        a.admission_type, ' – ',
        a.insurance, ' – ',
        'Age ', a.age_at_admission,
        ' (HADM: ', a.hadm_id, ')'
    ) AS admission_label
FROM admissions a
ORDER BY a.hadm_id;
#=================================================================
-- Q10: DATE/TIME FILTERING Compare average LOS: weekdays vs weekends
SELECT 
    CASE 
        WHEN DAYOFWEEK(admittime) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*)                   AS total_admissions,
    ROUND(AVG(los_hours), 1)   AS avg_los_hours
FROM admissions
WHERE timestamp_error = 0
AND los_hours > 0
GROUP BY day_type;
#=================================================================
# CTE (WITH clause) Most frequently prescribed drugper admission type
WITH drug_counts AS (
    SELECT 
        a.admission_type,
        pr.drug,
        COUNT(*) AS prescriptions,
        RANK() OVER (
            PARTITION BY a.admission_type 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM prescriptions pr
    JOIN admissions a ON pr.hadm_id = a.hadm_id
    GROUP BY a.admission_type, pr.drug
)
SELECT 
    admission_type,
    drug,
    prescriptions
FROM drug_counts
WHERE rnk = 1;
#=================================================================
#  STORED PROCEDURE Accepts insurance type → returns top 10 longest stays for that insurance category
DELIMITER $$

CREATE PROCEDURE GetTopStaysByInsurance(IN ins_type VARCHAR(30))
BEGIN
    SELECT 
        a.hadm_id,
        a.subject_id,
        a.insurance,
        a.admission_type,
        a.diagnosis,
        ROUND(a.los_hours, 1) AS los_hours
    FROM admissions a
    WHERE a.insurance = ins_type
      AND a.timestamp_error = 0
      AND a.los_hours > 0
    ORDER BY a.los_hours DESC
    LIMIT 10;
END$$

DELIMITER ;
#=================================================================
# Which insurance type is associated with the longest average LOS?
SELECT 
    insurance,
    COUNT(*) AS total_admissions,
    ROUND(AVG(los_hours), 1) AS avg_los_hours
FROM admissions
WHERE timestamp_error = 0
  AND los_hours > 0
GROUP BY insurance
ORDER BY avg_los_hours DESC;
#=================================================================
# % of ER patients with at least one abnormal lab result during their stay
SELECT 
    ROUND(
        COUNT(DISTINCT CASE WHEN l.flag = 'abnormal' THEN a.hadm_id END) * 100.0 
        / COUNT(DISTINCT a.hadm_id), 2
    ) AS pct_er_with_abnormal_lab
FROM admissions a
LEFT JOIN labevents l ON a.hadm_id = l.hadm_id
WHERE a.admission_location LIKE '%EMERGENCY%';
#=================================================================
# Top 10 procedures most commonly performed alongside the top primary diagnosis
WITH top_diag AS (
    SELECT icd9_code
    FROM diagnoses_icd
    WHERE seq_num = 1
    GROUP BY icd9_code
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT 
    pr.icd9_code,
    dp.short_title,
    COUNT(*) AS procedure_count
FROM procedures_icd pr
JOIN d_icd_procedures dp ON pr.icd9_code = dp.icd9_code
WHERE pr.hadm_id IN (
    SELECT hadm_id FROM diagnoses_icd
    WHERE icd9_code = (SELECT icd9_code FROM top_diag)
)
GROUP BY pr.icd9_code, dp.short_title
ORDER BY procedure_count DESC
LIMIT 10;


#=================================================================
#  Do weekend admissions have higher in-hospital mortality than weekdays?
SELECT 
    CASE 
        WHEN DAYOFWEEK(admittime) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_admissions,
    SUM(hospital_expire_flag) AS deaths,
    ROUND(SUM(hospital_expire_flag) * 100.0 
          / COUNT(*), 2) AS mortality_rate_pct
FROM admissions
GROUP BY day_type;


#=================================================================
-- BQ5: Which discharge location has the highest 30-day readmission rate?
SELECT 
    discharge_location,
    COUNT(*) AS total_admissions,
    SUM(readmission_30d) AS readmissions,
    ROUND(SUM(readmission_30d) * 100.0 
        / COUNT(*), 2) AS readmission_rate_pct
FROM admissions
GROUP BY discharge_location
ORDER BY readmission_rate_pct DESC;
