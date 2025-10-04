WITH positive AS (
    SELECT 
        patient_id, 
        MIN(test_date) AS first_positive
    FROM covid_tests
    WHERE result = 'Positive'
    GROUP BY patient_id
),
negative AS (
    SELECT 
        patient_id, 
        test_date
    FROM covid_tests
    WHERE result = 'Negative'
),
pn AS (
    SELECT 
        pos.patient_id, 
        pos.first_positive, 
        MIN(neg.test_date) AS first_negative
    FROM positive pos
    JOIN negative neg
        ON pos.patient_id = neg.patient_id
       AND neg.test_date > pos.first_positive
    GROUP BY pos.patient_id, pos.first_positive
)
SELECT 
    pn.patient_id, 
    pat.patient_name, 
    pat.age,
    DATEDIFF(pn.first_negative, pn.first_positive) AS recovery_time
FROM pn
JOIN patients pat 
    ON pn.patient_id = pat.patient_id
ORDER BY recovery_time ASC, pat.patient_name ASC;
-- Find patients who tested positive and then negative, and calculate recovery time
-- Recovery time is the difference in days between the first positive test and the first negative test after that
-- Output patient_id, patient_name, age, and recovery_time