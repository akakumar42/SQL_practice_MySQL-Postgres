WITH free_try AS (
    SELECT user_id, ROUND(AVG(activity_duration), 2) AS trial_avg_duration
    FROM UserActivity
    WHERE activity_type = 'free_trial'
    GROUP BY user_id
),
paid_sub AS (
    SELECT user_id, ROUND(AVG(activity_duration), 2) AS paid_avg_duration
    FROM UserActivity
    WHERE activity_type = 'paid'
    GROUP BY user_id
)
SELECT p.user_id, trial_avg_duration, paid_avg_duration
FROM paid_sub p
LEFT JOIN free_try f ON p.user_id = f.user_id
WHERE paid_avg_duration IS NOT NULL
ORDER BY user_id;