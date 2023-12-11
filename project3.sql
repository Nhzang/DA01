select*from public.sales_dataset_rfm_prj_clean
--ex1
SELECT productline, year_id, dealsize, SUM(sales) AS TotalRevenue
FROM public.sales_dataset_rfm_prj_clean
GROUP BY productline, year_id, dealsize
ORDER BY productline, year_id, dealsize;
--ex2
SELECT 
	month_id,
	ordernumber,
    SUM(sales) AS REVENUE  
FROM 
    public.sales_dataset_rfm_prj_clean
GROUP BY 
   month_id, ordernumber
ORDER BY 
    REVENUE DESC;
--ex3
	SELECT 
		month_id,
        productline,
		ordernumber,
        SUM(sales) AS Revenue
    FROM 
         public.sales_dataset_rfm_prj_clean
    WHERE 
        month_id = 11
    GROUP BY 
         month_id,
        productline,
		ordernumber
    ORDER BY 
        Revenue DESC
    LIMIT 1
--ex4
WITH RankedProducts AS (
    SELECT 
        year_id,
        productline,
        SUM(sales) AS REVENUE,
        RANK() OVER(PARTITION BY year_id ORDER BY SUM(sales) DESC) AS RANK
    FROM 
        public.sales_dataset_rfm_prj_clean
    WHERE 
        Country = 'UK'
    GROUP BY 
        year_id,productline
)
SELECT 
    year_id,
    productline,
    REVENUE,
    RANK
FROM 
    RankedProducts
WHERE 
    RANK = 1
ORDER BY 
    year_id;
--ex5
with customer_rfm as (
select ordernumber, customername,
current_date-MAX(orderdate) as R,
count(distinct ordernumber)as F,
sum(sales) as M
from public.sales_dataset_rfm_prj_clean a
group by ordernumber, customername)
--Bước 2: Chia các giá trị thành các khoảng trên thang điểm 1-5
,rfm_score as(
select ordernumber, customername,
ntile(5) over (order by R DESC) as R_score,
ntile(5) over (order by F DESC) as F_score,
ntile(5) over (order by M DESC) as M_score
from customer_rfm)
--bước 3: phân nhóm 125 tổhopwj R-F-M
	select ordernumber, customername,
	concat(cast(R_score as varchar),cast(F_score as varchar),cast(M_score as varchar))
	from rfm_score



