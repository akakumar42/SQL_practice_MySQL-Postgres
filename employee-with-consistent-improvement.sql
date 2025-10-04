WITH ranked AS (
    SELECT
        pr.employee_id,
        pr.review_date,
        pr.rating,
        ROW_NUMBER() OVER (
            PARTITION BY pr.employee_id
            ORDER BY pr.review_date DESC
        ) AS rn,
        COUNT(*) OVER (PARTITION BY pr.employee_id) AS cnt
    FROM performance_reviews pr
),
last_three AS (
    SELECT
        employee_id,
        review_date,
        rating
    FROM ranked
    WHERE rn <= 3 AND cnt >= 3
),
steps AS (
    SELECT
        employee_id,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date ASC
        ) AS step
    FROM last_three
),
pivoted AS (
    SELECT
        employee_id,
        MAX(CASE WHEN step = 1 THEN rating END) AS r1,
        MAX(CASE WHEN step = 2 THEN rating END) AS r2,
        MAX(CASE WHEN step = 3 THEN rating END) AS r3
    FROM steps
    GROUP BY employee_id
),
increasing AS (
    SELECT
        employee_id,
        (r3 - r1) AS improvement_score
    FROM pivoted
    WHERE r1 < r2 AND r2 < r3
)
SELECT
    e.employee_id,
    e.name,
    i.improvement_score
FROM increasing i
JOIN employees e
  ON e.employee_id = i.employee_id
ORDER BY i.improvement_score DESC, e.name ASC;
-- Find employees who have consistently improved their performance ratings over their last three reviews
-- Output employee_id, name, and improvement_score (difference between latest and earliest rating)