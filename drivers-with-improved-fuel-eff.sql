WITH first_half AS (
    SELECT driver_id, 
           AVG(distance_km / fuel_consumed) AS first_half_avg
    FROM trips
    WHERE MONTH(trip_date) BETWEEN 1 AND 6
    GROUP BY driver_id
),
second_half AS (
    SELECT driver_id, 
           AVG(distance_km / fuel_consumed) AS second_half_avg
    FROM trips
    WHERE MONTH(trip_date) BETWEEN 7 AND 12
    GROUP BY driver_id
)
SELECT fh.driver_id, 
       d.driver_name, 
       ROUND(fh.first_half_avg, 2) AS first_half_avg, 
       ROUND(sh.second_half_avg, 2) AS second_half_avg,
       ROUND(sh.second_half_avg - fh.first_half_avg, 2) AS efficiency_improvement
FROM first_half fh
JOIN second_half sh 
  ON fh.driver_id = sh.driver_id
JOIN drivers d 
  ON sh.driver_id = d.driver_id
WHERE  ROUND(sh.second_half_avg - fh.first_half_avg, 2) > 0
ORDER BY efficiency_improvement DESC, d.driver_name;
-- Find drivers who have improved their fuel efficiency in the second half of the year compared to the first half