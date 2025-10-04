WITH sales_with_season AS (
    SELECT 
        s.sale_id,
        s.product_id,
        s.sale_date,
        s.quantity,
        s.price,
        CASE 
            WHEN EXTRACT(MONTH FROM s.sale_date) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM s.sale_date) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM s.sale_date) IN (6, 7, 8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM s.sale_date) IN (9, 10, 11) THEN 'Fall'
        END AS season
    FROM sales s
),
category_stats AS (
    SELECT 
        sws.season,
        p.category,
        SUM(sws.quantity) AS total_quantity,
        SUM(sws.quantity * sws.price) AS total_revenue
    FROM sales_with_season sws
    JOIN products p ON sws.product_id = p.product_id
    GROUP BY sws.season, p.category
),
ranked AS (
    SELECT 
        season,
        category,
        total_quantity,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY season 
            ORDER BY total_quantity DESC, total_revenue DESC
        ) AS rn
    FROM category_stats
)
SELECT 
    season,
    category,
    total_quantity,
    total_revenue
FROM ranked
WHERE rn = 1
ORDER BY season;
-- Find the top-selling product category for each season based on total quantity sold
-- If there's a tie in quantity, use total revenue to break the tie