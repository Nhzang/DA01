--ex1
SELECT count(DISTINCT(a.company_id)) as duplicate_companies
FROM job_listings as a
LEFT JOIN job_listings AS b ON a.company_id = b.company_id
WHERE a.title = b.title 
AND a.description = b.description 
AND a.job_id <> b.job_id
--ex2
with cte1 as 
(
select category, product, sum(spend) as total_spend
from product_spend
where category = 'appliance'
and transaction_date >= '2022-01-01' 
    AND transaction_date <= '2022-12-31' 
group by category,product
order by sum(spend) desc
limit 2
),
cte2 as
(select category, product, sum(spend) as total_spend
from product_spend
where category = 'electronics'
and  transaction_date >= '2022-01-01' 
    AND transaction_date <= '2022-12-31' 
group by category,product
order by sum(spend) desc
limit 2
)
select *
from cte1 
UNION all
select *
from cte2
--ex3
SELECT COUNT(members) AS member_count
FROM
(SELECT 
  policy_holder_id AS members,
  COUNT(case_id) AS calls
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id)>=3) AS member_count;
--ex4
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes AS b
  ON a.page_id = b.page_id
WHERE b.page_id IS NULL;
--ex5
with cte as 
(SELECT  user_id	
from user_actions 
where EXTRACT(month from event_date) in (6,7) 
and EXTRACT(year from event_date) = 2022 
GROUP BY user_id 
having count(DISTINCT EXTRACT(month from event_date)) = 2)

SELECT 7 as month_ , count(*) as number_of_user 
from cte
--ex6
Select left(trans_date, 7) as month, 
    country,
    count(id) as trans_count,
    sum(state = 'approved') as approved_count,
    sum(amount) as trans_total_amount,
    sum(case 
            when state = 'approved' then amount 
            else 0
        end) as approved_total_amount
from Transactions 
group by month, country
--ex7
WITH min_year_table AS (
SELECT product_id, min(year) min_year
FROM sales
GROUP BY product_id)

SELECT a.product_id, a.year first_year, quantity, price
FROM sales as a
JOIN min_year_table as m ON a.product_id = m.product_id and a.year = m.min_year
--ex8
SELECT c.customer_id
FROM Customer c
group by customer_id 
HAVING count(distinct c.product_key) = (select count(distinct p.product_key) FROM Product p);
--ex9
with cte as(
  select *
  from Employees
  where manager_id is not null
)
select a.employee_id from 
cte as a left join Employees as b
on b.employee_id =a.manager_id 
where a.salary <30000 and b.employee_id is null
order by a.employee_id
--ex10
SELECT count(DISTINCT(a.company_id)) as duplicate_companies
FROM job_listings as a
LEFT JOIN job_listings AS b ON a.company_id = b.company_id
WHERE a.title = b.title 
AND a.description = b.description 
AND a.job_id <> b.job_id
--ex11
(SELECT name AS results
FROM Users
INNER JOIN MovieRating USING(user_id)
GROUP BY user_id
ORDER BY COUNT(rating) DESC, name
LIMIT 1)

UNION ALL

(SELECT title AS results
FROM Movies
INNER JOIN MovieRating USING(movie_id)
WHERE MONTH(created_at) = '02' AND YEAR(created_at) = '2020'
GROUP BY title
ORDER BY AVG(rating) DESC, title
LIMIT 1)
--ex12
with base 
as(select requester_id id from RequestAccepted
union all
select accepter_id id from RequestAccepted)

select id, count(*) num  from base group by id order by count(*) desc 
limit 1
