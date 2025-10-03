WITH week_wise AS (
    SELECT 
        employee_id, 
        meeting_date, 
        SUM(duration_hours) AS weekly_hours,
        WEEKOFYEAR(meeting_date) AS week_num
    FROM meetings
    GROUP BY week_num, employee_id
    HAVING weekly_hours > 20
)
SELECT 
    e.employee_id, 
    e.employee_name, 
    e.department, 
    COUNT(1) AS meeting_heavy_weeks
FROM week_wise w
JOIN employees e 
    ON e.employee_id = w.employee_id
GROUP BY e.employee_id, e.employee_name, e.department
HAVING meeting_heavy_weeks > 1
ORDER BY meeting_heavy_weeks DESC, e.employee_name;
-- Find employees who have had more than 20 hours of meetings in a week for more than one week