WITH store_counts AS (
    SELECT store_id
    FROM inventory
    GROUP BY store_id
    HAVING COUNT(*) > 2
),
expensive AS (
    SELECT store_id, product_name AS exps, quantity AS exq
    FROM (
        SELECT i.store_id,
               i.product_name,
               i.quantity,
               RANK() OVER (PARTITION BY i.store_id ORDER BY i.price DESC) AS rnk
        FROM inventory i
        JOIN store_counts sc ON i.store_id = sc.store_id
    ) ranked
    WHERE rnk = 1
),
cheapest AS (
    SELECT store_id, product_name AS cheap, quantity AS chq
    FROM (
        SELECT i.store_id,
               i.product_name,
               i.quantity,
               RANK() OVER (PARTITION BY i.store_id ORDER BY i.price ASC) AS rnk
        FROM inventory i
        JOIN store_counts sc ON i.store_id = sc.store_id
    ) ranked
    WHERE rnk = 1
)
SELECT s.store_id,
       s.store_name,
       s.location,
       e.exps AS most_exp_product,
       c.cheap AS cheapest_product,
       ROUND(c.chq / e.exq, 2) AS imbalance_ratio
FROM expensive e
JOIN cheapest c ON e.store_id = c.store_id
JOIN stores s ON e.store_id = s.store_id
WHERE e.exq < c.chq
ORDER BY imbalance_ratio DESC, s.store_name;