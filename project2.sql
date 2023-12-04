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
--II, Tạo metric trước khi dựng dashboard
--1, Tạo dataset
    with cte as(
  select
  EXTRACT(MONTH FROM a.created_at) as month, EXTRACT(YEAR FROM a.created_at) AS year,
  c.category as Product_category, 
  sum(b.sale_price) as TPV,
  count(a.order_id) as TPO,
  sum(c.cost) as total_cost
  from bigquery-public-data.thelook_ecommerce.orders as a
  join bigquery-public-data.thelook_ecommerce.order_items as b on b.order_id=a.order_id
  join bigquery-public-data.thelook_ecommerce.products as c on c.id=b.id
  group by month, year, Product_category
)
select
month, year, Product_category,TPV,TPO,
ROUND((TPV-lag(TPV) over (PARTITION BY Product_category ORDER BY year, month)/lag(TPV) over(partition by Product_category order by year,month)), 4) * 100 AS Revenue_ggrowth,
ROUND((TPO-lag(TPO) over (PARTITION BY Product_category ORDER BY year, month)/lag(TPO) over(partition by Product_category order by year,month)), 4) * 100 AS Order_growth,
total_cost,
round(TPV-total_cost,4) as total_profit,
round((TPV-total_cost)/total_cost,4) as Profit_to_cost_ratio
from cte
order by Product_category, year, month
--2, Cohort_chart
with cte1 as(
SELECT 
  user_id,
	amount,
	 FORMAT_DATE('%Y-%m', first_purchase_date) as cohort_month,
	created_at,
	(extract(year from created_at)-extract(year from first_purchase_date))*12
	+(extract(month from created_at)-extract(month from first_purchase_date))+1 as index
FROM(
	SELECT user_id,
	round(sale_price,4) AS amount,
MIN(created_at) over(PARTITION BY user_id) as first_purchase_date ,
created_at
from bigquery-public-data.thelook_ecommerce.order_items
) a)
,xxx as(
SELECT 
cohort_month,
index,
count(distinct user_id) as user_count,
round(sum(amount),4) as revenue
from cte1
group by cohort_month, index),

---CUSTOMER_COHORT
customer_cohort as(
select 
cohort_month,
sum(case when index=1 then user_count else 0 end ) as m1,
sum(case when index=2 then user_count else 0 end ) as m2,
sum(case when index=3 then user_count else 0 end ) as m3,
sum(case when index=4 then user_count else 0 end ) as m4
from xxx
group by cohort_month
order by cohort_month)
--RETENTION COHORT
,retention_cohort as(
select cohort_month,
concat(round(100.00*m1/m1,2),'%') as m1,
concat(round(100.00*m2/m1,2),'%') as m2,
concat(round(100.00*m3/m1,2),'%') as m3,
concat(round(100.00*m4/m1,2),'%') as m4
from customer_cohort
)
--CHURN COHORT
select cohort_month,
 concat(100.00-round(100.00*m1/m1,2),'%') as m1,
 concat(100.00-round(100.00*m2/m1,2),'%') as m2,
 concat(100.00-round(100.00*m3/m1,2),'%') as m3,
 concat(100.00-round(100.00*m4/m1,2),'%') as m4
 from customer_cohort
--LINK Cohort_chart: https://docs.google.com/spreadsheets/d/1w9msL2pQgfPL50NTkJ42XpxUbnm09shbCHvyBrqBuio/edit?usp=sharing
/* INSIGHT: - Tổng quan, mỗi tháng The Look đều có sự gia tăng về số lượng người dùng đây cũng có thể đánh giá là 1 tín hiệu tốt
            - Tuy nhiên, tỉ lệ người dùng quay lại The Look là rất thấp kể từ ngày mua hàng đầu tiên (dưới 10% cho đến 8-2023 mới trên 10%)
            - Song song với tỉ lệ trở lại thấp là tỉ lệ rời bỏ The Look cực kỳ cao hầu như chắc chắn người dùng sẽ rời bỏ sau khi sử dụng và mua hàng lần đầu tiên
--> Do vậy, The Look cần có những giải pháp kịp thời ngay lập tức ví dụ như những chiến dịch marketing thu hút hơn, những tuần lễ giảm giá với đa dạng mặt hàng,... để có thể giữ chân khách hàng ở lại sử dụng dịch vụ








