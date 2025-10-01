/*WITH user_products AS (
    SELECT user_id, product_id
    FROM ProductPurchases
    GROUP BY user_id, product_id
),
product_pairs AS (
    SELECT 
        up1.user_id,
        up1.product_id AS product1_id,
        up2.product_id AS product2_id
    FROM user_products up1
    JOIN user_products up2
      ON up1.user_id = up2.user_id
     AND up1.product_id < up2.product_id
),
pair_counts AS (
    SELECT 
        product1_id,
        product2_id,
        COUNT(DISTINCT user_id) AS customer_count
    FROM product_pairs
    GROUP BY product1_id, product2_id
    HAVING COUNT(DISTINCT user_id) >= 3
)
SELECT 
    pc.product1_id,
    pc.product2_id,
    pi1.category AS product1_category,
    pi2.category AS product2_category,
    pc.customer_count
FROM pair_counts pc
JOIN ProductInfo pi1 ON pc.product1_id = pi1.product_id
JOIN ProductInfo pi2 ON pc.product2_id = pi2.product_id
ORDER BY pc.customer_count DESC, pc.product1_id, pc.product2_id;
*/
SELECT
P1.product_id AS product1_id,
P2.product_id AS product2_id,
PI1.category AS product1_category,
PI2.category AS product2_category,
COUNT(P1.user_id) AS customer_count
FROM ProductPurchases P1
INNER JOIN ProductPurchases P2 ON P1.user_id=P2.user_id AND P1.product_id<P2.product_id
LEFT JOIN ProductInfo PI1 ON P1.product_id=PI1.product_id
LEFT JOIN ProductInfo PI2 ON P2.product_id=PI2.product_id
GROUP BY product1_id,product2_id
HAVING COUNT(P1.user_id)>=3
ORDER BY customer_count DESC,product1_id,product2_id;