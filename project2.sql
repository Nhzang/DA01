--ex1
SELECT 
    CONCAT(EXTRACT(MONTH FROM created_at),'-',EXTRACT(YEAR FROM created_at)) AS year_month,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(order_id) AS total_orders,
    COUNT(CASE WHEN status = 'Complete' THEN order_id END) AS completed_orders
FROM 
    bigquery-public-data.thelook_ecommerce.order_items
WHERE 
    DATE(created_at) >= '2019-01-01' AND DATE(created_at) <= '2022-04-30'
GROUP BY 1
ORDER BY total_orders;
/*Insight: lượng người mua và số lượng đơn hàng tăng theo từng tháng8*/
--ex2
WITH MonthlyOrders AS (
    SELECT 
        concat(extract(MONTH from created_at),'-',extract(YEAR from created_at)) AS year_month,
        COUNT(DISTINCT user_id) AS distinct_users,
        AVG(sale_price) as  average_order_value
    FROM 
        bigquery-public-data.thelook_ecommerce.order_items
    WHERE 
        DATE(created_at) >= '2019-01-01' AND DATE(created_at) <= '2022-04-30'
    GROUP BY 1        
)

SELECT 
    year_month,
    distinct_users,
    average_order_value
FROM 
    MonthlyOrders
ORDER BY 
    distinct_users;
/*Insight: Tổng số người dùng mỗi tháng tăng 
           Giá trị đơn hàng trung bình từ tháng 1-2019 có sự biến động nhẹ đến tháng 7-2019 thì duy trì ở mức đều 0,06k cho tới năm 2022 */
--ex3
WITH YoungestCustomers AS (
    SELECT 
        first_name,
        last_name,
        gender,
        age,
        'youngest' AS tag
    FROM 
        bigquery-public-data.thelook_ecommerce.users
    WHERE 
        DATE(created_at) >= '2019-01-01' AND DATE(created_at) <= '2022-04-30'
        AND age = (
            SELECT 
                MIN(age)
            FROM 
                bigquery-public-data.thelook_ecommerce.users as sub
           
        )
),
OldestCustomers AS (
    SELECT 
        first_name,
        last_name,
        gender,
        age,
        'oldest' AS tag
    FROM 
        bigquery-public-data.thelook_ecommerce.users
    WHERE 
        DATE(created_at) >= '2019-01-01' AND DATE(created_at) <= '2022-04-30'
        AND age = (
            SELECT 
                MAX(age)
            FROM 
                bigquery-public-data.thelook_ecommerce.users as sub
          
        )
)

SELECT 
    first_name,
    last_name,
    gender,
    age,
    tag
FROM 
    YoungestCustomers --1115

UNION ALL

SELECT 
    first_name,
    last_name,
    gender,
    age, --1150
    tag
FROM  OldestCustomers
ORDER BY gender 
/*Insight: Người trẻ nhất là 12 tuổi, số lượng: 1115 
           Người già nhất là 70 tuổi, số lượng: 1150 */
--ex4
WITH MonthlyProductProfit AS (
    SELECT 
        CONCAT(EXTRACT(YEAR FROM a.created_at), '-', EXTRACT(MONTH FROM a.created_at)) as month_year,
        a.product_id,
        c.name AS product_name,
        SUM(a.sale_price) AS sales,
        SUM(c.cost) AS cost,
        SUM(a.sale_price - c.cost) AS profit
    FROM 
        bigquery-public-data.thelook_ecommerce.order_items AS a
    JOIN bigquery-public-data.thelook_ecommerce.inventory_items AS b ON a.product_id = b.product_id
    JOIN bigquery-public-data.thelook_ecommerce.products AS c ON b.id = c.id
    WHERE 
        DATE(a.created_at) >= '2019-01-01' AND DATE(a.created_at) <= '2022-04-30'
    GROUP BY 
        month_year, a.product_id, product_name
)

SELECT 
    month_year,
    product_id,
    product_name,
    sales,
    cost,
    profit,
    DENSE_RANK() OVER(PARTITION BY month_year ORDER BY profit DESC) AS rank_per_month
FROM 
    MonthlyProductProfit
ORDER BY 
    month_year, rank_per_month
LIMIT 5; 
--ex5
SELECT 
    DATE(a.created_at) AS dates,
    b.product_category as product_categories,
    SUM(a.sale_price) AS revenue
FROM 
    bigquery-public-data.thelook_ecommerce.order_items AS a
JOIN 
    bigquery-public-data.thelook_ecommerce.inventory_items AS b ON a.product_id = b.product_id
WHERE 
    DATE(a.created_at) >= DATE_SUB(DATE '2022-04-15', INTERVAL 3 MONTH)
    AND DATE(a.created_at) <= DATE '2022-04-15'
GROUP BY 
    dates,product_category
ORDER BY 
    dates , revenue desc;



